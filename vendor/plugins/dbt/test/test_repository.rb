require File.expand_path('../helper', __FILE__)

class TestRepository < Dbt::TestCase
  def test_database_interactions
    repository = Dbt::Repository.new

    database = repository.add_database(:default)

    assert_equal repository.database_for_key(:default), database

    assert repository.database_keys.include?(:default)

    assert_raises(RuntimeError) do
      repository.add_database(:default)
    end

    assert_equal repository.database_for_key(:default), database

    assert repository.database_keys.include?(:default)

    assert_equal repository.remove_database(:default), database

    assert !repository.database_keys.include?(:default)

    assert_raises(RuntimeError) do
      repository.database_for_key(:default)
    end

    assert_raises(RuntimeError) do
      repository.remove_database(:default)
    end
  end

  def test_database_configurations
    repository = Dbt::Repository.new

    assert_equal repository.configuration_for_key?(:development), false

    repository.configuration_data = {
      'development' =>
        {
          'database' => 'DBT_TEST',
          'username' => 'postgres',
          'password' => 'mypass',
          'host' => '127.0.0.1',
          'port' => 5432
        }
    }
    assert_equal repository.configuration_for_key?(:development), true

    Dbt::Config.driver = 'postgres'

    config = repository.configuration_for_key(:development)

    assert config.is_a?(Dbt::PgDbConfig) || config.is_a?(Dbt::PostgresDbConfig)

    assert_equal config.host, '127.0.0.1'
    assert_equal config.port, 5432
    assert_equal config.catalog_name, 'DBT_TEST'
    assert_equal config.username, 'postgres'
    assert_equal config.password, 'mypass'

    assert repository.configuration_for_key(:development) == config

    repository.configuration_data = nil

    assert_equal repository.configuration_for_key?(:development), false

    assert_raises(RuntimeError) do
      repository.configuration_for_key(:development)
    end
  end

  def test_top_level_configuration_for_key
    Dbt.repository.configuration_data = {
      'development' =>
        {
          'database' => 'DBT_TEST',
          'username' => 'postgres',
          'password' => 'mypass',
          'host' => '127.0.0.1',
          'port' => 5432
        }
    }

    Dbt.add_database(:default, :rake_integration => false)

    assert_equal Dbt.repository.configuration_for_key?(:development), true

    assert_not_nil Dbt.configuration_for_key(:default)
  end

  def test_database_configuration_load
    repository = Dbt::Repository.new

    database_yml = create_file('database.yml', <<-DATABASE_YML)
development:
  database: DBT_TEST
  username: <%= 'postgres' %>
  password: <%= 'mypass' %>
  host: 127.0.0.1
  port: 5432
    DATABASE_YML

    Dbt::Config.config_filename = database_yml
    assert repository.load_configuration_data

    assert_equal repository.configuration_for_key?(:development), true
    Dbt::Config.driver = 'postgres'

    config = repository.configuration_for_key(:development)
    assert_equal config.host, '127.0.0.1'
    assert_equal config.port, 5432
    assert_equal config.catalog_name, 'DBT_TEST'
    assert_equal config.username, 'postgres'
    assert_equal config.password, 'mypass'
  end

  def test_database_configuration_reset_when_config_filename_changed
    database_yml = create_file('database.yml', <<-DATABASE_YML)
development:
  database: DBT_TEST
  username: <%= 'postgres' %>
  password: <%= 'mypass' %>
  host: 127.0.0.1
  port: 5432
    DATABASE_YML

    Dbt.repository.configuration_data = {'production' => {}}
    assert_equal Dbt.repository.is_configuration_data_loaded?, true
    Dbt::Config.config_filename = database_yml
    assert_equal Dbt.repository.is_configuration_data_loaded?, false
  end
end
