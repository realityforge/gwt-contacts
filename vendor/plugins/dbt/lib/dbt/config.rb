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

class Dbt # nodoc

  # Class used to statically configure the Dbt library
  class Config

    @default_datasets_dir_name = nil
    @repository_config_file = nil
    @default_up_dirs = nil
    @default_down_dirs = nil
    @default_finalize_dirs = nil
    @default_pre_create_dirs = nil
    @default_post_create_dirs = nil
    @default_pre_import_dirs = nil
    @default_post_import_dirs = nil
    @index_file_name = nil
    @default_import = nil
    @default_fixture_dir_name = nil
    @environment = nil
    @driver = nil
    @default_migrations_dir_name = nil
    @default_database = nil
    @task_prefix = nil
    @default_import_dir = nil

    class << self
      attr_writer :environment

      def environment
        @environment || 'development'
      end

      attr_writer :task_prefix

      def task_prefix
        @task_prefix || 'dbt'
      end

      attr_writer :driver

      def driver=(driver)
        valid_drivers = ['sql_server', 'postgres']
        raise "Unknown driver specified '#{driver}'. Valid drivers include: #{valid_drivers.inspect}" if driver && !valid_drivers.include?(driver)
        @driver = driver
      end

      def driver
        @driver || 'sql_server'
      end

      def driver_class
        d = driver
        is_jruby = defined?(JRUBY_VERSION)

        if d == 'sql_server'
          is_jruby ? Dbt::MssqlDbDriver : Dbt::TinyTdsDbDriver
        else #d == 'postgres'
          is_jruby ? Dbt::PostgresDbDriver : Dbt::PgDbDriver
        end
      end

      def driver_config_class(options = {})
        d = options[:driver] || driver
        is_jruby = options[:jruby].nil? ? defined?(JRUBY_VERSION) : options[:jruby]

        if d == 'sql_server'
          is_jruby ? Dbt::MssqlDbConfig : Dbt::TinyTdsDbConfig
        else #d == 'postgres'
          is_jruby ? Dbt::PostgresDbConfig : Dbt::PgDbConfig
        end
      end

      attr_writer :default_no_create

      def default_no_create?
        @default_no_create.nil? ? false : @default_no_create
      end

      attr_writer :default_database

      def default_database
        @default_database || :default
      end

      def default_database?(database_key)
        database_key.to_s == default_database.to_s
      end

      attr_writer :default_import

      def default_import
        @default_import || :default
      end

      attr_writer :default_import_dir

      def default_import_dir
        @default_import_dir || 'import'
      end

      def default_import?(import_key)
        import_key.to_s == default_import.to_s
      end

      # config_file is where the yaml config file is located
      attr_writer :config_filename

      def config_filename
        raise "config_filename not specified" unless @config_filename
        @config_filename
      end

      # search_dirs is an array of paths that are searched in order for artifacts for each module
      attr_writer :default_search_dirs

      def default_search_dirs
        raise "default_search_dirs not specified" unless @default_search_dirs
        @default_search_dirs
      end

      attr_writer :default_up_dirs

      def default_up_dirs
        @default_up_dirs || ['.', 'types', 'views', 'functions', 'stored-procedures', 'misc']
      end

      attr_writer :default_finalize_dirs

      def default_finalize_dirs
        @default_finalize_dirs || ['triggers', 'finalize']
      end

      attr_writer :default_pre_import_dirs

      def default_pre_import_dirs
        @default_pre_import_dirs || ['import-hooks/pre']
      end

      attr_writer :default_post_import_dirs

      def default_post_import_dirs
        @default_post_import_dirs || ['import-hooks/post']
      end

      attr_writer :default_pre_create_dirs

      def default_pre_create_dirs
        @default_pre_create_dirs || ['db-hooks/pre']
      end

      attr_writer :default_post_create_dirs

      def default_post_create_dirs
        @default_post_create_dirs || ['db-hooks/post']
      end

      attr_writer :default_down_dirs

      def default_down_dirs
        @default_down_dirs || ['down']
      end

      attr_writer :index_file_name

      def index_file_name
        @index_file_name || 'index.txt'
      end

      attr_writer :default_fixture_dir_name

      def default_fixture_dir_name
        @default_fixture_dir_name || 'fixtures'
      end

      attr_writer :default_datasets_dir_name

      def default_datasets_dir_name
        @default_datasets_dir_name || 'datasets'
      end

      attr_writer :default_migrations_dir_name

      def default_migrations_dir_name
        @default_migrations_dir_name || 'migrations'
      end

      attr_writer :repository_config_file

      def repository_config_file
        @repository_config_file || 'repository.yml'
      end
    end
  end
end
