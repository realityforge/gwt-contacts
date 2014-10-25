#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Dbt

  class Runtime
    def status(database)
      return <<TXT
Database Version: #{database.version}
Database Schema Hash: #{database.version_hash}
Migration Support: #{database.enable_migrations? ? 'Yes' : 'No'}
TXT
    end

    def create(database)
      create_database(database)
      init_database(database.key) do
        perform_pre_create_hooks(database)
        perform_create_action(database, :up)
        perform_create_action(database, :finalize)
        perform_post_create_hooks(database)
        perform_post_create_migrations_setup(database)
      end
    end

    def create_by_import(imp)
      database = imp.database
      create_database(database) unless partial_import_completed?
      init_database(database.key) do
        perform_pre_create_hooks(database) unless partial_import_completed?
        perform_create_action(database, :up) unless partial_import_completed?
        perform_import_action(imp, false, nil)
        perform_create_action(database, :finalize)
        perform_post_create_hooks(database)
        perform_post_create_migrations_setup(database)
      end
    end

    def drop(database)
      init_control_database(database.key) do
        db.drop(database, configuration_for_database(database))
      end
    end

    def migrate(database)
      init_database(database.key) do
        perform_migration(database, :perform)
      end
    end

    def query(database, sql)
      init_database(database.key) do
        return db.query(sql)
      end
    end

    def execute(database, sql)
      init_database(database.key) do
        db.execute(sql)
      end
    end

    def backup(database)
      init_control_database(database.key) do
        db.backup(database, configuration_for_database(database))
      end
    end

    def restore(database)
      init_control_database(database.key) do
        db.restore(database, configuration_for_database(database))
      end
    end

    def database_import(imp, module_group)
      init_database(imp.database.key) do
        perform_import_action(imp, true, module_group)
      end
    end

    def up_module_group(module_group)
      database = module_group.database
      init_database(database.key) do
        database.repository.modules.each do |module_name|
          next unless module_group.module_by_name?(module_name)
          create_module(database, module_name, :up)
          create_module(database, module_name, :finalize)
        end
      end
    end

    def down_module_group(module_group)
      database = module_group.database
      init_database(database.key) do
        database.repository.modules.reverse.each do |module_name|
          next unless module_group.module_by_name?(module_name)
          process_module(database, module_name, :down)
          tables = database.repository.table_ordering(module_name).reverse
          schema_name = database.repository.schema_name_for_module(module_name)
          db.drop_schema(schema_name, tables)
        end
      end
    end

    def load_dataset(database, dataset_name)
      init_database(database.key) do
        subdir = "#{database.datasets_dir_name}/#{dataset_name}"
        fixtures = {}
        database.repository.modules.each do |module_name|
          collect_fixtures_from_dirs(database, module_name, subdir, fixtures)
        end

        database.repository.modules.reverse.each do |module_name|
          down_fixtures(database, module_name, fixtures)
        end
        database.repository.modules.each do |module_name|
          up_fixtures(database, module_name, fixtures)
        end
      end
    end

    def load_database_config(database)
      perform_load_database_config(database)
    end

    def package_database_data(database, package_dir)
      perform_package_database_data(database, package_dir)
    end

    def filter_database_name(sql, pattern, database_key, environment = Dbt::Config.environment, optional = true)
      config_key = config_key(database_key, environment)
      return sql if optional && !Dbt.repository.configuration_for_key?(config_key)
      sql.gsub(pattern, Dbt.repository.configuration_for_key(config_key).catalog_name)
    end

    def dump_database_to_fixtures(database, base_fixture_dir, options = {})
      filter = options[:filter]
      data_set = options[:data_set]
      init_database(database.key) do
        database.repository.modules.each do |module_name|
          database.repository.table_ordering(module_name).select{|t| filter ? filter.call(t) : true}.each do |table_name|
            info("Dumping #{table_name}")
            records = load_query_into_yaml(dump_table_sql(table_name))

            fixture_filename =
              data_set ?
                "#{base_fixture_dir}/#{module_name}/#{database.datasets_dir_name}/#{data_set}/#{clean_table_name(table_name)}.yml" :
                "#{base_fixture_dir}/#{module_name}/#{database.fixture_dir_name}/#{clean_table_name(table_name)}.yml"
            emit_fixture(fixture_filename, records)
          end
        end
      end
    end

    def info(message)
      puts message
    end

    def reset
      @db = nil
    end

    def config_key_for_database(database, env = Dbt::Config.environment)
      config_key(database.key, env)
    end

    def configuration_for_database(database, env = Dbt::Config.environment)
      configuration_for_key(config_key(database.key, env))
    end

    # Hash the set of files that may be used by any create/import/migrate for the given database
    def calculate_fileset_hash(database)
      hash_files(database, collect_fileset_for_hash(database))
    end

    private

    def dump_table_sql(table_name)
      const_name = :"DUMP_SQL_FOR_#{clean_table_name(table_name).gsub('.', '_')}"

      if Object.const_defined?(const_name)
        return Object.const_get(const_name)
      else
        return "SELECT * FROM #{table_name}"
      end
    end

    def load_query_into_yaml(sql)
      records = YAML::Omap.new
      i = 0
      db.query(sql).each do |record|
        records["r#{i += 1}"] = record
      end
      records
    end

    def emit_fixture(fixture_filename, records)
      FileUtils.mkdir_p File.dirname(fixture_filename)
      File.open(fixture_filename, 'wb') do |file|
        file.write records.to_yaml
      end
    end

    IMPORT_RESUME_AT_ENV_KEY = "IMPORT_RESUME_AT"

    def partial_import_completed?
      !!ENV[IMPORT_RESUME_AT_ENV_KEY]
    end

    def perform_load_database_config(database)
      unless database.repository.modules && database.repository.modules.size > 0
        if database.load_from_classloader?
          content = load_resource(database, Dbt::Config.repository_config_file)
          database.repository.from_yaml(content)
        else
          definition = RepositoryDefinition.new

          database.pre_db_artifacts.each do |artifact|
            content = read_repository_xml_from_artifact(artifact)
            definition.merge!(RepositoryDefinition.new.from_yaml(content))
          end

          processed_config_file = false
          database.dirs_for_database('.').each do |dir|
            repository_config_file = "#{dir}/#{Dbt::Config.repository_config_file}"
            if File.exist?(repository_config_file)
              if processed_config_file
                raise "Duplicate copies of #{Dbt::Config.repository_config_file} found in database search path"
              else
                processed_config_file = true
                File.open(repository_config_file, 'r') do |input|
                  definition.merge!(RepositoryDefinition.new.from_yaml(input.read))
                end
              end
            end
          end

          database.post_db_artifacts.each do |artifact|
            content = read_repository_xml_from_artifact(artifact)
            definition.merge!(RepositoryDefinition.new.from_yaml(content))
          end

          raise "#{Dbt::Config.repository_config_file} not located in base directory of database search path and no modules defined" unless processed_config_file

          database.repository.merge!(definition)
        end
      end
      database.validate
    end

    def read_repository_xml_from_artifact(artifact)
      raise "Unable to locate database artifact #{artifact}" unless File.exist?(artifact)
      Zip::ZipFile.open(artifact) do |zip|
        filename = 'data/repository.yml'
        unless zip.file.exist?(filename)
          raise "Database artifact #{artifact} does not contain a #{filename} and thus is not in the correct format."
        end
        return zip.file.read(filename)
      end
    end

    def config_key(database_key, env = Dbt::Config.environment)
      Dbt::Config.default_database?(database_key) ? env : "#{database_key}_#{env}"
    end

    def configuration_for_key(config_key)
      Dbt.repository.configuration_for_key(config_key)
    end

    def init_database(database_key, &block)
      setup_connection(database_key, false, &block)
    end

    def init_control_database(database_key, &block)
      setup_connection(database_key, true, &block)
    end

    def create_database(database)
      configuration = configuration_for_database(database)
      return if configuration.no_create?
      init_control_database(database.key) do
        db.drop(database, configuration)
        db.create_database(database, configuration)
      end
    end

    def perform_post_create_migrations_setup(database)
      if database.enable_migrations?
        db.setup_migrations
        if database.assume_migrations_applied_at_create?
          perform_migration(database, :record)
        else
          perform_migration(database, :force)
        end
      end
    end

    def perform_migration(database, action)
      files =
        if database.load_from_classloader?
          collect_resources(database, database.migrations_dir_name)
        else
          collect_files(database, database.migrations_dir_name)
        end
      version_index = nil
      if database.version
        files.each_with_index do |filename, i|
          migration_name = File.basename(filename, '.sql')
          sep_index = migration_name.index('_')
          if sep_index
            migration_key = migration_name[sep_index + 1,migration_name.size]
            if migration_key == "Release-#{database.version}"
              version_index = i
              break
            end
          end
        end
      end
      files.each_with_index do |filename, i|
        migration_name = File.basename(filename, '.sql')
        if [:record, :force].include?(action) || db.should_migrate?(database.key.to_s, migration_name)
          should_run = (:record != action && !(version_index && version_index >= i))
          run_sql_file(database, "Migration: ", filename, false) if should_run
          db.mark_migration_as_run(database.key.to_s, migration_name)
        end
      end
    end

    def perform_post_create_hooks(database)
      database.post_create_dirs.each do |dir|
        process_dir_set(database, dir, false, "#{'%-15s' % ''}: #{dir_display_name(dir)}")
      end
    end

    def perform_pre_create_hooks(database)
      database.pre_create_dirs.each do |dir|
        process_dir_set(database, dir, false, "#{'%-15s' % ''}: #{dir_display_name(dir)}")
      end
    end

    def import(imp, module_name, should_perform_delete)
      ordered_tables = imp.database.repository.table_ordering(module_name)

      # check the import configuration is set
      configuration_for_key(config_key(imp.database.key, "import"))

      # Iterate over module in dependency order doing import as appropriate
      # Note: that tables with initial fixtures are skipped
      tables = ordered_tables.reject do |table|
        try_find_file_in_module(imp.database, module_name, imp.database.fixture_dir_name, table, 'yml')
      end

      unless imp.database.load_from_classloader?
        dirs = imp.database.search_dirs.map { |d| "#{d}/#{module_name}/#{imp.dir}" }
        filesystem_files = dirs.collect { |d| Dir["#{d}/*.yml"] + Dir["#{d}/*.sql"] }.flatten.compact
        tables.each do |table_name|
          table_name = clean_table_name(table_name)
          sql_file = /#{table_name}.sql$/
          yml_file = /#{table_name}.yml$/
          filesystem_files = filesystem_files.delete_if { |f| f =~ sql_file || f =~ yml_file }
        end
        raise "Discovered additional files in import directory in database search path. Files: #{filesystem_files.inspect}" unless filesystem_files.empty?
      end

      if should_perform_delete && !partial_import_completed?
        tables.reverse.each do |table|
          info("Deleting #{clean_table_name(table)}")
          run_sql_batch("DELETE FROM #{table}")
        end
      end

      tables.each do |table|
        if ENV[IMPORT_RESUME_AT_ENV_KEY] == clean_table_name(table)
          info("Deleting #{clean_table_name(table)}")
          run_sql_batch("DELETE FROM #{table}")
          ENV[IMPORT_RESUME_AT_ENV_KEY] = nil
        end
        unless partial_import_completed?
          db.pre_table_import(imp, table)
          perform_import(imp.database, module_name, table, imp.dir)
          db.post_table_import(imp, table)
        end
      end

      if ENV[IMPORT_RESUME_AT_ENV_KEY].nil?
        db.post_data_module_import(imp, module_name)
      end
    end

    def create_module(database, module_name, mode)
      schema_name = database.repository.schema_name_for_module(module_name)
      db.create_schema(schema_name) if :up == mode
      process_module(database, module_name, mode)
    end

    def perform_create_action(database, mode)
      database.repository.modules.each do |module_name|
        create_module(database, module_name, mode)
      end
    end

    def collect_resources(database, dir)
      index_name = cleanup_resource_name("#{dir}/#{Dbt::Config.index_file_name}")
      return [] unless resource_present?(database, index_name)
      load_resource(database, index_name).split("\n").collect { |l| cleanup_resource_name("#{dir}/#{l.strip}") }
    end

    def cleanup_resource_name(value)
      value.gsub(/\/\.\//, '/')
    end

    def collect_files(database, relative_dir, extension = 'sql')
      directories = database.dirs_for_database(relative_dir)

      index = []
      files = []

      directories.each do |dir|
        index_file = File.join(dir, Dbt::Config.index_file_name)
        index_entries =
          File.exist?(index_file) ? File.new(index_file).readlines.collect { |filename| filename.strip } : []
        index_entries.each do |e|
          exists = false
          directories.each do |d|
            if File.exist?(File.join(d, e))
              exists = true
              break
            end
          end
          raise "A specified index entry does not exist on the disk #{e}" unless exists
        end

        index += index_entries

        if File.exist?(dir)
          files += Dir["#{dir}/*.#{extension}"]
        end
      end

      prefix = relative_dir.gsub("/./","").gsub(/\/\.$/,"")
      matcher = /^#{prefix}\/[^\/]*\.#{extension}$/
      index_filename = "#{prefix}#{Dbt::Config.index_file_name}"
      database.post_db_artifacts.each do |artifact|
        pkg = Dbt.cache.package(artifact)
        if pkg.files.include?(index_filename)
          content = pkg.contents(index_filename)
          index += content.readlines.collect { |filename| filename.strip }
        end
        file_additions = pkg.files.select { |f| f =~ matcher }.collect { |f| "zip:#{artifact}:#{f}" }
        file_additions.each do |f|
          b = File.basename(f)
          unless files.any? {|other| b == File.basename(other)}
            files << f
          end
        end
      end
      database.pre_db_artifacts.each do |artifact|
        pkg = Dbt.cache.package(artifact)
        if pkg.files.include?(index_filename)
          content = pkg.contents(index_filename)
          index += content.split.collect { |filename| filename.strip }
        end
        file_additions = pkg.files.select { |f| f =~ matcher }.collect { |f| "zip:#{artifact}:#{f}" }
        file_additions.each do |f|
          b = File.basename(f)
          unless files.any? {|other| b == File.basename(other)}
            files << f
          end
        end
      end

      file_map = {}

      files.each do |filename|
        basename = File.basename(filename)
        file_map[basename] = (file_map[basename] || []) + [filename]
      end
      duplicates = file_map.reject { |basename, filenames| filenames.size == 1 }.values

      unless duplicates.empty?
        raise "Files with duplicate basename not allowed.\n\t#{duplicates.collect { |filenames| filenames.join("\n\t") }.join("\n\t")}"
      end

      files.sort! do |x, y|
        x_basename = File.basename(x)
        y_basename = File.basename(y)
        x_index = index.index(x_basename)
        y_index = index.index(y_basename)
        if x_index.nil? && y_index.nil?
          x_basename <=> y_basename
        elsif x_index.nil? && !y_index.nil?
          1
        elsif y_index.nil? && !x_index.nil?
          -1
        else
          x_index <=> y_index
        end
      end

      files
    end

    def perform_import_action(imp, should_perform_delete, module_group)
      if module_group.nil?
        imp.pre_import_dirs.each do |dir|
          process_dir_set(imp.database, dir, true, "#{'%-15s' % ''}: #{dir_display_name(dir)}")
        end unless partial_import_completed?
      end
      imp.modules.each do |module_key|
        if module_group.nil? || module_group.modules.include?(module_key)
          import(imp, module_key, should_perform_delete)
        end
      end
      if partial_import_completed?
        raise "Partial import unable to be completed as bad table name supplied #{ENV[IMPORT_RESUME_AT_ENV_KEY]}"
      end
      if module_group.nil?
        imp.post_import_dirs.each do |dir|
          process_dir_set(imp.database, dir, true, "#{'%-15s' % ''}: #{dir_display_name(dir)}")
        end
      end
      db.post_database_import(imp)
    end

    def collect_dir_set(database, dir)
      if database.load_from_classloader?
        collect_resources(database, dir)
      else
        collect_files(database, dir)
      end
    end

    def process_dir_set(database, dir, is_import, label)
      run_sql_files(database, label, collect_dir_set( database, dir ), is_import)
    end

    def perform_package_database_data(database, package_dir)
      FileUtils.mkdir_p package_dir

      import_dirs = database.imports.values.collect { |i| i.dir }.sort.uniq
      dataset_dirs = database.datasets.collect { |dataset| "#{database.datasets_dir_name}/#{dataset}" }
      dirs = database.up_dirs + database.down_dirs + database.finalize_dirs + [database.fixture_dir_name] + import_dirs + dataset_dirs
      database.repository.modules.each do |module_name|
        dirs.each do |relative_dir_name|
          relative_module_dir = "#{module_name}/#{relative_dir_name}"
          target_dir = "#{package_dir}/#{module_name}/#{relative_dir_name}"

          is_fixture_style_dir =
            database.fixture_dir_name == relative_dir_name || dataset_dirs.include?(relative_dir_name)
          is_import_dir = import_dirs.include?(relative_dir_name)

          if is_fixture_style_dir
            files = collect_files(database, relative_module_dir, 'yml')
            tables = database.repository.table_ordering(module_name).collect{|table_name| clean_table_name(table_name)}
            files.delete_if {|fixture| !tables.include?(File.basename(fixture,'.yml'))}
            cp_files_to_dir(files, target_dir)
          elsif is_import_dir
            files = collect_files(database, relative_module_dir, 'yml') + collect_files(database, relative_module_dir, 'sql')
            tables = database.repository.table_ordering(module_name).collect{|table_name| clean_table_name(table_name)}
            files.delete_if do |fixture|
              !(tables.include?(File.basename(fixture, '.yml')) ||
                tables.include?(File.basename(fixture, '.sql')))
            end
            cp_files_to_dir(files, target_dir)
          else
            files = collect_files(database, relative_module_dir)
            cp_files_to_dir(files, target_dir)
            generate_index(target_dir, files)
          end
        end
      end
      create_hooks = [database.pre_create_dirs, database.post_create_dirs]
      import_hooks = database.imports.values.collect { |i| [i.pre_import_dirs, i.post_import_dirs] }
      database_wide_dirs = create_hooks + import_hooks
      database_wide_dirs.flatten.compact.each do |relative_dir_name|
        target_dir = "#{package_dir}/#{relative_dir_name}"
        files = collect_files(database, relative_dir_name)
        cp_files_to_dir(files, target_dir)
        generate_index(target_dir, files)
      end
      File.open("#{package_dir}/#{Dbt::Config.repository_config_file}","w") do |f|
        f.write database.repository.to_yaml
      end
      if database.enable_migrations?
        target_dir = "#{package_dir}/#{database.migrations_dir_name}"
        files = collect_files(database, database.migrations_dir_name)
        cp_files_to_dir(files, target_dir)
        generate_index(target_dir, files)
      end
    end

    def cp_files_to_dir(files, target_dir)
      return if files.empty?
      FileUtils.mkdir_p target_dir
      FileUtils.cp_r files.select{|f| !(f =~ /^zip:/)}, target_dir
      files.select{|f| (f =~ /^zip:/)}.each do |f|
        parts = f.split(':')
        File.open("#{target_dir}/#{File.basename(parts[2])}","w") do |out|
          out.write Dbt.cache.package(parts[1]).contents(parts[2])
        end
      end
    end

    def generate_index(target_dir, files)
      unless files.empty?
        File.open("#{target_dir}/#{Dbt::Config.index_file_name}", "w") do |index_file|
          index_file.write files.collect { |f| File.basename(f) }.join("\n")
        end
      end
    end

    def dir_display_name(dir)
      (dir == '.' ? '' : "#{dir}/")
    end

    def run_import_sql(database, table, sql, script_file_name = nil, print_dot = false)
      sql = filter_sql(sql, database.expanded_filters)
      sql = sql.gsub(/@@TABLE@@/, table) if table
      sql = filter_database_name(sql, /@@SOURCE@@/, database.key, "import")
      sql = filter_database_name(sql, /@@TARGET@@/, database.key, Dbt::Config.environment)
      run_sql_batch(sql, script_file_name, print_dot, true)
    end

    def generate_standard_import_sql(table)
      sql = "INSERT INTO @@TARGET@@.#{table}("
      columns = db.column_names_for_table(table)
      sql += columns.join(', ')
      sql += ")\n  SELECT "
      sql += columns.join(', ')
      sql += " FROM @@SOURCE@@.#{table}\n"
      sql
    end

    def perform_standard_import(database, table)
      run_import_sql(database, table, generate_standard_import_sql(table))
    end

    def perform_import(database, module_name, table, import_dir)
      fixture_file = try_find_file_in_module(database, module_name, import_dir, table, 'yml')
      sql_file = try_find_file_in_module(database, module_name, import_dir, table, 'sql')

      info("#{'%-15s' % module_name}: Importing #{clean_table_name(table)} (By #{fixture_file ? 'F' : sql_file ? 'S' : "D"})")
      begin
        if fixture_file && sql_file
          raise "Unexpectedly found both import fixture (#{fixture_file}) and import sql (#{sql_file}) files."
        end

        if fixture_file
          load_fixture(table, load_data(database, fixture_file))
        elsif sql_file
          run_import_sql(database, table, load_data(database, sql_file), sql_file, true)
        else
          perform_standard_import(database, table)
        end
      rescue Exception => e

        heading = "Problem importing #{clean_table_name(table)}."
        puts "\n#{'#' * heading.length}\n#{heading}\n#{'#' * heading.length}\n\n" +
               "Fix the problem and retry import specifying IMPORT_RESUME_AT=#{clean_table_name(table)} " +
               "on the commandline to re-attempt import from current position.\n\n"
        raise e
      end
    end

    def setup_connection(database_key, open_control_database, &block)
      db.open(configuration_for_key(config_key(database_key)), open_control_database)
      if block_given?
        begin
          yield
        ensure
          db.close
        end
      end
    end

    def process_module(database, module_name, mode)
      dirs = mode == :up ? database.up_dirs : mode == :down ? database.down_dirs : database.finalize_dirs
      dirs.each do |dir|
        process_dir_set(database, "#{module_name}/#{dir}", false, "#{'%-15s' % module_name}: #{dir_display_name(dir)}")
      end
      load_fixtures(database, module_name) if mode == :up
    end

    def load_fixtures(database, module_name)
      load_fixtures_from_dirs(database, module_name, database.fixture_dir_name)
    end

    def db
      @db ||= Dbt::Config.driver_class.new
    end

    def down_fixtures(database, module_name, fixtures)
      database.repository.table_ordering(module_name).reverse.select {|table_name| !!fixtures[table_name] }.each do |table_name|
        run_sql_batch("DELETE FROM #{table_name}")
      end
    end

    def up_fixtures(database, module_name, fixtures)
      database.repository.table_ordering(module_name).each do |table_name|
        filename = fixtures[table_name]
        next unless filename
        info("#{'%-15s' % 'Fixture'}: #{clean_table_name(table_name)}")
        load_fixture(table_name, load_data(database, filename))
      end
    end

    def load_fixtures_from_dirs(database, module_name, subdir)
      fixtures = {}
      collect_fixtures_from_dirs(database, module_name, subdir, fixtures)

      down_fixtures(database, module_name, fixtures)
      up_fixtures(database, module_name, fixtures)
    end

    def collect_fixtures_from_dirs(database, module_name, subdir, fixtures)
      unless database.load_from_classloader?
        dirs = database.search_dirs.map { |d| "#{d}/#{module_name}#{ subdir ? "/#{subdir}" : ''}" }
        filesystem_files = dirs.collect { |d| Dir["#{d}/*.yml"] }.flatten.compact
        filesystem_sql_files = dirs.collect { |d| Dir["#{d}/*.sql"] }.flatten.compact
      end
      database.repository.table_ordering(module_name).each do |table_name|
        if database.load_from_classloader?
          filename = module_filename(module_name, subdir, table_name, 'yml')
          if resource_present?(database, filename)
            fixtures[table_name] = filename
          end
        else
          dirs.each do |dir|
            filename = table_name_to_fixture_filename(dir, table_name)
            filesystem_files.delete(filename)
            if File.exist?(filename)
              raise "Duplicate fixture for #{table_name} found in database search paths" if fixtures[table_name]
              fixtures[table_name] = filename
            end
          end
          filename = module_filename(module_name, subdir, table_name, 'yml')
          database.post_db_artifacts.each do |artifact|
            if Dbt.cache.package(artifact).files.include?(filename)
              fixtures[table_name] = "zip:#{artifact}:#{filename}"
            end
          end unless fixtures[table_name]
          database.pre_db_artifacts.each do |artifact|
            if Dbt.cache.package(artifact).files.include?(filename)
              fixtures[table_name] = "zip:#{artifact}:#{filename}"
            end
          end unless fixtures[table_name]
        end
      end

      if !database.load_from_classloader? && !filesystem_files.empty?
        raise "Unexpected fixtures found in database search paths. Fixtures do not match existing tables. Files: #{filesystem_files.inspect}"
      end

      if !database.load_from_classloader? && !filesystem_sql_files.empty?
        raise "Unexpected sql files found in fixture directories. SQL files are not processed. Files: #{filesystem_sql_files.inspect}"
      end

      fixtures
    end

    def table_name_to_fixture_filename(dir, table_name)
      "#{dir}/#{clean_table_name(table_name)}.yml"
    end

    def clean_table_name(table_name)
      table_name.tr('[]"' '', '')
    end

    def load_fixture(table_name, content)
      require 'erb'
      require 'yaml'
      yaml = YAML::load(ERB.new(content).result)
      # Skip empty files
      return unless yaml
      # NFI
      yaml_value =
        if yaml.respond_to?(:type_id) && yaml.respond_to?(:value)
          yaml.value
        else
          [yaml]
        end
      db.pre_fixture_import(table_name)
      yaml_value.each do |fixture|
        raise "Bad data for #{table_name} fixture named #{fixture}" unless fixture.respond_to?(:each)
        fixture.each do |name, data|
          raise "Bad data for #{table_name} fixture named #{name} (nil)" unless data
          db.insert(table_name, data)
        end
        db.post_fixture_import(table_name)
      end
    end

    def run_filtered_sql_batch(database, sql, script_file_name = nil)
      sql = filter_sql(sql, database.expanded_filters)
      run_sql_batch(sql, script_file_name)
    end

    def filter_sql(sql, filters)
      filters.each do |filter|
        sql = filter.call(sql)
      end
      sql
    end

    def run_sql_files(database, label, files, is_import)
      files.each do |filename|
        run_sql_file(database, label, filename, is_import)
      end
    end

    def load_data(database, filename)
      if database.load_from_classloader?
        load_resource(database, filename)
      else
        match = /^zip:(.+):([^:]+)$/.match(filename)
        if match
          Dbt.cache.package(match[1]).contents(match[2])
        else
          IO.readlines(filename).join
        end
      end
    end

    def run_sql_file(database, label, filename, is_import)
      info("#{label}#{File.basename(filename)}")
      sql = load_data(database, filename)
      if is_import
        run_import_sql(database, nil, sql, filename)
      else
        run_filtered_sql_batch(database, sql, filename)
      end
    end

    def load_resource(database, resource_path)
      require 'java'
      stream = java.lang.ClassLoader.getSystemResourceAsStream("#{database.resource_prefix}/#{resource_path}")
      raise "Missing resource #{resource_path}" unless stream
      content = ""
      while stream.available() > 0
        content << stream.read()
      end
      content
    end

    def run_sql_batch(sql, script_file_name = nil, print_dot = false, execute_in_control_database = false)
      sql.gsub(/\r/, '').split(/(\s|^)GO(\s|$)/).reject { |q| q.strip.empty? }.each_with_index do |ddl, index|
        $stdout.putc '.' if print_dot
        begin
          db.execute(ddl, execute_in_control_database)
        rescue
          if script_file_name.nil? || index.nil?
            raise $!
          else
            raise "An error occurred while trying to execute batch ##{index + 1} of #{File.basename(script_file_name)}:\n#{$!}"
          end
        end
      end
      $stdout.putc "\n" if print_dot
    end

    def module_filename(module_name, subdir, table, extension)
      "#{module_name}/#{subdir}/#{clean_table_name(table)}.#{extension}"
    end

    def resource_present?(database, resource_path)
      require 'java'
      !!java.lang.ClassLoader.getSystemResourceAsStream("#{database.resource_prefix}/#{resource_path}")
    end

    def try_find_file_in_module(database, module_name, subdir, table, extension)
      filename = module_filename(module_name, subdir, table, extension)
      if database.load_from_classloader?
        resource_present?(database, filename) ? filename : nil
      else
        filename = module_filename(module_name, subdir, table, extension)
        database.search_dirs.map do |d|
          file = "#{d}/#{filename}"
          return file if File.exist?(file)
        end
        database.post_db_artifacts.each do |artifact|
          return "zip:#{artifact}:#{filename}" if Dbt.cache.package(artifact).files.include?(filename)
        end
        database.pre_db_artifacts.each do |artifact|
          return "zip:#{artifact}:#{filename}" if Dbt.cache.package(artifact).files.include?(filename)
        end
        return nil
      end
    end

    def hash_files(database, files)
      intermediate = ''
      files.each do |path|
        intermediate << "#{path} : #{Digest::MD5.hexdigest(load_data(database,path))}\n"
      end
      Digest::MD5.hexdigest(intermediate)
    end

    def collect_fileset_for_hash(database)
      files = []

      database.pre_create_dirs.each do |dir|
        files << collect_dir_set(database, dir)
      end

      database.repository.modules.each do |module_name|
        [database.up_dirs, database.down_dirs, database.finalize_dirs].each do |dirs|
          dirs.each do |dir|
            files << collect_dir_set(database, "#{module_name}/#{dir}")
          end
        end
        fixtures = {}
        collect_fixtures_from_dirs(database, module_name, database.fixture_dir_name, fixtures)
        database.repository.table_ordering(module_name).each do |table_name|
          files << fixtures[table_name] if fixtures[table_name]
        end
      end

      database.imports.values.each do |imp|
        imp.pre_import_dirs.each do |dir|
          files << collect_dir_set(database, dir)
        end
        imp.modules.each do |module_name|
          tables = database.repository.table_ordering(module_name)
          tables.each do |table|
            files << try_find_file_in_module(database, module_name, imp.dir, table, 'yml')
            files << try_find_file_in_module(database, module_name, imp.dir, table, 'sql')
          end
        end
        imp.post_import_dirs.each do |dir|
          files << collect_dir_set(database, dir)
        end
      end

      database.post_create_dirs.each do |dir|
        files << collect_dir_set(database, dir)
      end

      if database.enable_migrations?
        files << collect_dir_set(database, database.migrations_dir_name)
      end

      files.flatten!.select{|x| !x.nil?}
    end
  end
end
