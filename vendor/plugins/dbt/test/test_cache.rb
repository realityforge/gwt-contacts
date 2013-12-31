require File.expand_path('../helper', __FILE__)

class TestCache < Dbt::TestCase

  def test_basic_workflow
    zip_filename = create_zip('data/File.txt' => 'myContents', 'ExcludedFile.txt' => 'blah')
    cache = Dbt::Cache.new
    assert_equal 0, cache.instance_variable_get("@package_cache").size
    cache.package(zip_filename)
    assert_equal 1, cache.instance_variable_get("@package_cache").size
    assert_equal 1, cache.package(zip_filename).files.size
    assert_equal 'myContents', cache.package(zip_filename).contents('File.txt')
    cache.reset
    assert_equal 0, cache.instance_variable_get("@package_cache").size
  end
end
