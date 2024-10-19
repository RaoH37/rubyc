# frozen_string_literal: true

require_relative 'file_builder'

module Rubyc
  class Builder
    class FilesBuilder
      def initialize(nodes, package_path)
        @nodes = nodes
        @package_path = package_path
      end

      def generate
        @nodes.each do |node|
          FileBuilder.new(node, @package_path, @nodes.map(&:relative_path)).generate
        end
      end
    end
  end
end
