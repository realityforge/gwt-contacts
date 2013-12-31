#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Dbt #nodoc
  class Buildr
    def self.add_idea_data_source(database_key, environment_key, buildr_project = nil)
      if buildr_project.nil? && ::Buildr.application.current_scope.size > 0
        buildr_project = ::Buildr.project(::Buildr.application.current_scope.join(':')) rescue nil
      end

      unless Dbt.repository.is_configuration_data_loaded?
        begin
          Dbt.repository.load_configuration_data
        rescue => e
          info("Unable to load configuration data from #{Dbt::Config.config_filename}, " +
                 "skipping addition of data source #{database_key} to idea. Cause: #{e}")
          return
        end
      end

      config =
        begin
          Dbt.configuration_for_key(database_key, environment_key)
        rescue => e
          info("Missing configuration #{database_key} in environment #{environment_key}, " +
                 "skipping addition of data source #{database_key} to idea. Cause: #{e}")
          return
        end

      name = config.key
      jdbc_url = config.build_jdbc_url
      username = config.username
      password = config.password

      if config.is_a?(Dbt::MssqlDbConfig) || config.is_a?(Dbt::TinyTdsDbConfig)
        buildr_project.ipr.add_sql_server_data_source(name, :url => jdbc_url, :username => username, :password => password)
      else
        buildr_project.ipr.add_postgres_data_source(name, :url => jdbc_url, :username => username, :password => password)
      end
    end
  end
end
