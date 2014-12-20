$LOAD_PATH.insert(0, File.expand_path("#{File.dirname(__FILE__)}/../vendor/plugins/dbt/lib"))

require 'dbt'

Dbt::Config.environment = ENV['DB_ENV'] if ENV['DB_ENV']

Dbt::Config.driver = 'postgres'
Dbt::Config.config_filename = File.expand_path('config/database.yml')

Dbt.add_database(:default) do |database|
  database.search_dirs = %w(database/generated database)
  database.enable_domgen
end
