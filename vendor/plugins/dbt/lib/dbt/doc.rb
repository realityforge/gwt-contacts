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
  class DbDoc
    # Define file tasks that will transform sql documentation from the
    # source directory to the target directory. The method will return
    # a list of the target files that will be created. The tool will
    # skip a directory if target == source as it can be difficult to
    # track and may be removed on clean
    def self.define_doc_tasks(source_directory, target_directory)
      target_files = []
      if File.expand_path(source_directory) != File.expand_path(target_directory)
        find_source_files(source_directory).collect do |src_file|
          # source file name with the source_directory path removed from its start
          src_file_name = src_file.to_s.gsub(/^#{source_directory.to_s}/, "")

          target_file = File.expand_path(target_directory + src_file_name.gsub(/\.sql$/, "_Documentation.sql"))

          file(target_file => [src_file]) do
            File.open(src_file) do |f|
              sql = f.readlines.join
              parsed_doc_models = []
              parse_sql_doc(sql, parsed_doc_models)
              generate_doc(target_file, parsed_doc_models)
            end
          end

          target_files << target_file
        end
      end

      target_files
    end

    private

    # Class holding documentation info for a given function or stored procedure
    class DocModel

      attr_accessor :full_object_name
      attr_accessor :object_doc
      attr_accessor :object_type
      attr_accessor :param_docs

      def initialize
        @param_docs = {}
      end

      def add_param_doc(p_name, p_doc)
        @param_docs[p_name] = p_doc
      end

      def object_name
        dot_index = full_object_name.index(".")
        if dot_index
          full_object_name[dot_index + 1, full_object_name.length]
        else
          full_object_name
        end
      end

      def schema_name
        dot_index = full_object_name.index(".")
        if dot_index
          full_object_name[0, dot_index]
        else
          "dbo"
        end
      end

      def to_s
        @full_object_name + ", " + @object_doc
      end
    end

    # Parses the given text file and fills the parse_models with DocModel
    # instances corresponding to all the documented functions and stored procedures
    # found in the file
    def self.parse_sql_doc(text, parsed_models)
      regexp = /(\/\*\*.*?\*\/)(\s*create\s+(procedure|function|type|view)\s+)([a-zA-Z_\.]+)/mi
      match = regexp.match(text)

      return if !match

      comment_block = Regexp.last_match(1)
      create_stmt = Regexp.last_match(2)
      obj_type = Regexp.last_match(3)
      obj_name = Regexp.last_match(4)

      # strip the trailing */
      comment_block.gsub!(/\*\/\s*$/, "")

      # strip the leading /**
      comment_block.gsub!(/^\/\*\*/, "")

      # strip leading blank spaces for all lines
      comment_block.gsub!(/^\s*\*/, "")

      comment_xml = "<root>" + comment_block + "</root>"

      doc_model = DocModel.new
      doc_model.full_object_name = obj_name
      doc_model.object_type = obj_type.upcase.strip

      xml_doc = REXML::Document.new(comment_xml)
      root = xml_doc.root

      comment_desc = ""

      root.elements.each("//description") { |e| comment_desc = comment_desc + e.text.strip.gsub(/'/, "''") }

      doc_model.object_doc = comment_desc

      root.elements.each("//param") do |p|
        param_name = p.attributes["name"]
        doc_model.add_param_doc(param_name, p.text.strip.gsub(/'/, "''"))
      end

      parsed_models.push(doc_model)

      # remainder of the text file
      remainder = text[text.index(create_stmt + obj_name) + create_stmt.length + obj_name.length, text.length]

      # parse the remainder of the text file
      parse_sql_doc(remainder, parsed_models)

    end

    def self.generate_doc(target_file_name, doc_models)
      FileUtils.mkdir_p File.dirname(File.expand_path(target_file_name))

      # store all the doc models in the target_file_name
      # blank file if no documentation. Stops the need to keep re-running task
      File.open(target_file_name, 'wb') do |f|
        doc_models.each do |model|
          f.write <<SQL
EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = '#{trim_doc(model.object_doc)}',
  @level0type = N'SCHEMA', @level0name = '#{model.schema_name}',
  @level1type = N'#{model.object_type}', @level1name = '#{model.object_name}';
GO
SQL

          # only functions and procedures have parameters
          return if model.object_type == 'VIEW' || model.object_type == 'TYPE'

          model.param_docs.each do |param, doc|
            f.write <<SQL
EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = '#{trim_doc(doc)}',
  @level0type = N'SCHEMA', @level0name = '#{model.schema_name}',
  @level1type = N'#{model.object_type}', @level1name = '#{model.object_name}',
  @level2type = N'PARAMETER', @level2name = '@#{param}';
GO
SQL
          end
        end
      end
    end

    MAX_EXTENDED_PROPERTY_SIZE = 7000

    def self.trim_doc(doc)
      return (doc.length < MAX_EXTENDED_PROPERTY_SIZE) ? doc :  doc[0,MAX_EXTENDED_PROPERTY_SIZE - 3] + "..."
    end

    # do not include *_Documentation.sql files in the src files
    def self.find_source_files(source_directory)
      FileList["#{source_directory}/**/*.sql"].reject do |f|
        f_name = f.to_s
        /\_Documentation\.sql$/.match(f_name)
      end
    end
  end
end
