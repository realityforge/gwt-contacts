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
    assert_equal definition.pre_db_artifacts, []
    assert_equal definition.post_db_artifacts, []

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
    Dbt::Config.default_search_dirs = %w(a b)
    definition = Dbt::DatabaseDefinition.new(:default, {})
    dirs_for_database = definition.dirs_for_database('triggers')
    assert dirs_for_database[0] =~ /^.*a\/triggers$/
    assert dirs_for_database[1] =~ /^.*b\/triggers$/
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
      db.repository.modules = ['CodeMetrics', 'Foo']
    end
    definition.validate

    definition2 = Dbt::DatabaseDefinition.new(:default,
                                              :imports => {:default => {:modules => [:CodeMetrics]}}) do |db|
      db.repository.modules = ['Foo']
    end
    assert_raises(RuntimeError) do
      definition2.validate
    end
  end

  def test_version_hash
    Dbt::Config.default_search_dirs = ['.']
    definition = Dbt::DatabaseDefinition.new(:default, :module_groups => {:foo => {}})

    assert(Dbt.runtime.respond_to?(:calculate_fileset_hash), "Mocked calculate_fileset_hash, but it doesn't exist!")

    s = sequence('main')
    mock = Dbt.runtime
    mock.expects(:calculate_fileset_hash).with(definition).returns('A').in_sequence(s)

    assert_equal( 'A', definition.version_hash )

    definition.version_hash = 'B'

    # Should not trigger another call to calculate the hash
    assert_equal( 'B', definition.version_hash )
  end
end
