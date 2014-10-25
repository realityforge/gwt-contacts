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

  class DatabaseDefinition < BaseElement
    include FilterContainer

    def initialize(key, options, &block)
      @repository = RepositoryDefinition.new
      options = options.dup
      imports_config = options.delete(:imports)
      module_groups_config = options.delete(:module_groups)

      @imports = {}
      imports_config.keys.each do |import_key|
        add_import(import_key, imports_config[import_key])
      end if imports_config
      @module_groups = {}
      module_groups_config.keys.each do |module_group_key|
        add_module_group(module_group_key, module_groups_config[module_group_key])
      end if module_groups_config

      @migrations = @backup = @restore = @datasets = @version_hash = @resource_prefix =
        @up_dirs = @down_dirs = @finalize_dirs = @pre_create_dirs = @post_create_dirs =
          @search_dirs = @migrations_dir_name = @migrations_applied_at_create =
            @rake_integration = @separate_import_task = @import_task_as_part_of_create =
              @datasets_dir_name = @fixture_dir_name =
                @database_environment_filter = @import_assert_filters = nil

      @pre_db_artifacts = []
      @post_db_artifacts = []

      super(key, options, &block)
    end

    def add_import(import_key, import_config = {})
      @imports[import_key.to_s] = ImportDefinition.new(self, import_key, import_config)
    end

    def add_module_group(module_group_key, module_group_config)
      @module_groups[module_group_key.to_s] = ModuleGroupDefinition.new(self, module_group_key, module_group_config)
    end

    def validate
      @imports.values.each { |d| d.validate }
      @module_groups.values.each { |d| d.validate }
    end

    attr_reader :repository

    # List of modules to import
    attr_reader :imports

    def import_by_name(import_key)
      import = @imports[import_key.to_s]
      raise "Unable to locate import definition by key '#{import_key}'" unless import
      import
    end

    # List of module_groups configs
    attr_reader :module_groups

    def module_group_by_name?(module_group_key)
      !!@module_groups[module_group_key.to_s]
    end

    def module_group_by_name(module_group_key)
      module_group = @module_groups[module_group_key.to_s]
      raise "Unable to locate module group definition by key '#{module_group_key}'" unless module_group
      module_group
    end

    attr_writer :migrations

    def enable_migrations?
      @migrations.nil? ? false : !!@migrations
    end

    attr_writer :migrations_applied_at_create

    def assume_migrations_applied_at_create?
      @migrations_applied_at_create.nil? ? enable_migrations? : @migrations_applied_at_create
    end

    attr_writer :rake_integration

    def enable_rake_integration?
      @rake_integration.nil? ? true : @rake_integration
    end

    def task_prefix
      raise "task_prefix invoked" unless enable_rake_integration?
      "#{Dbt::Config.task_prefix}#{Dbt::Config.default_database?(self.key) ? '' : ":#{self.key}"}"
    end

    # Database version. Stuffed as an extended property and used when creating filename.
    attr_accessor :version

    # Hash of database version. Stuffed as an extended property and used when determining whether content of version
    # has changed.
    attr_writer :version_hash

    def version_hash
      @version_hash || cache_version_hash
    end

    attr_writer :datasets_dir_name

    def datasets_dir_name
      @datasets_dir_name || Dbt::Config.default_datasets_dir_name
    end

    attr_writer :fixture_dir_name

    def fixture_dir_name
      @fixture_dir_name || Dbt::Config.default_fixture_dir_name
    end

    def pre_db_artifacts
      @pre_db_artifacts
    end

    def post_db_artifacts
      @post_db_artifacts
    end

    attr_writer :pre_create_dirs

    def pre_create_dirs
      @pre_create_dirs || Dbt::Config.default_pre_create_dirs
    end

    attr_writer :post_create_dirs

    def post_create_dirs
      @post_create_dirs || Dbt::Config.default_post_create_dirs
    end

    attr_writer :migrations_dir_name

    def migrations_dir_name
      @migrations_dir_name || Dbt::Config.default_migrations_dir_name
    end

    # If there is a resource path then we are loading from within the jar
    # so we should not attempt to scan search directories
    def load_from_classloader?
      !!@resource_prefix
    end

    attr_accessor :resource_prefix

    attr_writer :search_dirs

    def search_dirs
      @search_dirs || Dbt::Config.default_search_dirs
    end

    def dirs_for_database(subdir)
      search_dirs.map { |d| "#{d}/#{subdir}" }
    end

    attr_writer :up_dirs

    # Return the list of dirs to process when "upping" module
    def up_dirs
      @up_dirs || Dbt::Config.default_up_dirs
    end

    attr_writer :down_dirs

    # Return the list of dirs to process when "downing" module
    def down_dirs
      @down_dirs || Dbt::Config.default_down_dirs
    end

    attr_writer :finalize_dirs

    # Return the list of dirs to process when finalizing module.
    # i.e. Getting database ready for use. Often this is the place to add expensive triggers, constraints and indexes
    # after the import
    def finalize_dirs
      @finalize_dirs || Dbt::Config.default_finalize_dirs
    end

    attr_writer :datasets

    # List of datasets that should be defined.
    def datasets
      @datasets || []
    end

    attr_writer :separate_import_task

    def enable_separate_import_task?
      @separate_import_task.nil? ? false : @separate_import_task
    end

    attr_writer :import_task_as_part_of_create

    def enable_import_task_as_part_of_create?
      @import_task_as_part_of_create.nil? ? (self.imports.size > 0) : @import_task_as_part_of_create
    end

    attr_writer :backup

    # Should the a backup task be defined for database?
    def backup?
      @backup.nil? ? false : @backup
    end

    attr_writer :restore

    # Should the a restore task be defined for database?
    def restore?
      @restore.nil? ? false : @restore
    end

    private
    def cache_version_hash
      @version_hash ||= Dbt.runtime.calculate_fileset_hash( self )
    end
  end
end
