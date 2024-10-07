# frozen_string_literal: true

module Rubyc
  class Loader
    class << self
      def call(input_path)
        raise Error, "no such file #{input_path}" unless File.exist?(input_path)

        new(input_path).load
      end
    end

    def initialize(input_path)
      @input_path = input_path
    end

    def load
      byte_code = IO.binread @input_path
      instruction = RubyVM::InstructionSequence.load_from_binary byte_code
      instruction.eval
    end
  end
end
