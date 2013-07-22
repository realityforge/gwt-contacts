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
  class PgDbConfig < AbstractDbConfig
    include Dbt::PostgresConfig
  end

  class PgDbDriver < Dbt::BaseDbDriver
    include Dbt::Dialect::Postgres

    def open(config, use_control_database)
      raise "Can not open database connection. Connection already open." if open?

      database = use_control_database ? CONTROL_DATABASE : config.catalog_name

      require 'pg'

      @connection = ::PG.connect(:host => config.host,
                                 :port => config.port,
                                 :dbname => database,
                                 :user => config.username,
                                 :password => config.password)
    end

    def execute(sql, execute_in_control_database = false)
      raise "Can not execute statement when database connection is not open." unless open?
      current_database = nil
      if execute_in_control_database
        current_database = self.current_database
        select_database(nil)
      end
      success = false
      begin
        @connection.exec(sql)
        success = true
      ensure
        puts "Failed SQL: #{sql}" unless success
        select_database(current_database) if execute_in_control_database
      end
    end

    def query(sql)
      rs = @connection.exec(sql)

      return [] if rs.ntuples == 0

      results = []

      rs.each do |rs_hash|
        result = Dbt::OrderedHash.new

        rs_hash.each do |key, value|
          result[key] = value
        end
        results << result
      end
      results
    end

    def close
      if open?
        @connection.close() rescue Exception
        @connection = nil
      end
    end

    protected

    def open?
      !@connection.nil?
    end
  end
end
