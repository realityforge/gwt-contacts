require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rubygems/package_task'
require 'rake/testtask'

desc "Default Task"
task :default => :test

desc "Test Task"
Rake::TestTask.new do |t|
  files = FileList['test/helper.rb', 'test/test_*.rb']
  t.loader = :rake
  t.test_files = files
  t.libs << "."
  t.warning = true
end
