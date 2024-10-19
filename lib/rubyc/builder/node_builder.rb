# frozen_string_literal: true

module Rubyc
  class Builder
    class NodeBuilder
      REQUIRE_REGEX = %r{(\s*|\t*)*(?<req>require(_relative)?)(\s+\(|\s+|\()\s*('|")(?<path>(\w|/)+)('|")}
      REQUIRE_METHOD_NAME = 'require'
      REQUIRE_RELATIVE_METHOD_NAME = 'require_relative'
      REQUIRE_PACK_METHOD_NAME = 'require_pack'

      attr_reader :nodes, :abs_path

      def initialize(paths, abs_path)
        @abs_path = abs_path
        @nodes = []

        paths.each do |path|
          Node.new(self, nil, path)
        end
      end

      def <<(node)
        raise Error, 'Only Node can be added' unless node.is_a?(Node)

        @nodes << node unless @nodes.include?(node)
      end

      class Node
        include Comparable

        attr_reader :path, :builder, :converted_content

        def initialize(builder, parent, path)
          @builder = builder
          @parent = parent
          @path = path

          @builder << self

          @dir_path = File.dirname @path

          build
        end

        def relative_binary_path
          @relative_binary_path ||= File.join(File.dirname(relative_path), binary_name)
        end

        def binary_name
          File.basename(relative_path, File.extname(relative_path)) << RUBYC_EXTENSION
        end

        def relative_path
          @relative_path ||= @path.sub(@builder.abs_path, '').tap do |str|
            str[0] = '' if str[0] == '/'
          end
        end

        def <=>(other)
          @path <=> other.path
        end

        def build
          children_node_paths = []
          converted_lines = []

          File.read(@path).each_line do |line|
            line.chomp!

            if (require_match_result = line.match(REQUIRE_REGEX))
              r_path_full = extract_require_match(require_match_result[:req], require_match_result[:path])

              if File.file?(r_path_full)
                children_node_paths << r_path_full

                converted_lines << if require_match_result[:req] == REQUIRE_RELATIVE_METHOD_NAME
                                     line.sub!(REQUIRE_RELATIVE_METHOD_NAME, REQUIRE_PACK_METHOD_NAME)
                                     line.sub!(require_match_result[:path],
                                               r_path_full.sub(@builder.abs_path, '')[1..-4])
                                     line
                                   else
                                     line.sub(REQUIRE_METHOD_NAME, REQUIRE_PACK_METHOD_NAME)
                                   end
              else
                converted_lines << line
              end
            else
              converted_lines << line
            end
          end

          @converted_content = converted_lines.join("\n")

          children_node_paths.each do |child_node_path|
            Node.new(@builder, self, child_node_path)
          end
        end

        def extract_require_match(r_type, r_path)
          r_path_with_extension = if r_path.end_with?(RUBY_EXTENSION)
                                    r_path
                                  else
                                    "#{r_path}#{RUBY_EXTENSION}"
                                  end

          require_full_path(r_type, r_path_with_extension)
        end

        def require_full_path(r_type, r_path_with_extension)
          if r_type == REQUIRE_RELATIVE_METHOD_NAME
            File.join(@dir_path, r_path_with_extension)
          else
            File.join(@builder.abs_path, r_path_with_extension)
          end
        end

        def to_s
          %(#<Rubyc::Builder::NodeBuilder path=#{@path}>)
        end
      end
    end
  end
end
