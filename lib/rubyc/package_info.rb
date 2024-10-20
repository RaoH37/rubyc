# frozen_string_literal: true

require 'openssl'

module Rubyc
  class PackageInfo
    def self.build(package_path)
      Builder.new(package_path).generate
    end

    class Builder
      DIGEST = 'SHA256'

      def initialize(package_path)
        @package_path = package_path
      end

      def generate
        File.open(File.join(@package_path, 'package.info'), 'w') do |file|
          file.write "ruby.version = #{RUBY_VERSION}\n"
          file.write "rubyc.version = #{Rubyc.version}\n"
          file.write "package.sum = {#{DIGEST}}#{package_sum}\n"
        end
      end

      def package_sum
        bytes = Dir[File.join(@package_path, '**/*.rbc')].sort.map do |path|
          File.read(path)
        end

        OpenSSL::Digest.new(DIGEST).hexdigest(bytes.join)
      end
    end
  end
end
