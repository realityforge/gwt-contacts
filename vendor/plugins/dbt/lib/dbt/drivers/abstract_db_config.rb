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
  class AbstractDbConfig < Dbt::DbConfig

    def initialize(key, options)
      ignore_elements = options.delete('ignore_elements') || []
      ignore_elements.each do |element|
        options.delete(element)
      end
      @key = key
      @no_create = nil
      super(options)
    end

    attr_reader :key
    attr_accessor :database
    attr_accessor :host
    attr_writer :port
    attr_accessor :username
    attr_accessor :password

    def catalog_name
      self.database
    end

    def no_create=(no_create)
      if no_create.nil?
        @no_create = nil
      else
        raise "no_create must be true or false" unless ['true', 'false'].include?(no_create.to_s)
        @no_create = no_create.to_s == 'true'
      end
    end

    def no_create?
      @no_create.nil? ? Dbt::Config.default_no_create? : @no_create
    end
  end
end
