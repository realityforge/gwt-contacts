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

  class Repository

    def initialize
      @databases = {}
      @configurations = {}
      @configuration_data = {}
    end

    def database_keys
      @databases.keys
    end

    def database_for_key(database_key)
      database = @databases[database_key]
      raise "Missing database for key #{database_key}" unless database
      database
    end

    def add_database(database_key, options = {}, &block)
      raise "Database with key #{database_key} already defined." if @databases.has_key?(database_key)

      database = DatabaseDefinition.new(database_key, options, &block)
      @databases[database_key] = database

      database
    end

    def remove_database(database_key)
      raise "Database with key #{database_key} not defined." unless @databases.has_key?(database_key)
      @databases.delete(database_key)
    end

    def configuration_for_key?(config_key)
      !!@configuration_data[config_key.to_s]
    end

    def configuration_keys
      @configuration_data.keys
    end

    def configuration_for_key(config_key)
      existing = @configurations[config_key.to_s]
      return existing if existing
      c = @configuration_data[config_key.to_s]
      raise "Missing config for #{config_key}" unless c
      configuration = Dbt::Config.driver_config_class.new(config_key, c)
      @configurations[config_key.to_s] = configuration
    end

    def is_configuration_data_loaded?
      !@configuration_data.empty?
    end

    def load_configuration_data(filename = Dbt::Config.config_filename)
      require 'yaml'
      require 'erb'
      self.configuration_data = YAML::load(ERB.new(IO.read(filename)).result)
    end

    def configuration_data=(configuration_data)
      @configurations = {}
      @configuration_data = configuration_data.nil? ? {} : configuration_data
    end
  end
end
