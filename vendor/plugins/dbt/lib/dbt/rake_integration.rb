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

class Dbt #nodoc

  @@defined_init_tasks = false

  class DatabaseDefinition #nodoc

    # Enable domgen support. Assume the database is associated with a single repository
    # definition, a single task to generate sql etc.
    def enable_domgen(repository_key, load_task_name, generate_task_name)
      task "#{task_prefix}:load_config" => load_task_name
      task "#{task_prefix}:pre_build" => generate_task_name

      desc "Verify constraints on database."
      task "#{task_prefix}:verify_constraints" => ["#{task_prefix}:load_config"] do
        Dbt.banner("Verifying database", key)
        failed_constraints = []

        Domgen.repository_by_name(repository_key).data_modules.select { |data_module| data_module.sql? }.each do |data_module|
          failed_constraints += Dbt.runtime.query(self, "EXEC #{data_module.sql.schema}.spCheckConstraints")
        end
        if failed_constraints.size > 0
          error_message = "Failed Constraints:\n#{failed_constraints.collect do |row|
            "\t#{row['ConstraintName']} on #{row['SchemaName']}.#{row['TableName']}"
          end.join("\n")}"
          raise error_message
        end
        Dbt.banner("Database verified", key)
      end
    end

    # Enable db doc support. Assume that all the directories in up/down will have documentation and
    # will generate relative to specified directory.
    def enable_db_doc(target_directory)
      task "#{task_prefix}:db_doc"
      task "#{task_prefix}:pre_build" => ["#{task_prefix}:db_doc"]

      (up_dirs + down_dirs).each do |relative_dir_name|
        dirs_for_database(relative_dir_name).each do |dir|
          task "#{task_prefix}:db_doc" => Dbt::DbDoc.define_doc_tasks(dir, "#{target_directory}/#{relative_dir_name}")
        end
      end
    end
  end

  private

  def self.define_tasks_for_database(database)
    self.define_basic_tasks
    task "#{database.task_prefix}:load_config" => ["#{Dbt::Config.task_prefix}:global:load_config"]

    # Database dropping

    desc "Drop the #{database.key} database."
    task "#{database.task_prefix}:drop" => ["#{database.task_prefix}:load_config"] do
      banner('Dropping database', database.key)
      @@runtime.drop(database)
    end

    # Database creation

    task "#{database.task_prefix}:pre_build" => ["#{Dbt::Config.task_prefix}:all:pre_build"]

    task "#{database.task_prefix}:prepare_fs" => ["#{database.task_prefix}:pre_build"] do
      @@runtime.load_database_config(database)
    end

    task "#{database.task_prefix}:prepare" => ["#{database.task_prefix}:load_config", "#{database.task_prefix}:prepare_fs"]

    desc "Create the #{database.key} database."
    task "#{database.task_prefix}:create" => ["#{database.task_prefix}:prepare"] do
      banner('Creating database', database.key)
      @@runtime.create(database)
    end

    # Data set loading etc
    database.datasets.each do |dataset_name|
      desc "Loads #{dataset_name} data"
      task "#{database.task_prefix}:datasets:#{dataset_name}" => ["#{database.task_prefix}:prepare"] do
        banner("Loading Dataset #{dataset_name}", database.key)
        @@runtime.load_dataset(database, dataset_name)
      end
    end

    if database.enable_migrations?
      desc "Apply migrations to bring data to latest version"
      task "#{database.task_prefix}:migrate" => ["#{database.task_prefix}:prepare"] do
        banner("Migrating", database.key)
        @@runtime.migrate(database)
      end
    end

    # Import tasks
    if database.enable_separate_import_task?
      database.imports.values.each do |imp|
        define_import_task("#{database.task_prefix}", imp, "contents")
      end
    end

    database.module_groups.values.each do |module_group|
      define_module_group_tasks(module_group)
    end

    if database.enable_import_task_as_part_of_create?
      database.imports.values.each do |imp|
        key = ""
        key = ":" + imp.key.to_s unless Dbt::Config.default_import?(imp.key)
        desc "Create the #{database.key} database by import."
        task "#{database.task_prefix}:create_by_import#{key}" => ["#{database.task_prefix}:prepare"] do
          banner("Creating Database By Import", database.key)
          @@runtime.create_by_import(imp)
        end
      end
    end

    if database.backup?
      desc "Perform backup of #{database.key} database"
      task "#{database.task_prefix}:backup" => ["#{database.task_prefix}:load_config"] do
        banner("Backing up Database", database.key)
        @@runtime.backup(database)
      end
    end

    if database.restore?
      desc "Perform restore of #{database.key} database"
      task "#{database.task_prefix}:restore" => ["#{database.task_prefix}:load_config"] do
        banner("Restoring Database", database.key)
        @@runtime.restore(database)
      end
    end
  end

  def self.define_module_group_tasks(module_group)
    database = module_group.database
    desc "Up the #{module_group.key} module group in the #{database.key} database."
    task "#{database.task_prefix}:#{module_group.key}:up" => ["#{database.task_prefix}:prepare"] do
      banner("Upping module group '#{module_group.key}'", database.key)
      @@runtime.up_module_group(module_group)
    end

    desc "Down the #{module_group.key} schema group in the #{database.key} database."
    task "#{database.task_prefix}:#{module_group.key}:down" => ["#{database.task_prefix}:prepare"] do
      banner("Downing module group '#{module_group.key}'", database.key)
      @@runtime.down_module_group(module_group)
    end

    database.imports.values.each do |imp|
      import_modules = imp.modules.select { |module_name| module_group.modules.include?(module_name) }
      if module_group.import_enabled? && !import_modules.empty?
        description = "contents of the #{module_group.key} module group"
        define_import_task("#{database.task_prefix}:#{module_group.key}", imp, description, module_group)
      end
    end
  end

  def self.define_import_task(prefix, imp, description, module_group = nil)
    is_default_import = Dbt::Config.default_import?(imp.key)
    desc_prefix = is_default_import ? 'Import' : "#{imp.key.to_s.capitalize} import"

    task_name = is_default_import ? :import : :"import:#{imp.key}"
    desc "#{desc_prefix} #{description} of the #{imp.database.key} database."
    task "#{prefix}:#{task_name}" => ["#{imp.database.task_prefix}:prepare"] do
      banner("Importing Database#{is_default_import ? '' : " (#{imp.key})"}", imp.database.key)
      @@runtime.database_import(imp, module_group)
    end
  end

  def self.define_basic_tasks
    if !@@defined_init_tasks
      task "#{Dbt::Config.task_prefix}:global:load_config" do
        @@repository.load_configuration_data unless @@repository.is_configuration_data_loaded?
      end

      task "#{Dbt::Config.task_prefix}:all:pre_build"

      @@defined_init_tasks = true
    end
  end

  def self.banner(message, database_key)
    @@runtime.info("**** #{message}: (Database: #{database_key}, Environment: #{Dbt::Config.environment}) ****")
  end
end
