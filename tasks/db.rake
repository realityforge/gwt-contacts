def workspace_dir
  File.expand_path(File.dirname(__FILE__) + '/..')
end

$LOAD_PATH.insert(0, "#{workspace_dir}/vendor/plugins/dbt/lib")

require 'dbt'

Dbt::Config.environment = ENV['DB_ENV'] if ENV['DB_ENV']

Dbt::Config.driver = 'postgres'
Dbt::Config.config_filename = File.expand_path("#{workspace_dir}/config/database.yml")

def define_dbt_tasks(project)
  Dbt.database_for_key(:default).version = project.version
end

Dbt.add_database(:default) do |database|
  database.search_dirs = ["#{workspace_dir}/database/generated", "#{workspace_dir}/database"]
  database.enable_domgen(:Contacts, 'domgen:load', 'domgen:sql')
end
