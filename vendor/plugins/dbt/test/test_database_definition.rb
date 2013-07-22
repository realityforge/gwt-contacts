require File.expand_path('../helper', __FILE__)

class TestDatabaseDefinition < Dbt::TestCase

  def test_defaults
    definition = Dbt::DatabaseDefinition.new(:default, {})
    assert_equal definition.key, :default
    assert_equal definition.imports, {}
    assert_equal definition.module_groups, {}
    assert_equal definition.enable_rake_integration?, true
    assert_equal definition.enable_migrations?, false
    assert_equal definition.assume_migrations_applied_at_create?, false
    assert_equal definition.enable_separate_import_task?, false
    assert_equal definition.enable_import_task_as_part_of_create?, false
    assert_equal definition.backup?, false
    assert_equal definition.restore?, false
    assert_equal definition.schema_overrides, {}

    assert_equal definition.load_from_classloader?, false
    assert_equal definition.datasets, []
    assert_equal definition.version, nil
    assert_equal definition.up_dirs, Dbt::Config.default_up_dirs
    assert_equal definition.down_dirs, Dbt::Config.default_down_dirs
    assert_equal definition.finalize_dirs, Dbt::Config.default_finalize_dirs
    assert_equal definition.pre_create_dirs, Dbt::Config.default_pre_create_dirs
    assert_equal definition.post_create_dirs, Dbt::Config.default_post_create_dirs
    assert_equal definition.datasets_dir_name, Dbt::Config.default_datasets_dir_name

    Dbt::Config.default_search_dirs = ['x']
    assert_equal definition.search_dirs, Dbt::Config.default_search_dirs
    assert_equal definition.migrations_dir_name, Dbt::Config.default_migrations_dir_name
  end

  def test_defaults_import
    definition = Dbt::DatabaseDefinition.new(:default, {})
    definition.add_import(:default, {})
    assert_equal definition.assume_migrations_applied_at_create?, false
  end

  def test_dirs_for_database
    Dbt::Config.default_search_dirs = ['a', 'b']
    definition = Dbt::DatabaseDefinition.new(:default, {})
    assert_equal definition.dirs_for_database('triggers'), ['a/triggers', 'b/triggers']
  end

  def test_modules
    definition = Dbt::DatabaseDefinition.new(:default, {})
    modules = ['a', 'b']
    definition.modules = modules
    assert_equal definition.modules, modules

    modules = ['a', 'b', 'c']
    definition.modules = Proc.new { modules }
    assert_equal definition.modules, modules
  end

  def test_task_prefix
    assert_equal Dbt::DatabaseDefinition.new(:default, :rake_integration => true).task_prefix,
                 'dbt'
    assert_equal Dbt::DatabaseDefinition.new(:core, :rake_integration => true).task_prefix,
                 'dbt:core'
    assert_raises(RuntimeError) do
      Dbt::DatabaseDefinition.new(:default, :rake_integration => false).task_prefix
    end
  end

  def test_schema_name_for_module
    definition = Dbt::DatabaseDefinition.new(:default, {})
    definition.schema_overrides = {'bar' => 'baz'}
    assert_equal definition.schema_name_for_module('foo'), 'foo'
    assert_equal definition.schema_name_for_module('bar'), 'baz'
  end

  def test_table_ordering
    definition = Dbt::DatabaseDefinition.new(:default, {})
    definition.table_map = {'mySchema' => ['tblOne', 'tblTwo']}
    assert_equal definition.table_ordering('mySchema'), ['tblOne', 'tblTwo']
    assert_raises(RuntimeError) do
      definition.table_ordering('NoSchemaHere')
    end
  end

  def test_resource_prefix_implies_classloader_load
    assert_equal Dbt::DatabaseDefinition.new(:default, {:resource_prefix => 'l'}).load_from_classloader?,
                 true
    assert_equal Dbt::DatabaseDefinition.new(:default, {:resource_prefix => nil}).load_from_classloader?,
                 false
  end

  def test_module_groups
    definition = Dbt::DatabaseDefinition.new(:default, :module_groups => {:foo => {}})
    definition.module_groups
    assert_equal definition.module_groups.size, 1
    assert_equal definition.module_group_by_name(:foo).key, :foo
    assert_equal definition.module_groups['foo'].key, :foo
    assert_equal definition.module_groups['foo'].database, definition
  end

  def test_imports
    definition = Dbt::DatabaseDefinition.new(:default, :imports => {:foo => {}})
    definition.module_groups
    assert_equal definition.imports.size, 1
    assert_equal definition.import_by_name(:foo).key, :foo
    assert_equal definition.imports['foo'].key, :foo
    assert_equal definition.imports['foo'].database, definition
  end

  def test_validate
    definition = Dbt::DatabaseDefinition.new(:default,
                                             :imports => {:default => {:modules => [:CodeMetrics]}}) do |db|
      db.modules = ['CodeMetrics', 'Foo']
    end
    definition.validate

    definition2 = Dbt::DatabaseDefinition.new(:default,
                                              :imports => {:default => {:modules => [:CodeMetrics]}}) do |db|
      db.modules = ['Foo']
    end
    assert_raises(RuntimeError) do
      definition2.validate
    end
  end

  def test_parse_repository_config
    definition = Dbt::DatabaseDefinition.new(:default, {})
    definition.parse_repository_config(<<-CONFIG)
---
modules: !omap
- CodeMetrics:
    schema: CodeMetrics
    tables:
    - "[CodeMetrics].[tblCollection]"
    - "[CodeMetrics].[tblMethodMetric]"
- Geo:
    schema: Geo
    tables:
    - "[Geo].[tblMobilePOI]"
    - "[Geo].[tblPOITrack]"
    - "[Geo].[tblSector]"
    - "[Geo].[tblOtherGeom]"
- TestModule:
    schema: TM
    tables:
    - "[TM].[tblBaseX]"
    - "[TM].[tblFoo]"
    - "[TM].[tblBar]"
    CONFIG

    assert_equal definition.modules, ['CodeMetrics', 'Geo', 'TestModule']
    assert_equal definition.schema_overrides.size, 1
    assert_equal definition.schema_name_for_module('TestModule'), 'TM'
    assert_equal definition.table_ordering('Geo'), ["[Geo].[tblMobilePOI]","[Geo].[tblPOITrack]","[Geo].[tblSector]","[Geo].[tblOtherGeom]"]
  end
end
