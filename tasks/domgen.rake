workspace_dir = File.expand_path(File.dirname(__FILE__) + "/..")

$LOAD_PATH.unshift(File.expand_path("#{workspace_dir}/../domgen/lib"))

require 'domgen'

Domgen::LoadSchema.new("#{workspace_dir}/architecture.rb")

Domgen::Logger.level = ::Logger::DEBUG
Domgen::Xmi::GenerateXMITask.new(:Contacts, "xmi", "#{workspace_dir}/target/xmi/contacts.xmi") do |t|
  t.description = 'Generates the xmi describing the repository'
end

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
  base_generated_dir = project._(:target, :generated, "main/ejb")

  task = Domgen::GenerateTask.new(repository_key, "ejb", [:ejb], base_generated_dir) do |t|
    t.description = 'Generates the EJB Service interfaces'
  end

  java_dir = "#{base_generated_dir}/java"
  file(java_dir => [task.task_name])
  project.compile.from java_dir
end

def define_gwt_services_unit(project, repository_key)
  base_generated_dir = project._(:target, :generated, "main/gwt")

  task = Domgen::GenerateTask.new(repository_key, "gwt", [:gwt_shared_service], base_generated_dir) do |t|
    t.description = 'Generates the Shared GWT Service interfaces'
  end

  java_dir = "#{base_generated_dir}/java"
  file(java_dir => [task.task_name])
  project.compile.from java_dir

  package(:sources).enhance [file(java_dir)]
  package(:sources).include "#{java_dir}/com"
end

def define_gwt_client_services(project, repository_key)
  base_generated_dir = project._(:target, :generated, "main/gwt")

  task = Domgen::GenerateTask.new(repository_key, "gwt", [:gwt_client_service], base_generated_dir) do |t|
    t.description = 'Generates the Client GWT Service support'
  end

  java_dir = "#{base_generated_dir}/java"
  file(java_dir => [task.task_name])
  project.compile.from java_dir

  package(:sources).enhance [file(java_dir)]
  package(:sources).include "#{java_dir}/com"
end

def define_gwt_servlets(project, repository_key)
  base_generated_dir = project._(:target, :generated, "main/gwt")

  task = Domgen::GenerateTask.new(repository_key, "gwt", [:gwt_server_service], base_generated_dir) do |t|
    t.description = 'Generates the GWT Service implementations'
  end

  java_dir = "#{base_generated_dir}/java"
  file(java_dir => [task.task_name])
  project.compile.from java_dir
end
