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

class Dbt
  class MssqlDbConfig < JdbcDbConfig
    include Dbt::SqlServerConfig

    def self.jdbc_driver_dependencies
      %w(net.sourceforge.jtds:jtds:jar:1.2.7)
    end

    def jdbc_driver
      "net.sourceforge.jtds.jdbc.Driver"
    end

    def jdbc_info
      info = java.util.Properties.new
      info.put('user', username) if username
      info.put('password', password) if password
      info
    end
  end

  class MssqlDbDriver < JdbcDbDriver
    include Dbt::Dialect::SqlServer
  end
end
