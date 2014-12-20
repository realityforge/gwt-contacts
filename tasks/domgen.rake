$LOAD_PATH.unshift(File.expand_path("#{File.dirname(__FILE__)}/../vendor/plugins/domgen/lib"))

require 'domgen'

Domgen::Build.define_load_task

Domgen::Build.define_generate_task([:pgsql], :key => :sql, :target_dir => 'database/generated')
