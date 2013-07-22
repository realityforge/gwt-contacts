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

  DatabaseNameFilter = ::Struct.new('DatabaseNameFilter', :pattern, :database_key, :optional)
  PropertyFilter = ::Struct.new('PropertyFilter', :pattern, :value)

  # Container class that is mixed into classes responsible for filtering sql files
  module FilterContainer
    def add_filter(&block)
      self.filters << block
    end

    def add_database_name_filter(pattern, database_key, optional = false)
      self.filters << DatabaseNameFilter.new(pattern, database_key, optional)
    end

    # Filter the SQL files replacing specified pattern with specified value
    def add_property_filter(pattern, value)
      self.filters << PropertyFilter.new(pattern, value)
    end

    # Makes the import scripts support statements such as
    #   ASSERT_ROW_COUNT(1)
    #   ASSERT_ROW_COUNT(SELECT COUNT(*) FROM Foo)
    #   ASSERT_UNCHANGED_ROW_COUNT()
    #   ASSERT(@Id IS NULL)
    #
    attr_writer :import_assert_filters

    def import_assert_filters?
      return @import_assert_filters unless @import_assert_filters.nil?
      !self.respond_to?(:imports) || self.imports.size > 0
    end

    attr_writer :database_environment_filter

    def database_environment_filter?
      @database_environment_filter.nil? ? false : @database_environment_filter
    end

    def filters
      @filters ||= []
    end

    def expanded_filters
      filters = []
      if import_assert_filters?
        filters << Proc.new do |sql|
          sql = sql.gsub(/ASSERT_UNCHANGED_ROW_COUNT\(\)/, <<SQL)
IF (SELECT COUNT(*) FROM @@TARGET@@.@@TABLE@@) != (SELECT COUNT(*) FROM @@SOURCE@@.@@TABLE@@)
BEGIN
  RAISERROR ('Actual row count for @@TABLE@@ does not match expected rowcount', 16, 1) WITH SETERROR
END
SQL
          sql = sql.gsub(/ASSERT_ROW_COUNT\((.*)\)/, <<SQL)
IF (SELECT COUNT(*) FROM @@TARGET@@.@@TABLE@@) != (\\1)
BEGIN
  RAISERROR ('Actual row count for @@TABLE@@ does not match expected rowcount', 16, 1) WITH SETERROR
END
SQL
          sql = sql.gsub(/ASSERT\((.+)\)/, <<SQL)
IF NOT (\\1)
BEGIN
  RAISERROR ('Failed to assert \\1', 16, 1) WITH SETERROR
END
SQL
          sql
        end
      end

      if database_environment_filter?
        filters << Proc.new do |sql|
          sql.gsub(/@@ENVIRONMENT@@/, Dbt::Config.environment.to_s)
        end
      end

      self.filters.each do |filter|
        if filter.is_a?(PropertyFilter)
          filters << Proc.new do |sql|
            sql.gsub(filter.pattern, filter.value)
          end
        elsif filter.is_a?(DatabaseNameFilter)
          filters << Proc.new do |sql|
            Dbt.runtime.filter_database_name(sql,
                                             filter.pattern,
                                             filter.database_key,
                                             Dbt::Config.environment,
                                             filter.optional)
          end
        else
          filters << filter
        end
      end

      filters
    end
  end
end
