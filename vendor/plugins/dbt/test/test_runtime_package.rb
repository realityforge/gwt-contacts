require File.expand_path('../helper', __FILE__)

class TestRuntimePackage < Dbt::TestCase

  def test_simple_package
    db_scripts = create_dir("databases/generated")
    create_file("databases/generated/MyModule/base.sql", "")
    create_file("databases/generated/MyModule/types/typeA.sql", "")
    create_file("databases/generated/MyModule/views/viewA.sql", "")
    create_file("databases/generated/MyModule/functions/functionA.sql", "")
    create_file("databases/generated/MyModule/stored-procedures/spA.sql", "")
    create_file("databases/generated/MyModule/misc/spA.sql", "")
    create_file("databases/generated/MyModule/fixtures/foo.yml", "")
    create_file("databases/generated/MyModule/fixtures/bar.sql", "")
    create_file("databases/generated/MyModule/fixtures/fooShouldNotCopy.yml", "")
    create_file("databases/generated/MyModule/triggers/trgA.sql", "")
    create_file("databases/generated/MyModule/finalize/finA.sql", "")
    create_file("databases/generated/MyModule/down/downA.sql", "")

    database = Dbt.add_database(:default) do |db|
      db.rake_integration = false
      db.modules = ['MyModule']
      db.table_map = {'MyModule' => ['foo', 'bar', 'baz']}
      db.search_dirs = [db_scripts]
    end

    output_dir = create_dir("pkg/out")
    Dbt.runtime.package_database_data(database, output_dir)

    assert_file_exist("#{output_dir}/MyModule/base.sql")
    assert_file_exist("#{output_dir}/MyModule/types/typeA.sql")
    assert_file_exist("#{output_dir}/MyModule/views/viewA.sql")
    assert_file_exist("#{output_dir}/MyModule/functions/functionA.sql")
    assert_file_exist("#{output_dir}/MyModule/stored-procedures/spA.sql")
    assert_file_exist("#{output_dir}/MyModule/misc/spA.sql")
    assert_file_exist("#{output_dir}/MyModule/fixtures/foo.yml")
    assert_file_not_exist("#{output_dir}/MyModule/fixtures/fooShouldNotCopy.yml")
    assert_file_not_exist("#{output_dir}/MyModule/fixtures/bar.sql")
    assert_file_exist("#{output_dir}/MyModule/triggers/trgA.sql")
    assert_file_exist("#{output_dir}/MyModule/finalize/finA.sql")
    assert_file_exist("#{output_dir}/MyModule/down/downA.sql")
  end

  def test_multiple_modules
    db_scripts = create_dir("databases/generated")
    create_file("databases/generated/MyModule/base.sql", "")
    create_file("databases/generated/MyOtherModule/base.sql", "")

    database = Dbt.add_database(:default) do |db|
      db.rake_integration = false
      db.modules = ['MyModule', 'MyOtherModule']
      db.table_map = {'MyModule' => [], 'MyOtherModule' => []}
      db.search_dirs = [db_scripts]
    end

    output_dir = create_dir("pkg/out")
    Dbt.runtime.package_database_data(database, output_dir)

    assert_file_exist("#{output_dir}/MyModule/base.sql")
    assert_file_exist("#{output_dir}/MyOtherModule/base.sql")
  end

  def test_multiple_search_dirs
    create_file("databases/MyModule/base.sql", "")
    create_file("databases/generated/MyModule/base2.sql", "")

    database = Dbt.add_database(:default) do |db|
      db.rake_integration = false
      db.modules = ['MyModule']
      db.table_map = {'MyModule' => ['foo', 'bar', 'baz']}
      db.search_dirs = [create_dir("databases"), create_dir("databases/generated")]
    end

    output_dir = create_dir("pkg/out")
    Dbt.runtime.package_database_data(database, output_dir)

    assert_file_exist("#{output_dir}/MyModule/base.sql")
    assert_file_exist("#{output_dir}/MyModule/base2.sql")
  end

  def test_ordering_in_index
    create_file("databases/MyModule/base1.sql", "")
    create_file("databases/MyModule/base2.sql", "")
    create_file("databases/MyModule/base3.sql", "")

    database = Dbt.add_database(:default) do |db|
      db.rake_integration = false
      db.modules = ['MyModule']
      db.table_map = {'MyModule' => []}
      db.search_dirs = [create_dir("databases")]
    end

    Dbt::Config.index_file_name = "myindex.txt"

    output_dir = create_dir("pkg/out")
    Dbt.runtime.package_database_data(database, output_dir)

    assert_file_exist("#{output_dir}/MyModule/base1.sql")
    assert_file_exist("#{output_dir}/MyModule/base2.sql")
    assert_file_exist("#{output_dir}/MyModule/base3.sql")

    assert_file_exist("#{output_dir}/MyModule/myindex.txt")
    index = IO.readlines("#{output_dir}/MyModule/myindex.txt")
    assert_equal index.size, 3
    assert_equal index[0].strip, "base1.sql"
    assert_equal index[1].strip, "base2.sql"
    assert_equal index[2].strip, "base3.sql"
  end

  def test_ordering_in_index_with_partial_index_supplied
    Dbt::Config.index_file_name = "myindex.txt"

    create_file("databases/MyModule/myindex.txt", "base3.sql\nbase2.sql\n")
    create_file("databases/MyModule/base1.sql", "")
    create_file("databases/MyModule/base2.sql", "")
    create_file("databases/MyModule/base3.sql", "")
    create_file("databases/MyModule/base4.sql", "")

    database = Dbt.add_database(:default) do |db|
      db.rake_integration = false
      db.modules = ['MyModule']
      db.table_map = {'MyModule' => []}
      db.search_dirs = [create_dir("databases")]
    end

    output_dir = create_dir("pkg/out")
    Dbt.runtime.package_database_data(database, output_dir)

    assert_file_exist("#{output_dir}/MyModule/base1.sql")
    assert_file_exist("#{output_dir}/MyModule/base2.sql")
    assert_file_exist("#{output_dir}/MyModule/base3.sql")
    assert_file_exist("#{output_dir}/MyModule/base4.sql")

    assert_file_exist("#{output_dir}/MyModule/myindex.txt")
    index = IO.readlines("#{output_dir}/MyModule/myindex.txt")
    assert_equal index.size, 4
    assert_equal index[0].strip, "base3.sql"
    assert_equal index[1].strip, "base2.sql"
    assert_equal index[2].strip, "base1.sql"
    assert_equal index[3].strip, "base4.sql"
  end

  def test_ordering_in_index_with_full_index_supplied
    Dbt::Config.index_file_name = "myindex.txt"

    create_file("databases/MyModule/myindex.txt", "base3.sql\nbase1.sql\nbase2.sql\n")
    create_file("databases/MyModule/base1.sql", "")
    create_file("databases/MyModule/base2.sql", "")
    create_file("databases/MyModule/base3.sql", "")

    database = Dbt.add_database(:default) do |db|
      db.rake_integration = false
      db.modules = ['MyModule']
      db.table_map = {'MyModule' => []}
      db.search_dirs = [create_dir("databases")]
    end

    output_dir = create_dir("pkg/out")
    Dbt.runtime.package_database_data(database, output_dir)

    assert_file_exist("#{output_dir}/MyModule/base1.sql")
    assert_file_exist("#{output_dir}/MyModule/base2.sql")
    assert_file_exist("#{output_dir}/MyModule/base3.sql")

    assert_file_exist("#{output_dir}/MyModule/myindex.txt")
    index = IO.readlines("#{output_dir}/MyModule/myindex.txt")
    assert_equal index.size, 3
    assert_equal index[0].strip, "base3.sql"
    assert_equal index[1].strip, "base1.sql"
    assert_equal index[2].strip, "base2.sql"
  end

  def test_data_sets_copied
    db_scripts = create_dir("databases/generated")
    create_file("databases/generated/MyModule/zang/bing/foo.yml", "")

    database = Dbt.add_database(:default) do |db|
      db.rake_integration = false
      db.modules = ['MyModule']
      db.table_map = {'MyModule' => ['foo', 'bar', 'baz']}
      db.search_dirs = [db_scripts]
      db.datasets = ['bing']
    end

    Dbt::Config.default_datasets_dir_name = 'zang'

    output_dir = create_dir("pkg/out")
    Dbt.runtime.package_database_data(database, output_dir)

    assert_file_exist("#{output_dir}/MyModule/zang/bing/foo.yml")
  end

  def test_imports_copied
    db_scripts = create_dir("databases/generated")
    create_file("databases/generated/MyModule/import1/foo.yml", "")

    database = Dbt.add_database(:default) do |db|
      db.rake_integration = false
      db.modules = ['MyModule']
      db.table_map = {'MyModule' => ['foo', 'bar', 'baz']}
      db.search_dirs = [db_scripts]
      db.add_import(:default, {})
    end

    Dbt::Config.default_import_dir = 'import1'

    output_dir = create_dir("pkg/out")
    Dbt.runtime.package_database_data(database, output_dir)

    assert_file_exist("#{output_dir}/MyModule/import1/foo.yml")
  end
end
