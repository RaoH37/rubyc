# frozen_string_literal: true

require_relative 'builder/file_builder'
require_relative 'builder/name_builder'

module Rubyc
  class Builder
    class << self
      def call(input_path, **options)
        raise Error, "no such file #{input_path}" unless File.exist?(input_path)

        new(input_path, **options).generate
      end
    end

    def initialize(input_path, output: nil)
      @input_path = input_path
      @output = output
    end

    def generate
      byte_code = FileBuilder.new(@input_path).to_bytes
      File.binwrite binary_path, byte_code.to_binary
      binary_path
    end

    def binary_path
      @binary_path ||= NameBuilder.call(@input_path, @output)
    end
  end
end
