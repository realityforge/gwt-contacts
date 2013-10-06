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

  # Base class used for elements configurable via options
  class ConfigElement

    def initialize(options, &block)
      self.options = options
      yield self if block_given?
    end

    def options=(options)
      options.each_pair do |k, v|
        keys = k.to_s.split('.')
        target = self
        keys[0, keys.length - 1].each do |target_accessor_key|
          target = target.send target_accessor_key.to_sym
        end
        begin
          target.send "#{keys.last}=", v
        rescue NoMethodError
          raise "Attempted to configure property \"#{keys.last}\" on #{self.class} but property does not exist."
        end
      end
    end
  end

  # Base class used for named elements configurable via options
  class BaseElement < ConfigElement
    attr_reader :key

    def initialize(key, options, &block)
      @key = key
      super(options)
    end
  end

  # Base Class used for sub-elements of database
  class DatabaseElement < BaseElement

    def initialize(database, key, options, &block)
      @database = database
      super(key, options, &block)
    end

    attr_reader :database
  end
end
