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
  module PostgresConfig
    def build_jdbc_url(options = {})
      credentials_inline = options[:credentials_inline].nil? ? false : options[:credentials_inline]
      use_control_catalog = options[:use_control_catalog].nil? ? false : options[:use_control_catalog]

      url = "jdbc:postgresql://#{host}:#{port}/"
      url += use_control_catalog ? control_catalog_name : catalog_name
      if credentials_inline
        url += "?user=#{username}&password=#{password}"
      end
      url
    end

    def control_catalog_name
      'postgres'
    end

    def port
      @port || 5432
    end
  end

  module Dialect
    module Postgres

      CONTROL_DATABASE = "postgres"

      def create_schema(schema_name)
        if query("SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '#{schema_name}'").empty?
          execute("CREATE SCHEMA #{quote_table_name(schema_name)}")
        end
      end

      def drop_schema(schema_name, tables)
        execute("DROP SCHEMA #{quote_table_name(schema_name)} CASCADE")
      end

      def create_database(database, configuration)
        execute("CREATE DATABASE #{quote_table_name(configuration.catalog_name)}")
        unless database.version.nil?
          execute("COMMENT ON DATABASE #{quote_table_name(configuration.catalog_name)} IS 'Database Schema Version #{database.version}'")
        end
      end

      def drop(database, configuration)
        execute("DROP DATABASE IF EXISTS #{quote_table_name(configuration.catalog_name)}")
      end

      def backup(database, configuration)
        raise NotImplementedError
      end

      def restore(database, configuration)
        raise NotImplementedError
      end

      def setup_migrations
        if query("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'public' AND TABLE_NAME = 'tblMigration'").empty?
          execute("CREATE TABLE #{quote_table_name('tblMigration')}(#{quote_column_name('Namespace')} varchar(50),#{quote_column_name('Migration')} varchar(255),#{quote_column_name('AppliedAt')} timestamp)")
        end
      end

      def should_migrate?(namespace, migration_name)
        setup_migrations
        query("SELECT * FROM #{quote_table_name('tblMigration')} WHERE #{quote_column_name('Namespace')} = #{quote_value(namespace)} AND #{quote_column_name('Migration')} = #{quote_value(migration_name)}").empty?
      end

      def mark_migration_as_run(namespace, migration_name)
        execute("INSERT INTO #{quote_table_name('tblMigration')}(#{quote_column_name('Namespace')},#{quote_column_name('Migration')},#{quote_column_name('AppliedAt')}) VALUES (#{quote_value(namespace)}, #{quote_value(migration_name)}, current_timestamp)")
      end

      def pre_fixture_import(table)
      end

      def post_fixture_import(table)
      end

      def pre_table_import(imp, table)
      end

      def post_table_import(imp, table)
      end

      def post_data_module_import(imp, module_name)
      end

      def post_database_import(imp)
      end

      protected

      def current_database
        select_value("SELECT current_database()")
      end

      def select_database(database_name)
        if database_name.nil?
          execute('\\connect "postgres"')
        else
          execute("\\connect \"#{database_name}\"")
        end
      end

      def quote_table_name(name)
        "\"#{name}\""
      end

      def quote_column_name(name)
        "\"#{name}\""
      end

      def quote_value(value)
        case value
          when NilClass then
            'NULL'
          when String then
            "'#{value.to_s.gsub(/\'/, "''")}'"
          when TrueClass then
            '1'
          when FalseClass then
            '0'
          else
            value
        end
      end
    end
  end
end
