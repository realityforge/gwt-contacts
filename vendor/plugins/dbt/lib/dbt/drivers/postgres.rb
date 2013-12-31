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
  class PostgresDbConfig < JdbcDbConfig
    include Dbt::PostgresConfig

    def self.jdbc_driver_dependencies
      %w{postgresql:postgresql:jar:9.1-901.jdbc4}
    end

    def jdbc_driver
      'org.postgresql.Driver'
    end

    def jdbc_info
      info = java.util.Properties.new
      info.put('user', username) if username
      info.put('password', password) if password
      info
    end
  end

  class PostgresDbDriver < JdbcDbDriver
    include Dbt::Dialect::Postgres
  end
end
