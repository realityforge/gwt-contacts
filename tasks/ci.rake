task 'ci:setup' do
  ENV['TEST'] = 'all'
  Dbt::Config.environment = 'test'
  Dbt::Config.config_filename = ENV['DB_CONFIG'] || 'config/ci-database.yml'
  Dbt.repository.load_configuration_data

  jdbc_url = Dbt.configuration_for_key(:default).build_jdbc_url(:credentials_inline => true)

  Buildr.project('gwt-contacts:server').test.using :properties => {'test.db.url' => jdbc_url}
end

task 'ci:package' => %w(ci:setup clean domgen:all dbt:create test package dbt:drop)
