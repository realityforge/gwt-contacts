require File.expand_path('../helper', __FILE__)

class TestRuntimeBasic < Dbt::TestCase

  def test_status
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]', '[MyModule].[bar]', '[MyModule].[baz]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    database.version = 2
    database.migrations = false
    status = Dbt.runtime.status(database)
    assert_match 'Migration Support: No', status
    assert_match 'Database Version: 2', status

    database.version = 1
    database.migrations = true
    status = Dbt.runtime.status(database)
    assert_match 'Migration Support: Yes', status
    assert_match 'Database Version: 1', status
  end

  def test_query
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]', '[MyModule].[bar]', '[MyModule].[baz]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    sql = "SELECT 42"

    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:query).with(sql).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.query(database, sql)
  end

  def test_create
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]', '[MyModule].[bar]', '[MyModule].[baz]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    mock.expects(:open).with(config, true).in_sequence(@s)
    mock.expects(:drop).with(database, config).in_sequence(@s)
    mock.expects(:create_database).with(database, config).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)
    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:create_schema).with(module_name).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.create(database)
  end

  def test_create_by_import
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config({}, 'import' => base_postgres_config().merge('database' => 'IMPORT_DB'))

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)
    database.separate_import_task = true
    import = database.add_import(:default, {})

    mock.expects(:open).with(config, true).in_sequence(@s)
    mock.expects(:drop).with(database, config).in_sequence(@s)
    mock.expects(:create_database).with(database, config).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)
    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:create_schema).with(module_name).in_sequence(@s)
    expect_default_table_import(mock, import, module_name, 'foo')
    mock.expects(:post_data_module_import).with(import, module_name).in_sequence(@s)
    mock.expects(:post_database_import).with(import).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.create_by_import(import)
  end

  def test_create_with_no_create
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config('no_create' => true)

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]', '[MyModule].[bar]', '[MyModule].[baz]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:create_schema).with(module_name).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.create(database)
  end

  def test_create_with_multiple_fixtures
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]', '[MyModule].[bar]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    create_fixture(module_name, 'foo')
    create_fixture(module_name, 'bar')

    mock.expects(:open).with(config, true).in_sequence(@s)
    mock.expects(:drop).with(database, config).in_sequence(@s)
    mock.expects(:create_database).with(database, config).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)
    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:create_schema).with(module_name).in_sequence(@s)
    expect_delete(mock, module_name, 'bar')
    expect_delete(mock, module_name, 'foo')
    expect_fixture(mock, module_name, 'foo')
    expect_fixture(mock, module_name, 'bar')
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.create(database)
  end

  def test_create_with_unexpected_fixtures
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]', '[MyModule].[bar]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    create_fixture(module_name, 'baz')

    mock.expects(:open).with(config, true).in_sequence(@s)
    mock.expects(:drop).with(database, config).in_sequence(@s)
    mock.expects(:create_database).with(database, config).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)
    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:create_schema).with(module_name).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)

    assert_raises(RuntimeError) do
      Dbt.runtime.create(database)
    end
  end

  def test_create_with_fixtures
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]', '[MyModule].[bar]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    create_fixture(module_name, 'foo')

    mock.expects(:open).with(config, true).in_sequence(@s)
    mock.expects(:drop).with(database, config).in_sequence(@s)
    mock.expects(:create_database).with(database, config).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)
    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:create_schema).with(module_name).in_sequence(@s)
    expect_delete(mock, module_name, 'foo')
    expect_fixture(mock, module_name, 'foo')
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.create(database)
  end

  def test_create_with_fixtures_including_non_fixture
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[foo]', '[bar]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    create_file("databases/#{module_name}/fixtures/bar.sql", "SELECT * FROM tblNotRun")

    mock.expects(:open).with(config, true).in_sequence(@s)
    mock.expects(:drop).with(database, config).in_sequence(@s)
    mock.expects(:create_database).with(database, config).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)
    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:create_schema).with(module_name).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)

    assert_raises(RuntimeError) do
      Dbt.runtime.create(database)
    end
  end

  def test_create_with_sql
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    Dbt::Config.default_up_dirs = ['.', 'Dir1', 'Dir2']
    Dbt::Config.default_finalize_dirs = ['Dir3', 'Dir4']
    Dbt::Config.default_fixture_dir_name = 'foo'
    Dbt::Config.default_pre_create_dirs = ['db-pre-create']
    Dbt::Config.default_post_create_dirs = ['db-post-create']

    create_table_sql("db-pre-create", 'preCreate')
    create_table_sql("#{module_name}", 'a')
    create_table_sql("#{module_name}", 'b')
    create_table_sql("#{module_name}/Dir1", 'd')
    create_table_sql("#{module_name}/Dir1", 'c')
    create_table_sql("#{module_name}/Dir2", 'e')
    create_table_sql("#{module_name}/Dir2", 'f')
    create_fixture(module_name, 'foo')
    create_table_sql("#{module_name}/Dir3", 'g')
    create_table_sql("#{module_name}/Dir4", 'h')
    create_table_sql("db-post-create", 'postCreate')

    mock.expects(:open).with(config, true).in_sequence(@s)
    mock.expects(:drop).with(database, config).in_sequence(@s)
    mock.expects(:create_database).with(database, config).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)
    mock.expects(:open).with(config, false).in_sequence(@s)
    expect_create_table(mock, '', 'db-pre-create/', 'preCreate')
    mock.expects(:create_schema).with(module_name).in_sequence(@s)
    expect_create_table(mock, module_name, '', 'a')
    expect_create_table(mock, module_name, '', 'b')
    expect_create_table(mock, module_name, 'Dir1/', 'c')
    expect_create_table(mock, module_name, 'Dir1/', 'd')
    expect_create_table(mock, module_name, 'Dir2/', 'e')
    expect_create_table(mock, module_name, 'Dir2/', 'f')
    expect_delete(mock, module_name, 'foo')
    expect_fixture(mock, module_name, 'foo')
    expect_create_table(mock, module_name, 'Dir3/', 'g')
    expect_create_table(mock, module_name, 'Dir4/', 'h')
    expect_create_table(mock, '', 'db-post-create/', 'postCreate')
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.create(database)
  end

  def test_create_with_sql_and_index_covering_partial
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    Dbt::Config.default_up_dirs = ['Dir1']
    Dbt::Config.index_file_name = 'index2.txt'

    create_file("databases/#{module_name}/Dir1/index2.txt", "d.sql\ne.sql")
    create_table_sql("#{module_name}/Dir1", 'c')
    create_table_sql("#{module_name}/Dir1", 'd')
    create_table_sql("#{module_name}/Dir1", 'e')
    create_table_sql("#{module_name}/Dir1", 'f')

    mock.expects(:open).with(config, true).in_sequence(@s)
    mock.expects(:drop).with(database, config).in_sequence(@s)
    mock.expects(:create_database).with(database, config).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)
    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:create_schema).with(module_name).in_sequence(@s)
    expect_create_table(mock, module_name, 'Dir1/', 'd')
    expect_create_table(mock, module_name, 'Dir1/', 'e')
    expect_create_table(mock, module_name, 'Dir1/', 'c')
    expect_create_table(mock, module_name, 'Dir1/', 'f')
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.create(database)
  end

  def test_create_with_sql_and_index_covering_full
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    Dbt::Config.default_up_dirs = ['Dir1']
    Dbt::Config.index_file_name = 'index2.txt'

    create_file("databases/#{module_name}/Dir1/index2.txt", "d.sql\ne.sql")
    create_table_sql("#{module_name}/Dir1", 'd')
    create_table_sql("#{module_name}/Dir1", 'e')

    mock.expects(:open).with(config, true).in_sequence(@s)
    mock.expects(:drop).with(database, config).in_sequence(@s)
    mock.expects(:create_database).with(database, config).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)
    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:create_schema).with(module_name).in_sequence(@s)
    expect_create_table(mock, module_name, 'Dir1/', 'd')
    expect_create_table(mock, module_name, 'Dir1/', 'e')
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.create(database)
  end

  def test_create_with_sql_and_index_with_additional
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    Dbt::Config.default_up_dirs = ['Dir1']
    Dbt::Config.index_file_name = 'index2.txt'

    create_file("databases/#{module_name}/Dir1/index2.txt", "d.sql\ne.sql\nf.sql")
    create_table_sql("#{module_name}/Dir1", 'd')
    create_table_sql("#{module_name}/Dir1", 'e')

    mock.expects(:open).with(config, true).in_sequence(@s)
    mock.expects(:drop).with(database, config).in_sequence(@s)
    mock.expects(:create_database).with(database, config).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)
    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:create_schema).with(module_name).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)

    assert_raises(RuntimeError) do
      Dbt.runtime.create(database)
    end
  end

  def test_drop
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]', '[MyModule].[bar]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    mock.expects(:open).with(config, true).in_sequence(@s)
    mock.expects(:drop).with(database, config).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.drop(database)
  end

  def test_import
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config({}, 'import' => base_postgres_config().merge('database' => 'IMPORT_DB'))

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]', '[MyModule].[bar]', '[MyModule].[baz]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)
    database.separate_import_task = true
    import = database.add_import(:default, {})

    mock.expects(:open).with(config, false).in_sequence(@s)
    expect_delete_for_table_import(mock, module_name, 'baz')
    expect_delete_for_table_import(mock, module_name, 'bar')
    expect_delete_for_table_import(mock, module_name, 'foo')
    expect_default_table_import(mock, import, module_name, 'foo')
    expect_default_table_import(mock, import, module_name, 'bar')
    expect_default_table_import(mock, import, module_name, 'baz')
    mock.expects(:post_data_module_import).with(import, module_name).in_sequence(@s)
    mock.expects(:post_database_import).with(import).in_sequence(@s)

    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.database_import(database.import_by_name(:default), nil)
  end

  def test_import_with_IMPORT_RESUME_AT
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config({}, 'import' => base_postgres_config().merge('database' => 'IMPORT_DB'))

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]', '[MyModule].[bar]', '[MyModule].[baz]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)
    database.separate_import_task = true
    import = database.add_import(:default, {})

    mock.expects(:open).with(config, false).in_sequence(@s)
    expect_delete_for_table_import(mock, module_name, 'bar')
    expect_default_table_import(mock, import, module_name, 'bar')
    expect_default_table_import(mock, import, module_name, 'baz')
    mock.expects(:post_data_module_import).with(import, module_name).in_sequence(@s)
    mock.expects(:post_database_import).with(import).in_sequence(@s)

    mock.expects(:close).with()

    ENV['IMPORT_RESUME_AT'] = 'MyModule.bar'
    Dbt.runtime.database_import(database.import_by_name(:default), nil)
  end

  def test_import_by_sql
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config({}, 'import' => base_postgres_config().merge('database' => 'IMPORT_DB'))

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)
    database.separate_import_task = true
    import = database.add_import(:default, {})

    Dbt::Config.default_import_dir = 'zzzz'
    import_sql = "INSERT INTO DBT_TEST.[foo]"
    create_file("databases/#{module_name}/zzzz/MyModule.foo.sql", import_sql)

    mock.expects(:open).with(config, false).in_sequence(@s)
    expect_delete_for_table_import(mock, module_name, 'foo')
    expect_pre_table_import(mock, import, module_name, 'foo', 'S')
    mock.expects(:execute).with(import_sql, true).in_sequence(@s)
    expect_post_table_import(mock, import, module_name, 'foo')
    mock.expects(:post_data_module_import).with(import, module_name).in_sequence(@s)
    mock.expects(:post_database_import).with(import).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.database_import(database.import_by_name(:default), nil)
  end

  def test_import_by_fixture
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config({}, 'import' => base_postgres_config().merge('database' => 'IMPORT_DB'))

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)
    database.separate_import_task = true
    import = database.add_import(:default, {})

    Dbt::Config.default_import_dir = 'zzzz'
    fixture_data = "1:\n  ID: 1\n"
    create_file("databases/MyModule/zzzz/MyModule.foo.yml", fixture_data)

    mock.expects(:open).with(config, false).in_sequence(@s)
    expect_delete_for_table_import(mock, module_name, 'foo')
    expect_pre_table_import(mock, import, module_name, 'foo', 'F')
    mock.expects(:pre_fixture_import).with('[MyModule].[foo]').in_sequence(@s)
    mock.expects(:insert).with('[MyModule].[foo]', 'ID' => 1).in_sequence(@s)
    mock.expects(:post_fixture_import).with('[MyModule].[foo]').in_sequence(@s)
    expect_post_table_import(mock, import, module_name, 'foo')
    mock.expects(:post_data_module_import).with(import, module_name).in_sequence(@s)
    mock.expects(:post_database_import).with(import).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.database_import(database.import_by_name(:default), nil)
  end

  def test_import_using_pre_post_dirs
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config({}, 'import' => base_postgres_config().merge('database' => 'IMPORT_DB'))

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)
    database.separate_import_task = true
    import = database.add_import(:default, {})

    Dbt::Config.default_pre_import_dirs = ['a', 'b']
    pre_import_sql = "SELECT 1"
    create_file("databases/a/yyy.sql", pre_import_sql)
    pre_import_sql_2 = "SELECT 2"
    create_file("databases/b/qqq.sql", pre_import_sql_2)

    Dbt::Config.default_post_import_dirs = ['c', 'd']
    post_import_sql = "SELECT 3"
    create_file("databases/c/xxx.sql", post_import_sql)
    post_import_sql_2 = "SELECT 4"
    create_file("databases/d/zzz.sql", post_import_sql_2)

    mock.expects(:open).with(config, false).in_sequence(@s)
    Dbt.runtime.expects(:info).with("               : a/yyy.sql").in_sequence(@s)
    mock.expects(:execute).with(pre_import_sql, true).in_sequence(@s)
    Dbt.runtime.expects(:info).with("               : b/qqq.sql").in_sequence(@s)
    mock.expects(:execute).with(pre_import_sql_2, true).in_sequence(@s)
    expect_delete_for_table_import(mock, module_name, 'foo')
    expect_default_table_import(mock, import, module_name, 'foo')
    mock.expects(:post_data_module_import).with(import, module_name).in_sequence(@s)
    Dbt.runtime.expects(:info).with("               : c/xxx.sql").in_sequence(@s)
    mock.expects(:execute).with(post_import_sql, true).in_sequence(@s)
    Dbt.runtime.expects(:info).with("               : d/zzz.sql").in_sequence(@s)
    mock.expects(:execute).with(post_import_sql_2, true).in_sequence(@s)
    mock.expects(:post_database_import).with(import).in_sequence(@s)
    mock.expects(:close).with()

    Dbt.runtime.database_import(database.import_by_name(:default), nil)
  end

  def test_migrate
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)
    database.migrations = true

    Dbt::Config.default_migrations_dir_name = 'migrate22'
    migrate_sql_1 = "SELECT 1"
    create_file("databases/migrate22/001_x.sql", migrate_sql_1)
    migrate_sql_2 = "SELECT 2"
    create_file("databases/migrate22/002_x.sql", migrate_sql_2)
    migrate_sql_3 = "SELECT 3"
    create_file("databases/migrate22/003_x.sql", migrate_sql_3)

    mock.expects(:open).with(config, false).in_sequence(@s)
    expect_should_migrate(mock, 'default', '001_x', true)
    expect_migrate(mock, 'default', "001_x", migrate_sql_1)
    expect_should_migrate(mock, 'default', '002_x', true)
    expect_migrate(mock, 'default', "002_x", migrate_sql_2)
    expect_should_migrate(mock, 'default', '003_x', true)
    expect_migrate(mock, 'default', "003_x", migrate_sql_3)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.migrate(database)
  end

  def test_migrate_from_major_version
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)
    database.migrations = true
    database.version = "Version_1"

    Dbt::Config.default_migrations_dir_name = 'migrate22'
    migrate_sql_1 = "SELECT 1"
    create_file("databases/migrate22/001_x.sql", migrate_sql_1)
    migrate_sql_2 = "SELECT 2"
    create_file("databases/migrate22/002_Release-#{database.version}.sql", migrate_sql_2)
    migrate_sql_3 = "SELECT 3"
    create_file("databases/migrate22/003_z.sql", migrate_sql_3)

    mock.expects(:open).with(config, false).in_sequence(@s)
    expect_should_migrate(mock, 'default', '001_x', true)
    expect_mark_migration_as_run(mock, 'default', "001_x")
    expect_should_migrate(mock, 'default',  "002_Release-#{database.version}", true)
    expect_mark_migration_as_run(mock, 'default', "002_Release-#{database.version}")
    expect_should_migrate(mock, 'default',  '003_z', true)
    expect_migrate(mock, 'default', "003_z", migrate_sql_3)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.migrate(database)
  end

  def test_migrate_with_existing_migrations_applied
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)
    database.migrations = true

    Dbt::Config.default_migrations_dir_name = 'migrate22'
    migrate_sql_1 = "SELECT 1"
    create_file("databases/migrate22/001_x.sql", migrate_sql_1)
    migrate_sql_2 = "SELECT 2"
    create_file("databases/migrate22/002_x.sql", migrate_sql_2)
    migrate_sql_3 = "SELECT 3"
    create_file("databases/migrate22/003_x.sql", migrate_sql_3)

    mock.expects(:open).with(config, false).in_sequence(@s)
    expect_should_migrate(mock, 'default',  '001_x', false)
    expect_should_migrate(mock, 'default',  '002_x', false)
    expect_should_migrate(mock, 'default',  '003_x', true)
    expect_migrate(mock, 'default', "003_x", migrate_sql_3)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.migrate(database)
  end

  def test_create_with_migrations
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]', '[MyModule].[bar]', '[MyModule].[baz]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)
    database.migrations = true
    database.migrations_applied_at_create = false

    Dbt::Config.default_migrations_dir_name = 'migrate22'
    migrate_sql_1 = "SELECT 1"
    create_file("databases/migrate22/001_x.sql", migrate_sql_1)

    mock.expects(:open).with(config, true).in_sequence(@s)
    mock.expects(:drop).with(database, config).in_sequence(@s)
    mock.expects(:create_database).with(database, config).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)
    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:create_schema).with(module_name).in_sequence(@s)
    mock.expects(:setup_migrations).with().in_sequence(@s)
    expect_migrate(mock, 'default', "001_x", migrate_sql_1)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.create(database)
  end

  def test_create_with_migrations_already_applied
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'
    table_names = ['[MyModule].[foo]', '[MyModule].[bar]', '[MyModule].[baz]']
    database = create_simple_db_definition(db_scripts, module_name, table_names)
    database.migrations = true
    database.migrations_applied_at_create = true

    Dbt::Config.default_migrations_dir_name = 'migrate22'
    migrate_sql_1 = "SELECT 1"
    create_file("databases/migrate22/001_x.sql", migrate_sql_1)

    mock.expects(:open).with(config, true).in_sequence(@s)
    mock.expects(:drop).with(database, config).in_sequence(@s)
    mock.expects(:create_database).with(database, config).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)
    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:create_schema).with(module_name).in_sequence(@s)
    mock.expects(:setup_migrations).with().in_sequence(@s)
    expect_mark_migration_as_run(mock, 'default', '001_x')
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.create(database)
  end

  def test_load_dataset
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    module_name = 'MyModule'

    database = create_db_definition(db_scripts,
                                    'MyModule' => ['[MyModule].[foo]', '[MyModule].[bar]'],
                                    'MyOtherModule' => ['[MyOtherModule].[baz]'])

    Dbt::Config.default_datasets_dir_name = 'mydatasets'
    create_file("databases/MyModule/mydatasets/mydataset/MyModule.foo.yml", "1:\n  ID: 1\n")
    create_file("databases/MyModule/mydatasets/mydataset/MyModule.bar.yml", "1:\n  ID: 1\n")
    create_file("databases/MyOtherModule/mydatasets/mydataset/MyOtherModule.baz.yml", "1:\n  ID: 1\n")

    mock.expects(:open).with(config, false).in_sequence(@s)
    expect_delete(mock, 'MyOtherModule', 'baz')
    expect_delete(mock, module_name, 'bar')
    expect_delete(mock, module_name, 'foo')
    expect_fixture(mock, module_name, 'foo')
    expect_fixture(mock, module_name, 'bar')
    expect_fixture(mock, 'MyOtherModule', 'baz')
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.load_dataset(database, 'mydataset')
  end

  def test_import_with_module_group
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config({}, 'import' => base_postgres_config().merge('database' => 'IMPORT_DB'))

    db_scripts = create_dir("databases")
    database = create_db_definition(db_scripts,
                                    'MyModule' => ['[MyModule].[foo]', '[MyModule].[bar]'],
                                    'MyOtherModule' => ['[MyOtherModule].[baz]'],
                                    'MyThirdModule' => ['[MyThirdModule].[biz]'])
    module_group = database.add_module_group('zz', :modules => ['MyOtherModule','MyThirdModule'], :import_enabled => true)
    assert_equal module_group.modules, ['MyOtherModule', 'MyThirdModule']
    assert_equal module_group.import_enabled?, true

    import = database.add_import(:default, {})

    mock.expects(:open).with(config, false).in_sequence(@s)
    expect_delete_for_table_import(mock, 'MyOtherModule', 'baz')
    expect_default_table_import(mock, import, 'MyOtherModule', 'baz')
    mock.expects(:post_data_module_import).with(import, 'MyOtherModule').in_sequence(@s)
    # TODO: This is wrong behaviour. All of deletes should occur first
    expect_delete_for_table_import(mock, 'MyThirdModule', 'biz')
    expect_default_table_import(mock, import, 'MyThirdModule', 'biz')
    mock.expects(:post_data_module_import).with(import, 'MyThirdModule').in_sequence(@s)
    mock.expects(:post_database_import).with(import).in_sequence(@s)

    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.database_import(database.import_by_name(:default), database.module_group_by_name('zz'))
  end

  def test_module_group_up
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config({}, 'import' => base_postgres_config().merge('database' => 'IMPORT_DB'))

    db_scripts = create_dir("databases")
    database = create_db_definition(db_scripts,
                                    'MyModule' => ['[MyModule].[foo]', '[MyModule].[bar]'],
                                    'MyOtherModule' => ['[MyOtherModule].[baz]'],
                                    'MyThirdModule' => ['[MyThirdModule].[biz]'])
    module_group = database.add_module_group('zz', :modules => ['MyOtherModule','MyThirdModule'])
    assert_equal module_group.modules, ['MyOtherModule', 'MyThirdModule']

    Dbt::Config.default_up_dirs = ['.']

    create_table_sql('MyOtherModule', 'a')
    create_table_sql('MyThirdModule', 'b')

    mock.expects(:open).with(config, false).in_sequence(@s)
    mock.expects(:create_schema).with('MyOtherModule').in_sequence(@s)
    expect_create_table(mock, 'MyOtherModule', '', 'a')
    mock.expects(:create_schema).with('MyThirdModule').in_sequence(@s)
    expect_create_table(mock, 'MyThirdModule', '', 'b')
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.up_module_group(database.module_group_by_name('zz'))
  end

  def test_module_group_down
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    config = create_postgres_config({}, 'import' => base_postgres_config().merge('database' => 'IMPORT_DB'))

    db_scripts = create_dir("databases")
    database = create_db_definition(db_scripts,
                                    'MyModule' => ['[MyModule].[foo]', '[MyModule].[bar]'],
                                    'MyOtherModule' => ['[MyOtherModule].[baz]', '[MyOtherModule].[bark]'],
                                    'MyThirdModule' => ['[MyThirdModule].[biz]'])
    module_group = database.add_module_group('zz', :modules => ['MyOtherModule', 'MyThirdModule'])
    database.schema_overrides['MyThirdModule'] = 'My3rdSchema'
    assert_equal module_group.modules, ['MyOtherModule', 'MyThirdModule']

    Dbt::Config.default_up_dirs = ['.']
    Dbt::Config.default_down_dirs = ['Down2', 'Down3']

    create_table_sql('MyOtherModule/Down2', 'a')
    create_table_sql('MyThirdModule/Down3', 'b')

    mock.expects(:open).with(config, false).in_sequence(@s)

    expect_create_table(mock, 'MyThirdModule', 'Down3/', 'b')
    mock.expects(:drop_schema).with('My3rdSchema', ['[MyThirdModule].[biz]']).in_sequence(@s)

    expect_create_table(mock, 'MyOtherModule', 'Down2/', 'a')
    mock.expects(:drop_schema).with('MyOtherModule', ['[MyOtherModule].[bark]','[MyOtherModule].[baz]']).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.down_module_group(database.module_group_by_name('zz'))
  end

  def test_dump_database_to_fixtures
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    fixture_dir = create_dir("output_fixtures")

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    table_names = ['[MyModule].[tblTable1]', '[MyModule].[tblTable2]']
    module_name = 'MyModule'
    database = create_simple_db_definition(db_scripts, module_name, table_names)

    Dbt::Config.default_fixture_dir_name = 'fixturesXX'

    expected_table2_sql = "SELECT * FROM [MyModule].[tblTable2] ORDER BY ID"
    Object.const_set(:DUMP_SQL_FOR_MyModule_tblTable2, expected_table2_sql)

    begin
      mock.expects(:open).with(config, false).in_sequence(@s)
      Dbt.runtime.expects(:info).with("Dumping [MyModule].[tblTable1]").in_sequence(@s)
      mock.expects(:query).with("SELECT * FROM [MyModule].[tblTable1]").returns([{'ID' => 1}, {'ID' => 2}]).in_sequence(@s)
      Dbt.runtime.expects(:info).with("Dumping [MyModule].[tblTable2]").in_sequence(@s)
      mock.expects(:query).with(expected_table2_sql).returns([{'ID' => 1}, {'ID' => 2}]).in_sequence(@s)
      mock.expects(:close).with().in_sequence(@s)

      Dbt.runtime.dump_database_to_fixtures(database, fixture_dir)

      assert_file_exist("#{fixture_dir}/MyModule/fixturesXX/MyModule.tblTable1.yml")
      assert_file_exist("#{fixture_dir}/MyModule/fixturesXX/MyModule.tblTable2.yml")
    ensure
      Object.send(:remove_const, :DUMP_SQL_FOR_MyModule_tblTable2)
    end
  end

  def test_dump_database_to_fixtures_with_data_set
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    fixture_dir = create_dir("output_fixtures")

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    table_names = ['[MyModule].[tblTable1]']
    module_name = 'MyModule'
    database = create_simple_db_definition(db_scripts, module_name, table_names)
    data_set = 'foo'

    Dbt::Config.default_datasets_dir_name = 'dataset123'

    mock.expects(:open).with(config, false).in_sequence(@s)
    Dbt.runtime.expects(:info).with("Dumping [MyModule].[tblTable1]").in_sequence(@s)
    mock.expects(:query).with("SELECT * FROM [MyModule].[tblTable1]").returns([{'ID' => 1}, {'ID' => 2}]).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.dump_database_to_fixtures(database, fixture_dir, :data_set => data_set)

    assert_file_exist("#{fixture_dir}/MyModule/dataset123/foo/MyModule.tblTable1.yml")
  end

  def test_dump_database_to_fixtures_with_filter
    mock = Dbt::DbDriver.new
    Dbt.runtime.instance_variable_set("@db", mock)

    fixture_dir = create_dir("output_fixtures")

    config = create_postgres_config()

    db_scripts = create_dir("databases")
    table_names = ['[MyModule].[tblTable1]', '[MyModule].[tblTable2]']
    module_name = 'MyModule'
    database = create_simple_db_definition(db_scripts, module_name, table_names)
    filter = Proc.new {|t| t == '[MyModule].[tblTable1]'}

    Dbt::Config.default_fixture_dir_name = 'fixturesXX'

    mock.expects(:open).with(config, false).in_sequence(@s)
    Dbt.runtime.expects(:info).with("Dumping [MyModule].[tblTable1]").in_sequence(@s)
    mock.expects(:query).with("SELECT * FROM [MyModule].[tblTable1]").returns([{'ID' => 1}, {'ID' => 2}]).in_sequence(@s)
    mock.expects(:close).with().in_sequence(@s)

    Dbt.runtime.dump_database_to_fixtures(database, fixture_dir, :filter => filter)

    assert_file_exist("#{fixture_dir}/MyModule/fixturesXX/MyModule.tblTable1.yml")
  end

  def setup
    super
    @s = sequence('main')
  end

  def create_table_sql(dir, table_name)
    create_file("databases/#{dir}/#{table_name}.sql", "CREATE TABLE [#{table_name}]")
  end

  def create_fixture(module_name, table_name)
    create_file("databases/#{module_name}/#{Dbt::Config.default_fixture_dir_name}/#{module_name}.#{table_name}.yml", "1:\n  ID: 1\n")
  end

  def expect_create_table(mock, module_name, dirname, table_name, seq = true)
    Dbt.runtime.expects(:info).with("#{'%-15s' % module_name}: #{dirname}#{table_name}.sql").in_sequence(@s)
    mock.expects(:execute).with("CREATE TABLE [#{table_name}]", false).in_sequence(@s)
  end

  def expect_delete(mock, module_name, table_name)
    mock.expects(:execute).with("DELETE FROM [#{module_name}].[#{table_name}]", false).in_sequence(@s)
  end

  def expect_fixture(mock, module_name, table_name)
    Dbt.runtime.expects(:info).with("Fixture        : #{module_name}.#{table_name}").in_sequence(@s)
    mock.expects(:pre_fixture_import).with("[#{module_name}].[#{table_name}]").in_sequence(@s)
    mock.expects(:insert).with("[#{module_name}].[#{table_name}]", 'ID' => 1).in_sequence(@s)
    mock.expects(:post_fixture_import).with("[#{module_name}].[#{table_name}]").in_sequence(@s)
  end

  def expect_migrate(mock, database_key, migration_name, sql)
    Dbt.runtime.expects(:info).with("Migration: #{migration_name}.sql").in_sequence(@s)
    mock.expects(:execute).with(sql, false).in_sequence(@s)
    expect_mark_migration_as_run(mock, database_key, migration_name)
  end

  def expect_should_migrate(mock, database_key, migration_name, result)
    mock.expects(:"should_migrate?").with(database_key, migration_name).returns(result).in_sequence(@s)
  end

  def expect_mark_migration_as_run(mock, database_key, migration_name)
    mock.expects(:mark_migration_as_run).with(database_key, migration_name).in_sequence(@s)
  end

  def expect_default_table_import(mock, import_definition, module_name, table_name)
    expect_pre_table_import(mock, import_definition, module_name, table_name, 'D')
    mock.expects(:column_names_for_table).with("[#{module_name}].[#{table_name}]").returns(['[ID]']).in_sequence(@s)
    mock.expects(:execute).with("INSERT INTO DBT_TEST.[#{module_name}].[#{table_name}]([ID])\n  SELECT [ID] FROM IMPORT_DB.[#{module_name}].[#{table_name}]\n", true).in_sequence(@s)
    expect_post_table_import(mock, import_definition, module_name, table_name)
  end

  def expect_pre_table_import(mock, import_definition, module_name, table_name, import_type)
    mock.expects(:pre_table_import).with(import_definition, "[#{module_name}].[#{table_name}]").in_sequence(@s)
    Dbt.runtime.expects(:info).with("#{'%-15s' % module_name}: Importing #{module_name}.#{table_name} (By #{import_type})").in_sequence(@s)
  end

  def expect_post_table_import(mock, import_definition, module_name, table_name)
    mock.expects(:post_table_import).with(import_definition, "[#{module_name}].[#{table_name}]").in_sequence(@s)
  end

  def expect_delete_for_table_import(mock, module_name, table_name)
    Dbt.runtime.expects(:info).with("Deleting #{module_name}.#{table_name}").in_sequence(@s)
    expect_delete(mock, module_name, table_name)
  end

  def create_simple_db_definition(db_scripts, module_name, table_names)
    Dbt.add_database(:default) do |db|
      db.rake_integration = false
      db.modules = [module_name]
      db.table_map = {module_name => table_names}
      db.search_dirs = [db_scripts]
    end
  end

  def create_db_definition(db_scripts, table_map)
    Dbt.add_database(:default) do |db|
      db.rake_integration = false
      db.modules = table_map.keys
      db.table_map = table_map
      db.search_dirs = [db_scripts]
    end
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
