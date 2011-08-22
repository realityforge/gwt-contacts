workspace_dir = File.expand_path(File.dirname(__FILE__) + "/..")

$LOAD_PATH.unshift(File.expand_path("#{workspace_dir}/../domgen/lib"))

require 'domgen'

Domgen::LoadSchema.new("#{workspace_dir}/architecture.rb")

Domgen::Logger.level = ::Logger::DEBUG
#Domgen::Xmi::GenerateXMITask.new(:contacts, "xmi", "#{workspace_dir}/target/xmi/contacts.xmi")

def define_persistence_unit(project, repository_key)
  base_generated_dir = project._(:target, :generated, "main/jpa")

  task = Domgen::GenerateTask.new(repository_key, "jpa", [:jpa_model, :jpa_ejb], base_generated_dir) do |t|
    t.description = 'Generates the Java code for the persistent objects'
  end

  java_dir = "#{base_generated_dir}/java"
  file(java_dir => [task.task_name])
  project.compile.from java_dir
end

def define_services_unit(project, repository_key)
  base_generated_dir = project._(:target, :generated, "main/services")

  task = Domgen::GenerateTask.new(repository_key, "ejb", [:ejb], base_generated_dir) do |t|
    t.description = 'Generates the EJB Service interfaces'
  end

  java_dir = "#{base_generated_dir}/java"
  file(java_dir => [task.task_name])
  project.compile.from java_dir
end
