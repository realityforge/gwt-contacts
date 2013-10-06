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

  def self.define_database_package(database_key, buildr_project, options = {})
    database = self.repository.database_for_key(database_key)
    package_dir = buildr_project._(:target, 'dbt')
    jruby_version = options[:jruby_version] || (defined?(JRUBY_VERSION) ? JRUBY_VERSION : '1.7.2')

    task "#{database.task_prefix}:package" => ["#{database.task_prefix}:prepare_fs"] do
      banner("Packaging Database Scripts", database.key)
      params = options.dup
      params[:jruby_version] = jruby_version
      package_database(database, package_dir, params)
    end
    buildr_project.file("#{package_dir}/code" => "#{database.task_prefix}:package")
    buildr_project.file("#{package_dir}/data" => "#{database.task_prefix}:package")
    jar = buildr_project.package(:jar) do |j|
    end
    dependencies =
      ["org.jruby:jruby-complete:jar:#{jruby_version}"] +
        Dbt::Config.driver_config_class(:jruby => true).jdbc_driver_dependencies

    dependencies.each do |spec|
      jar.merge(Buildr.artifact(spec))
    end
    jar.include "#{package_dir}/code", :as => '.'
    jar.include "#{package_dir}/data"
    jar.with :manifest => buildr_project.manifest.merge('Main-Class' => 'org.realityforge.dbt.dbtcli')
  end

  private

  def self.execute_command(database, command)
    if "status" == command
      puts @@runtime.status(database)
    elsif "create" == command
      @@runtime.create(database)
    elsif "drop" == command
      @@runtime.drop(database)
    elsif "migrate" == command
      @@runtime.migrate(database)
    elsif "restore" == command
      @@runtime.restore(database)
    elsif "backup" == command
      @@runtime.backup(database)
    elsif /^datasets:/ =~ command
      dataset_name = command[9, command.length]
      @@runtime.load_dataset(database, dataset_name)
    elsif /^import/ =~ command
      import_key = command[7, command.length]
      import_key = Dbt::Config.default_import.to_s if import_key.nil?
      database.imports.values.each do |imp|
        if imp.key.to_s == import_key
          @@runtime.database_import(imp, nil)
          return
        end
      end
      raise "Unknown import '#{import_key}'"
    elsif /^create_by_import/ =~ command
      import_key = command[17, command.length]
      import_key = Dbt::Config.default_import.to_s if import_key.nil?
      database.imports.values.each do |imp|
        if imp.key.to_s == import_key
          @@runtime.create_by_import(imp)
          return
        end
      end
      raise "Unknown import '#{import_key}'"
    else
      raise "Unknown command '#{command}'"
    end
  end

  def self.package_database(database, package_dir, options)
    rm_rf package_dir
    package_database_code(database, "#{package_dir}/code", options)
    self.runtime.package_database_data(database, "#{package_dir}/data")
  end

  def self.package_database_code(database, package_dir, options)
    FileUtils.mkdir_p package_dir
    valid_commands = ["status", "create", "drop"]
    valid_commands << "restore" if database.restore?
    valid_commands << "backup" if database.backup?
    if database.enable_separate_import_task?
      database.imports.values.each do |imp|
        command = "import"
        command = "#{command}:#{imp.key}" unless Dbt::Config.default_import?(imp.key)
        valid_commands << command
      end
    end
    if database.enable_import_task_as_part_of_create?
      database.imports.values.each do |imp|
        command = "create_by_import"
        command = "#{command}:#{imp.key}" unless Dbt::Config.default_import?(imp.key)
        valid_commands << command
      end
    end
    database.datasets.each do |dataset|
      valid_commands << "datasets:#{dataset}"
    end

    valid_commands << "migrate" if database.enable_migrations?

    FileUtils.mkdir_p "#{package_dir}/org/realityforge/dbt"
    File.open("#{package_dir}/org/realityforge/dbt/dbtcli.rb", "w") do |f|
      f << <<TXT
require 'dbt'
require 'optparse'
require 'java'

