raise "Patch applied in latest version of buildr" unless Buildr::VERSION == '1.4.13'

module Buildr #:nodoc:
  module IntellijIdea
    class IdeaProject
      def add_web_facet(options = {})
        name = options[:name] || "Web"
        default_webroots = {}
        buildr_project.assets.paths.each { |p| default_webroots[p] = "/" }
        webroots = options[:webroots] || default_webroots
        default_deployment_descriptors = []
        ['web.xml', 'sun-web.xml', 'glassfish-web.xml', 'jetty-web.xml', 'geronimo-web.xml',
         'context.xml', 'weblogic.xml',
         'jboss-deployment-structure.xml', 'jboss-web.xml',
         'ibm-web-bnd.xml', 'ibm-web-ext.xml', 'ibm-web-ext-pme.xml'].
          each do |descriptor|
          webroots.each_pair do |path, relative_url|
            next unless relative_url == "/"
            d = "#{path}/WEB-INF/#{descriptor}"
            default_deployment_descriptors << d if File.exist?(d)
          end
        end
        deployment_descriptors = options[:deployment_descriptors] || default_deployment_descriptors

        add_facet(name, "web") do |f|
          f.configuration do |c|
            c.descriptors do |d|
              deployment_descriptors.each do |deployment_descriptor|
                d.deploymentDescriptor :name => File.basename(deployment_descriptor), :url => file_path(deployment_descriptor)
              end
            end
            c.webroots do |w|
              webroots.each_pair do |webroot, relative_url|
                w.root :url => file_path(webroot), :relative => relative_url
              end
            end
          end
          # Patch Start
          default_enable_jsf = webroots.keys.any?{|webroot| File.exist?("#{webroot}/WEB-INF/faces-config.xml")}
          # Patch End
          enable_jsf = options[:enable_jsf].nil? ? default_enable_jsf : options[:enable_jsf]
          enable_jsf = false if root_project.ipr? && root_project.ipr.version >= '13'
          f.facet(:type => 'jsf', :name => 'JSF') do |jsf|
            jsf.configuration
          end if enable_jsf
        end
      end
    end
  end
end