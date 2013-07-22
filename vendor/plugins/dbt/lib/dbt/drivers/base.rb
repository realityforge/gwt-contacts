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

  # Abstract class representing database configuration
  class DbConfig < Dbt::ConfigElement
    def catalog_name
      raise NotImplementedError
    end

    def no_create?
      raise NotImplementedError
    end
  end

  # Abstract class representing database driver
  class DbDriver
    def insert(table_name, row)
      raise NotImplementedError
    end

    def execute(sql, execute_in_control_database = false)
      raise NotImplementedError
    end

    def query(sql)
      raise NotImplementedError
    end

    def create_schema(schema_name)
      raise NotImplementedError
    end

    def drop_schema(schema_name, tables)
      raise NotImplementedError
    end

    def column_names_for_table(table)
      raise NotImplementedError
    end

    def open(config, open_control_database)
      raise NotImplementedError
    end

    def close
      raise NotImplementedError
    end

    def create_database(database, configuration)
      raise NotImplementedError
    end

    def drop(database, configuration)
      raise NotImplementedError
    end

    def backup(database, configuration)
      raise NotImplementedError
    end

    def restore(database, configuration)
      raise NotImplementedError
    end

    def setup_migrations
      raise NotImplementedError
    end

    def should_migrate?(namespace, migration_name)
      raise NotImplementedError
    end

    def mark_migration_as_run(namespace, migration_name)
      raise NotImplementedError
    end

    def pre_table_import(imp, table)
      raise NotImplementedError
    end

    def post_table_import(imp, table)
      raise NotImplementedError
    end

    def pre_fixture_import(table)
      raise NotImplementedError
    end

    def post_fixture_import(table)
      raise NotImplementedError
    end

    def post_data_module_import(imp, module_name)
      raise NotImplementedError
    end

    def post_database_import(imp)
      raise NotImplementedError
    end
  end

  class BaseDbDriver < DbDriver
    def insert(table_name, row)
      column_names = row.keys.collect { |column_name| quote_column_name(column_name) }
      value_list = row.values.collect { |value| quote_value(value) }
      execute("INSERT INTO #{table_name} (#{column_names.join(', ')}) VALUES (#{value_list.join(', ')})")
    end

    # Returns a single value from a record
    def select_value(sql)
      result = query(sql)
      return nil unless result
      result = result.first
      return nil unless result
      result.values.first
    end
  end
end
