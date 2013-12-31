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

  @@cache = Cache.new
  @@repository = Repository.new
  @@runtime = Runtime.new

  def self.cache
    @@cache
  end

  def self.repository
    @@repository
  end

  def self.runtime
    @@runtime
  end

  def self.database_for_key(database_key)
    self.repository.database_for_key(database_key)
  end

  def self.configuration_for_key(database_key, env = Dbt::Config.environment)
    self.runtime.configuration_for_database(database_for_key(database_key), env)
  end

  def self.database_keys
    self.repository.database_keys
  end

  def self.add_database(database_key, options = {}, &block)
    database = @@repository.add_database(database_key, options, &block)

    define_tasks_for_database(database) if database.enable_rake_integration?

    database
  end

  def self.remove_database(database_key)
    self.repository.remove_database(database_key)
  end
end
