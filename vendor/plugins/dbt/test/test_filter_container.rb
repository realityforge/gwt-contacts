require File.expand_path('../helper', __FILE__)

class TestFilterContainer < Dbt::TestCase

  class TestFilterContainer
    include Dbt::FilterContainer

    def initialize
      @database_environment_filter = @import_assert_filters = nil
    end
  end

  def test_add_database_name_filter
    c = TestFilterContainer.new

    create_postgres_config

    pattern = '@@MYDB@@'
    database_key = 'default'
    optional = false
    c.add_database_name_filter(pattern, database_key, optional)

    assert_equal c.filters.size, 1
    assert c.filters[0].is_a?(Dbt::DatabaseNameFilter)
    assert_equal c.filters[0].pattern, pattern
    assert_equal c.filters[0].database_key, database_key
    assert_equal c.filters[0].optional, optional

    assert_equal expand_text("X", c), "X"
    assert_equal expand_text("@@MYDB@@", c), "DBT_TEST"
  end

  def test_add_property_filter
    c = TestFilterContainer.new

    pattern = '@@MYKEY@@'
    value = 'foofoo'
    c.add_property_filter(pattern, value)

    assert_equal c.filters.size, 1
    assert c.filters[0].is_a?(Dbt::PropertyFilter)
    assert_equal c.filters[0].pattern, pattern
    assert_equal c.filters[0].value, value

    assert_equal expand_text("X", c), "X"
    assert_equal expand_text("@@MYKEY@@", c), "foofoo"
  end

  def test_database_environment_filter
    c = TestFilterContainer.new

    assert_equal c.database_environment_filter?, false

    c.database_environment_filter = true

    assert_equal expand_text("X", c), "X"
    assert_equal expand_text("@@ENVIRONMENT@@", c), Dbt::Config.environment.to_s
  end


  def test_import_assert_filters
    c = TestFilterContainer.new

    assert_equal c.import_assert_filters?, true

    c.import_assert_filters = true

    assert_equal expand_text("X", c), "X"
    assert_not_equal expand_text("ASSERT_ROW_COUNT(1)", c), "ASSERT_ROW_COUNT(1)"
  end

  def expand_text(text, filter_container)
    filter_container.expanded_filters.each do |filter|
      text = filter.call(text)
    end
    text
  end

  def create_postgres_config(config = {}, top_level_config = {})
    Dbt::Config.driver = 'postgres'
    Dbt.repository.configuration_data = {
      Dbt::Config.environment => base_postgres_config(config)
    }.merge(top_level_config)
    Dbt.repository.configuration_for_key(Dbt::Config.environment)
  end

  def base_postgres_config(config = {})
    {
      'database' => 'DBT_TEST',
      'username' => ENV['USER'],
      'password' => 'letmein',
      'host' => '127.0.0.1',
      'port' => 5432
    }.merge(config)
  end
end
