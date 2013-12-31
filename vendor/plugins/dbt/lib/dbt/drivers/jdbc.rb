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
  class JdbcDbConfig < Dbt::AbstractDbConfig
    def jdbc_driver
      raise NotImplementedError
    end

    def build_jdbc_url(options = {})
      raise NotImplementedError
    end

    def jdbc_info
      raise NotImplementedError
    end
  end

  class JdbcDbDriver < Dbt::BaseDbDriver
    def execute(sql, execute_in_control_database = false)
      raise "Can not execute statement when database connection is not open." unless open?
      current_database = nil
      if execute_in_control_database
        current_database = self.current_database
        select_database(nil)
      end
      statement = @connection.createStatement()
      success = false
      begin
        statement.executeUpdate(sql)
        success = true
      ensure
        puts "Failed SQL: #{sql}" unless success
        statement.close
        select_database(current_database) if execute_in_control_database
      end
    end

    def query(sql)
      statement = @connection.createStatement()
      statement.executeQuery(sql)
      column_names = []

      rs = statement.executeQuery(sql)
      meta_data = rs.getMetaData()
      (1..meta_data.columnCount).each do |index|
        column_names << meta_data.getColumnName(index)
      end

      results = []

      while rs.next()
        result = Dbt::OrderedHash.new

        column_names.each_with_index do |name, index|
          value = rs.getObject(index + 1)
          if value.java_kind_of?(java.sql.Clob)
            value = value.getSubString(1, value.length)
          end
          result[name] = value
        end
        results << result
      end
      rs.close
      statement.close
      results
    end

    def open(config, use_control_database)
      raise "Can not open database connection. Connection already open." if open?
      config.class.jdbc_driver_dependencies.each do |spec|
        begin
          dependency = ::Buildr.artifact(spec)
          dependency.invoke
          require dependency.to_s
        rescue NameError
          # Ignore as buildr not present
        end
      end

      require 'java'
      java.lang.Class.forName(config.jdbc_driver, true, java.lang.Thread.currentThread.getContextClassLoader) if config.jdbc_driver
      @connection = java.sql.DriverManager.getConnection(config.build_jdbc_url(:use_control_catalog => use_control_database), config.jdbc_info)
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
