# frozen_string_literal: true

require 'fileutils'

module Rubyc
  class Builder
    class NameBuilder
      class << self
        def call(package_name, record_dir_path)
          new(package_name, record_dir_path).generate
        end
      end

      def initialize(package_name, record_dir_path)
        @package_name = package_name
        @record_dir_path = record_dir_path
      end

      def generate
        dist_path.tap do |path|
          FileUtils.rm_rf path if File.exist? path
          FileUtils.mkdir_p path
          Rubyc.logger.debug "create dist folder=#{path}"
        end
      end

      private

      def dist_path
        File.join((@record_dir_path || Dir.pwd), 'dist', package_full_name)
      end

      def package_full_name
        "#{@package_name}_#{suffix}"
      end

      def suffix
        delimiter = '.'
        "#{RUBY_VERSION.split(delimiter)[0..1].join(delimiter)}_#{Rubyc.version.split(delimiter)[0..1].join(delimiter)}"
      end
    end
  end
end
