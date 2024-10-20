# frozen_string_literal: true

require 'logger'

module Rubyc
  RUBY_EXTENSION = '.rb'
  RUBYC_EXTENSION = '.rbc'

  class Error < StandardError; end

  class << self
    def version = File.read(File.expand_path('../RUBYC_VERSION', __dir__)).strip

    def suffixes = ['.rbc'].freeze

    def load(input_path, load_path: nil)
      require_relative 'rubyc/loader' unless defined?(Rubyc::Loader)

      input_path = input_path.to_path if input_path.respond_to?(:to_path)
      load_path = load_path.to_path if load_path.respond_to?(:to_path)

      logger.debug "load input_path=#{input_path} load_path=#{load_path}"

      load_path ||= File.dirname(input_path)
      $LOAD_PATH.unshift(load_path) unless $LOAD_PATH.include?(load_path)

      Loader.call(input_path)
      true
    rescue Error => e
      logger.error "input_path=#{input_path} error=#{e.message}"
      false
    end

    def generate(input_path, package_name: nil, record_dir_path: Dir.pwd)
      require_relative 'rubyc/builder' unless defined?(Rubyc::Builder)

      input_path = input_path.to_path if input_path.respond_to?(:to_path)
      record_dir_path = record_dir_path.to_path if record_dir_path.respond_to?(:to_path)

      Builder.call(input_path, package_name: package_name, record_dir_path: record_dir_path)
    end

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.level = Logger::INFO
        log.formatter = proc do |severity, _datetime, _progname, msg|
          "#{severity} - #{msg}\n"
        end
      end
    end
  end
end
