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

  class ModuleGroupDefinition < DatabaseElement

    def initialize(database, key, options, &block)
      @modules = @import_enabled = nil
      super(database, key, options, &block)
    end

    attr_writer :modules

    def modules
      raise "Missing modules configuration for module_group #{key}" unless @modules
      @modules
    end

    attr_writer :import_enabled

    def import_enabled?
      @import_enabled.nil? ? false : @import_enabled
    end

    def validate
      self.modules.each do |module_key|
        unless database.modules.include?(module_key.to_s)
          raise "Module #{module_key} in module group #{self.key} does not exist in database module list #{self.database.modules.inspect}"
        end
      end
    end
  end
end
