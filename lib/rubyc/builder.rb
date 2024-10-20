# frozen_string_literal: true

require_relative 'builder/files_builder'
require_relative 'builder/name_builder'
require_relative 'builder/node_builder'
require_relative 'package_info'

module Rubyc
  class Builder
    class << self
      def call(input_path, **options)
        new(input_path, **options).generate
      end
    end

    def initialize(input_path, package_name: nil, record_dir_path: nil)
      raise Error, "no such file or directory #{input_path}" unless File.exist?(input_path)

      node_paths, dir_input_path = node_builder_settings(input_path)
      package_name ||= File.basename(dir_input_path)
      @package_path = NameBuilder.call(package_name, record_dir_path)
      @node_builder = NodeBuilder.new(node_paths, dir_input_path)
    end

    def generate
      FilesBuilder.new(@node_builder.nodes, @package_path).generate
      PackageInfo.build(@package_path)
      @package_path
    end

    private

    def node_builder_settings(input_path)
      if File.file?(input_path)
        [Dir[input_path], File.dirname(input_path)]
      else
        [Dir[File.join(input_path, '*.rb')], input_path]
      end
    end
  end
end
