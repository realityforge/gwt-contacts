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
  class CachedPackage
    attr_reader :filename
    attr_reader :files

    def initialize(filename)
      @filename = filename
      @files = []
      require 'zip/zip'
      require 'zip/zipfilesystem'
      Zip::ZipFile.foreach(filename) do |entry|
        @files << entry.name[5, entry.name.length - 5] if entry.file? && entry.name =~ /^data\/.*$/
      end
    end

    def contents(filename)
      raise "Unknown filename #{filename} for package #{self.filename}" unless self.files.include?(filename)
      Zip::ZipFile.open(self.filename) do |zipfile|
        return zipfile.read "data/#{filename}"
      end
    end
  end

  class Cache
    def initialize
      reset
    end

    def reset
      @package_cache = {}
    end

    def package(filename)
      cache = @package_cache[filename]
      unless cache
        cache = CachedPackage.new(filename)
        @package_cache[filename] = cache
      end
      cache
    end
  end
end
