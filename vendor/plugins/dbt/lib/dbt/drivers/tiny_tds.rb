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
  class TinyTdsDbConfig < AbstractDbConfig
    include Dbt::SqlServerConfig

    attr_writer :timeout

    def timeout
      @timeout || (60 * 5)
    end
  end

  class TinyTdsDbDriver < Dbt::BaseDbDriver
    include Dbt::Dialect::SqlServer

    def open(config, use_control_database)
      raise "Can not open database connection. Connection already open." if open?

      database = use_control_database ? 'msdb' : config.catalog_name

      require 'tiny_tds'

      @connection =
        TinyTds::Client.new(:host => config.host,
                            :port => config.port,
                            :appname => config.appname,
                            :database => database,
                            :timeout => config.timeout,
                            :username => config.username,
                            :password => config.password)
      # Configure the conenction so it is more ANSI-like
      [
        'SET CURSOR_CLOSE_ON_COMMIT ON',
        'SET ANSI_NULLS ON',
        'SET ANSI_PADDING ON',
        'SET ANSI_WARNINGS ON',
        'SET ARITHABORT ON',
        'SET CONCAT_NULL_YIELDS_NULL ON',
        'SET QUOTED_IDENTIFIER ON',
        'SET NUMERIC_ROUNDABORT OFF'
      ].each do |sql|
        execute(sql, false)
      end
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
        @connection.execute(sql).do
        success = true
      ensure
        puts "Failed SQL: #{sql}" unless success
        select_database(current_database) if execute_in_control_database
      end
    end

    def query(sql)
      rs = @connection.execute(sql)

      results = []

      rs.each(:cache_rows => false) do |row|
        # Each row is now an array of values ordered by #fields.
        # Rows are yielded and forgotten about, freeing memory.
        results << row
      end
      rs.cancel
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
