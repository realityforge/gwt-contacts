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

  class RepositoryDefinition < ConfigElement
    attr_accessor :schema_overrides, :table_map

    def initialize(options = {}, &block)
      @table_map = {}
      @schema_overrides = {}
      @modules = []
      super(options, &block)
    end

    attr_writer :modules

    # List of modules to process for database
    def modules
      @modules = @modules.call if !@modules.nil? && @modules.is_a?(Proc)
      @modules
    end

    def schema_name_for_module(module_name)
      override = schema_overrides[module_name]
      return override if override
      return module_name if self.modules.include?(module_name)
      raise "Unable to determine schema name for non existent module #{module_name}"
    end

    def table_ordering(module_name)
      tables = table_map[module_name.to_s]
      raise "No tables defined for module #{module_name}" unless tables
      tables
    end

    def merge!(other)
      other.modules.each do |m|
        if self.modules.include?(m)
          raise "Attempting to merge repository that has duplicate module definition #{m} (Existing = #{self.modules.inspect})"
        end
      end
      other.modules.each do |m|
        self.modules.push(m)
      end
      self.schema_overrides.merge!(other.schema_overrides)
      self.table_map.merge!(other.table_map)
      self
    end

    def from_yaml(content)
      require 'yaml'
      repository_config = YAML::load(content)
      modules = repository_config['modules'].nil? ? [] : repository_config['modules'].keys
      schema_overrides = {}
      table_map = {}
      repository_config['modules'].each do |module_config|
        name = module_config[0]
        schema = module_config[1]['schema']
        tables = module_config[1]['tables']
        table_map[name] = tables
        schema_overrides[name] = schema if name != schema
      end if repository_config['modules']

      self.modules = modules
      self.schema_overrides = schema_overrides
      self.table_map = table_map
      self
    end

    def to_yaml
      modules = YAML::Omap.new
      self.modules.each do |module_name|
        module_config = {}
        module_config['schema'] = self.schema_name_for_module(module_name)
        module_config['tables'] = self.table_ordering(module_name)
        modules[module_name.to_s] = module_config
      end
      {'modules' => modules}.to_yaml
    end
  end
end
