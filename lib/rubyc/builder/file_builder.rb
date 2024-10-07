# frozen_string_literal: true

require 'tempfile'

module Rubyc
  class Builder
    class FileBuilder
      REQUIRE_REGEX = /(\s*|\t*)*require(_relative)?(\s+\(|\s+|\()/
      REQUIRE_REPLACE_REGEX = /require(_relative)?/
      RUBY_EXTENSION = '.rb'

      # TODO: pouvoir passer en options la liste des fichiers à compiler dans le bon ordre

      def initialize(input_path)
        @input_path = input_path
      end

      def to_bytes
        build_combinated_file
        combinated_file.rewind
        bytes = RubyVM::InstructionSequence.compile_file combinated_file.path
        combinated_file.close
        combinated_file.unlink
        bytes
      end

      private

      def build_combinated_file
        files_to_compile_paths.each do |path|
          puts "pack #{path}"

          File.read(path).each_line do |line|
            next if compiled_require_dep?(line)

            combinated_file.write line
          end
        end
      end

      def compiled_require_dep?(line)
        return false unless line.match?(REQUIRE_REGEX)

        required_dep = File.basename(eval(line.sub(REQUIRE_REPLACE_REGEX, '')))
        required_dep << RUBY_EXTENSION unless required_dep.end_with?(RUBY_EXTENSION)
        files_to_compile_paths.find { |path| path.end_with?(required_dep) }
      end

      def combinated_file
        @combinated_file ||= Tempfile.new(File.basename(@input_path, File.extname(@input_path)))
      end

      def files_to_compile_paths
        # separator = '/'
        # @files_to_compile_paths ||= Dir[dir_pattern_search].sort do |a, b|
        #   a.split(separator).length <=> b.split(separator).length
        # end.sort do |a, b|
        #   a <=> b if a.split(separator).length == b.split(separator).length
        # end

        @files_to_compile_paths ||= Dir[dir_pattern_search].group_by do |path|
          path.split('/').length
        end.sort.map do |_, paths|
          paths.sort
        end.flatten
      end

      def dir_pattern_search
        return @input_path if File.file?(@input_path)

        File.join(@input_path, '**/*.rb')
      end
    end
  end
end
