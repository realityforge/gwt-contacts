require 'buildr/java/cobertura'

if Buildr::VERSION <= '1.4.6'
  module Buildr
    module Cobertura
      class << self
        attr_writer :report_dir

        def report_dir
          @report_dir || "reports/cobertura"
        end

        def report_to(file = nil)
          File.expand_path(File.join(*[report_dir, file.to_s].compact))
        end

        def data_file
          File.expand_path("#{report_dir}/cobertura.ser")
        end
      end
    end
  end


  namespace 'cobertura' do
    [:xml, :html].each do |format|
      desc "Run the test cases and produce code coverage reports"
      task format => ["instrument", "test"] do
        if Buildr.projects.detect { |project| !project.compile.sources.empty? }
          info "Creating test coverage reports in #{Buildr::Cobertura.report_to(format)}"
          Buildr.ant "cobertura" do |ant|
            ant.taskdef :resource=>"tasks.properties",
                        :classpath=>Buildr.artifacts(Buildr::Cobertura.dependencies).each(&:invoke).map(&:to_s).join(File::PATH_SEPARATOR)
            ant.send "cobertura-report", :destdir=>Buildr::Cobertura.report_to(format), :format=>format, :datafile=>Buildr::Cobertura.data_file do
              Buildr.projects.map(&:cobertura).map(&:sources).flatten.each do |src|
                ant.fileset :dir=>src.to_s if File.exist?(src.to_s)
              end
            end
          end
        end
      end
    end
  end
end

Buildr::Cobertura.report_dir = 'target/_reports/cobertura'
