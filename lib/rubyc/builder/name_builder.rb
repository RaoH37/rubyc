# frozen_string_literal: true

require 'fileutils'

module Rubyc
  class Builder
    class NameBuilder
      EXTENSION = '.rbc'

      class << self
        def call(input_path, output)
          new(input_path, output).generate
        end
      end

      def initialize(input_path, output)
        @input_path = input_path
        @output = output
        @binary_dir_path = Dir.pwd
        @binary_name = File.basename(@input_path, File.extname(@input_path))
      end

      def generate
        build unless @output.nil?
        File.join(@binary_dir_path, binary_extend_name)
      end

      private

      def binary_extend_name
        "#{@binary_name}_#{RUBY_VERSION}_#{Rubyc.version}#{EXTENSION}"
      end

      def build
        expanded_output = File.expand_path(@output)

        if File.directory?(expanded_output)
          @binary_dir_path = expanded_output
          return
        end

        last_path_node = File.basename(expanded_output, File.extname(expanded_output))

        if File.file?(expanded_output)
          File.unlik(expanded_output)
          @binary_dir_path = File.expand_path(File.dirname(expanded_output))
          @binary_name = last_path_node
          return
        end

        if last_path_node == File.basename(expanded_output)
          @binary_dir_path = File.expand_path(File.join(File.dirname(@output), last_path_node))
        else
          @binary_dir_path = File.expand_path(File.dirname(@output))
          @binary_name = last_path_node
        end

        FileUtils.mkdir_p @binary_dir_path
      end
    end
  end
end
