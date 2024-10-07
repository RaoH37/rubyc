# frozen_string_literal: true

module Rubyc
  class Error < StandardError; end

  class << self
    def version = File.read(File.expand_path('../RUBYC_VERSION', __dir__)).strip

    def suffixes = ['.rbc']

    def load(input_path)
      require_relative 'rubyc/loader' unless defined?(Rubyc::Loader)
      Loader.call(input_path)
    end

    def generate(input_path, output: nil)
      require_relative 'rubyc/builder' unless defined?(Rubyc::Builder)
      Builder.call(input_path, output: output)
    end
  end
end
