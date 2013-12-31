require File.expand_path('../helper', __FILE__)

class TestModuleGroupDefinition < Dbt::TestCase

  def test_defaults
    definition = Dbt::DatabaseDefinition.new(:default,
                                             :module_groups => {:foo => {:modules => [:Bar]}}) do |d|
      d.repository.modules = ['Bar', 'Baz']
    end
    module_groups = definition.module_groups
    assert_equal module_groups.size, 1

    module_group = module_groups.values[0]
    assert_equal module_group.key, :foo
    assert_equal module_group.database, definition
    assert_equal module_group.modules, [:Bar]
    assert_equal module_group.import_enabled?, false

    # Should not raise an exception
    module_group.validate
  end

  def test_invalid
    definition = Dbt::DatabaseDefinition.new(:default,
                                             :module_groups => {:foo => {:modules => [:Bar]}}) do |db|
      db.repository.modules = []
    end

    assert_raises RuntimeError, "Module Bar in module group foo does not exist in database module list []" do
      definition.module_groups.values[0].validate
    end
  end

  def test_missing_modules
    definition = Dbt::DatabaseDefinition.new(:default, :module_groups => {:foo => {}})

    assert_raises RuntimeError, "Missing modules configuration for module_group foo" do
      definition.module_groups.values[0].modules
    end
  end
end
