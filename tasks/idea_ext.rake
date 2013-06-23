# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with this
# work for additional information regarding copyright ownership.  The ASF
# licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.

raise "Patch applied in the lastest version of buildr" unless Buildr::VERSION == '1.4.12'

class Buildr::IntellijIdea::IdeaModule
  def add_gwt_facet(modules = {}, options = {})
    name = options[:name] || "GWT"
    detected_gwt_version = nil
    if options[:gwt_dev_artifact]
      a = Buildr.artifact(options[:gwt_dev_artifact])
      a.invoke
      detected_gwt_version = a.to_s
    end

    settings =
      {
        :webFacet => "Web",
        :compilerMaxHeapSize => "512",
        :compilerParameters => "-draftCompile -localWorkers 2 -strict",
        :gwtScriptOutputStyle => "PRETTY"
      }.merge(options[:settings] || {})

    buildr_project.compile.dependencies.each do |d|
      if d.to_s =~ /\/com\/google\/gwt\/gwt-dev\/(.*)\//
        detected_gwt_version = d.to_s
        break
      end
    end unless detected_gwt_version

    if detected_gwt_version
      settings[:gwtSdkUrl] = resolve_path(File.dirname(detected_gwt_version))
      settings[:gwtSdkType] = "maven"
    else
      settings[:gwtSdkUrl] = "file://$GWT_TOOLS$"
    end

    add_facet(name, "gwt") do |f|
      f.configuration do |c|
        settings.each_pair do |k, v|
          c.setting :name => k.to_s, :value => v.to_s
        end
        c.packaging do |d|
          modules.each_pair do |k, v|
            d.module :name => k, :enabled => v
          end
        end
      end
    end
  end
end
