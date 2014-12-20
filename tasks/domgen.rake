workspace_dir = File.expand_path(File.dirname(__FILE__) + '/..')

$LOAD_PATH.unshift(File.expand_path("#{workspace_dir}/vendor/plugins/domgen/lib"))

require 'domgen'

Domgen::Build.define_load_task

Domgen::Build.define_generate_task([:pgsql], :key => :sql, :target_dir => "#{workspace_dir}/database/generated")