Dbt::Config.driver = '#{Dbt::Config.driver}'
Dbt::Config.environment = 'production'
Dbt::Config.config_filename = 'config/database.yml'
VALID_COMMANDS=#{valid_commands.inspect}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: dbtcli [OPTIONS] [COMMANDS]"
  opt.separator  ""
  opt.separator  "Commands: #{valid_commands.join(', ')}"
  opt.separator  ""
  opt.separator  "Options"

  opt.on("-e","--environment ENV","the database environment to use. Defaults to 'production'.") do |environment|
    Dbt::Config.environment = environment
  end

  opt.on("-c","--config-file CONFIG","the configuration file to use. Defaults to 'config/database.yml'.") do |config_filename|
    Dbt::Config.config_filename = config_filename
  end

  opt.on("-h","--help","help") do
    puts opt_parser
    java.lang.System.exit(53)
  end
end

begin
  opt_parser.parse!
rescue => e
  puts "Error: \#{e.message}"
  java.lang.System.exit(53)
end

ARGV.each do |command|
  unless VALID_COMMANDS.include?(command) || /^datasets:/ =~ command
    puts "Unknown command: \#{command}"
    java.lang.System.exit(42)
  end
end

if ARGV.length == 0
  puts "No command specified"
  java.lang.System.exit(31)
end

database = Dbt.add_database(:#{database.key}) do |database|
  database.resource_prefix = "data"
  database.fixture_dir_name = "#{database.fixture_dir_name}"
  database.datasets_dir_name = "#{database.datasets_dir_name}"
  database.migrations_dir_name = "#{database.migrations_dir_name}"
  database.up_dirs = %w(#{database.up_dirs.join(' ')})
  database.down_dirs = %w(#{database.down_dirs.join(' ')})
  database.finalize_dirs = %w(#{database.finalize_dirs.join(' ')})
  database.pre_create_dirs = %w(#{database.pre_create_dirs.join(' ')})
  database.post_create_dirs = %w(#{database.post_create_dirs.join(' ')})
  database.datasets = %w(#{database.datasets.join(' ')})
  database.import_assert_filters = #{database.import_assert_filters?}
  database.database_environment_filter = #{database.database_environment_filter?}
  database.rake_integration = false
  database.migrations = #{database.enable_migrations?}
  database.version = #{database.version.inspect}
TXT

      database.filters.each do |filter|
        if filter.is_a?(PropertyFilter)
          f << "  database.add_property_filter(#{filter.pattern.inspect}, #{filter.value.inspect})\n"
        elsif filter.is_a?(DatabaseNameFilter)
          f << "  database.add_database_name_filter(#{filter.pattern.inspect}, #{filter.database_key.inspect}, #{filter.optional.inspect})\n"
        else
          raise "Unsupported filter #{filter}"
        end
      end

      database.imports.each_pair do |import_key, definition|
        import_config = {
          :modules => definition.modules,
          :dir => definition.dir,
          :reindex => definition.reindex?,
          :shrink => definition.shrink?,
          :pre_import_dirs => definition.pre_import_dirs,
          :post_import_dirs => definition.post_import_dirs
        }
        f << "  database.add_import(:#{import_key}, #{import_config.inspect})\n"
      end

      f << <<TXT
end

puts "Environment: \#{Dbt::Config.environment}"
puts "Config File: \#{Dbt::Config.config_filename}"
puts "Commands: \#{ARGV.join(' ')}"

Dbt.repository.load_configuration_data(Dbt::Config.config_filename)
Dbt.runtime.load_database_config(database)

ARGV.each do |command|
  Dbt.execute_command(database, command)
end
TXT
    end
    jruby_version = options[:jruby_version] || (defined?(JRUBY_VERSION) ? JRUBY_VERSION : '1.7.2')
    prefix = jruby_version ? "RBENV_VERSION=jruby-#{options[:jruby_version]} RUBYOPT= rbenv exec " : ''
    sh "#{prefix}jrubyc --dir #{::Buildr::Util.relative_path(package_dir, Dir.pwd)} #{::Buildr::Util.relative_path(package_dir, Dir.pwd)}"
    FileUtils.cp_r Dir.glob("#{File.expand_path(File.dirname(__FILE__) + '/..')}/*"), package_dir
  end
end
