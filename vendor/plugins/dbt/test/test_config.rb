require File.expand_path('../helper', __FILE__)

class TestConfig < Dbt::TestCase
  # variable, default value, value to change to
  [
    [:default_migrations_dir_name, 'migrations', 'custom_migrations'],
    [:default_up_dirs, ['.', 'types', 'views', 'functions', 'stored-procedures', 'misc'], ['foo']],
    [:default_down_dirs, ['down'], ['foo']],
    [:default_finalize_dirs, ['triggers', 'finalize'], ['foo']],
    [:default_pre_import_dirs, ['import-hooks/pre'], ['foo']],
    [:default_post_import_dirs, ['import-hooks/post'], ['foo']],
    [:default_pre_create_dirs, ['db-hooks/pre'], ['foo']],
    [:default_post_create_dirs, ['db-hooks/post'], ['foo']],
    [:default_database, :default, 'iris'],
    [:default_import, :default, 'import-lite'],
    [:default_import_dir, 'import', 'import-lite'],
    [:repository_config_file, 'repository.yml', 'repo.yml'],
    [:default_datasets_dir_name, 'datasets', 'mydatasets'],
    [:default_fixture_dir_name, 'fixtures', 'myfixtures'],
    [:index_file_name, 'index.txt', 'import-lite'],
    [:task_prefix, 'dbt', 'db'],
    [:driver, 'sql_server', 'postgres'],
    [:environment, 'development', 'production']
  ].each do |config_name, default_value, new_value|
    define_method(:"test_#{config_name}") do
      assert_equal Dbt::Config.send(config_name), default_value
      Dbt::Config.send("#{config_name}=", new_value)
      assert_equal Dbt::Config.send(config_name), new_value
    end
  end

  def test_config_filename
    assert_raises(RuntimeError) do
      Dbt::Config.config_filename
    end
    Dbt::Config.config_filename = "myconfig.yml"
    assert_equal Dbt::Config.config_filename, "myconfig.yml"
  end

  def test_default_search_dirs
    assert_raises(RuntimeError) do
      Dbt::Config.default_search_dirs
    end
    Dbt::Config.default_search_dirs = ['x']
    assert_equal Dbt::Config.default_search_dirs, ['x']
  end

  def test_default_no_create
    assert_equal Dbt::Config.default_no_create?, false
    Dbt::Config.default_no_create = true
    assert_equal Dbt::Config.default_no_create?, true
  end

  def test_default_database?
    Dbt::Config.default_database = :foo
    assert_equal Dbt::Config.default_database?(:foo), true
    assert_equal Dbt::Config.default_database?(:bar), false
  end

  def test_default_import?
    Dbt::Config.default_import = :foo
    assert_equal Dbt::Config.default_import?(:foo), true
    assert_equal Dbt::Config.default_import?(:bar), false
  end

  def test_driver_config_class
    Dbt::Config.driver = 'sql_server'
    assert [Dbt::MssqlDbConfig, Dbt::TinyTdsDbConfig].include?(Dbt::Config.driver_config_class)
    Dbt::Config.driver = 'postgres'
    assert [Dbt::PostgresDbConfig, Dbt::PgDbConfig].include?(Dbt::Config.driver_config_class)
  end

  def test_driver_class
    Dbt::Config.driver = 'sql_server'
    assert [Dbt::MssqlDbDriver, Dbt::TinyTdsDbDriver].include?(Dbt::Config.driver_class)
    Dbt::Config.driver = 'postgres'
    assert [Dbt::PostgresDbDriver, Dbt::PgDbDriver].include?(Dbt::Config.driver_class)
  end
end
