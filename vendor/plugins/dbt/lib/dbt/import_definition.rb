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

  # Configuration class describing a database import activity
  class ImportDefinition < DatabaseElement
    include FilterContainer

    # TODO: Add per-import configurations that defines whether import should be
    # included as part of create or standalone or both

    def initialize(database, key, options, &block)
      @modules = @dir = @reindex = @shrink = @pre_import_dirs = @post_import_dirs =
        @database_environment_filter = @import_assert_filters = nil
      super(database, key, options, &block)
    end

    attr_writer :modules

    def modules
      @modules || database.modules
    end

    attr_writer :dir

    def dir
      @dir || Dbt::Config.default_import_dir
    end

    # TODO: Move to specific DbConfig
    attr_writer :reindex

    def reindex?
      @reindex.nil? ? true : @reindex
    end

    # TODO: Move to specific DbConfig
    attr_writer :shrink

    def shrink?
      @shrink.nil? ? false : @shrink
    end

    attr_writer :pre_import_dirs

    def pre_import_dirs
      @pre_import_dirs || Dbt::Config.default_pre_import_dirs
    end

    attr_writer :post_import_dirs

    def post_import_dirs
      @post_import_dirs || Dbt::Config.default_post_import_dirs
    end

    def validate
      self.modules.each do |module_key|
        if !database.modules.include?(module_key.to_s)
          raise "Module #{module_key} in import #{self.key} does not exist in database module list #{self.database.modules.inspect}"
        end
      end
    end
  end
end
