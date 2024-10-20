# frozen_string_literal: true

module Rubyc
  class Builder
    class FileBuilder
      def initialize(node, package_path, node_relative_paths)
        @node = node
        @node_relative_paths = node_relative_paths
        @binary_path = File.join(package_path, node.relative_binary_path)
      end

      def generate
        FileUtils.mkdir_p File.dirname(@binary_path)
        Rubyc.logger.debug "create binary file=#{@binary_path}"
        File.binwrite @binary_path, to_bytes
      end

      def to_bytes
        seq = RubyVM::InstructionSequence.compile(@node.converted_content)
        seq.to_binary
      end
    end
  end
end
