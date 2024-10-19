# frozen_string_literal: true

module Rubyc
  RUBY_EXTENSION = '.rb'
  RUBYC_EXTENSION = '.rbc'

  class Error < StandardError; end

  class << self
    def version = File.read(File.expand_path('../RUBYC_VERSION', __dir__)).strip

    def suffixes = ['.rbc']

    def load(input_path, load_path: nil)
      require_relative 'rubyc/loader' unless defined?(Rubyc::Loader)

      load_path ||= File.dirname(input_path)
      $LOAD_PATH.unshift(load_path) unless $LOAD_PATH.include?(load_path)

      Loader.call(input_path)
      true
    rescue StandardError => e
      puts "[ERROR] input_path=#{input_path} error=#{e.message}"
      false
    end

    def generate(input_path, package_name: nil, record_dir_path: Dir.pwd)
      require_relative 'rubyc/builder' unless defined?(Rubyc::Builder)
      Builder.call(input_path, package_name: package_name, record_dir_path: record_dir_path)
    end
  end
end
