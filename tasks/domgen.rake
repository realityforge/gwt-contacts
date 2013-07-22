workspace_dir = File.expand_path(File.dirname(__FILE__) + "/..")

$LOAD_PATH.unshift(File.expand_path("#{workspace_dir}/vendor/plugins/domgen/lib"))

require 'domgen'

Domgen::LoadSchema.new("#{workspace_dir}/architecture.rb")

Domgen::Sql.dialect = Domgen::Sql::PgDialect
Domgen::GenerateTask.new(:Contacts, "sql", [:pgsql], "#{workspace_dir}/database/generated")
