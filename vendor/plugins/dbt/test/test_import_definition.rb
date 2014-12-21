require File.expand_path('../helper', __FILE__)

class TestImportDefinition < Dbt::TestCase

  def test_defaults
    definition = Dbt::DatabaseDefinition.new(:default,
                                             :imports =>
                                               {
                                                 :foo => {}
                                               }) do |d|
      d.repository.modules = %w(Bar Baz)
    end
    imports = definition.imports
    assert_equal imports.size, 1

    imp = imports.values[0]
    assert_equal imp.key, :foo
    assert_equal imp.database, definition
    assert_equal imp.modules, %w(Bar Baz)
    Dbt::Config.default_import_dir = 'foo'
    assert_equal imp.dir, 'foo'
    Dbt::Config.default_pre_import_dirs = %w(zang)
    assert_equal imp.pre_import_dirs, %w(zang)

    Dbt::Config.default_post_import_dirs = %w(zing)
    assert_equal imp.post_import_dirs, %w(zing)

    # Should not raise an exception
    imp.validate
  end

  def test_invalid
    definition = Dbt::DatabaseDefinition.new(:default, :imports => {:foo => {:modules => %w(Foo)}}) do |d|
      d.repository.modules = %w(Bar Baz)
    end

    assert_raises RuntimeError do
      definition.imports.values[0].validate
    end
  end
end
