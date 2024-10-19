# frozen_string_literal: true

module Kernel
  def loaded_packs
    @loaded_packs ||= []
  end

  def require_pack(path)
    puts "require_pack=#{path}"
    path = path.to_path if path.respond_to? :to_path

    pack_paths = pack_paths_with_extensions(path)

    rp = nil

    pack_paths.each do |s|
      $LOAD_PATH.each do |lp|
        safe_lp = lp.dup
        pack_path = File.expand_path(File.join(safe_lp, s))

        if File.exist?(pack_path)
          rp = pack_path
          break
        end
      end

      break if rp
    end

    return unless rp

    load_pack(rp)
  end

  def load_pack(path)
    return if loaded_packs.include?(path)

    puts "load_pack=#{path}"

    Rubyc.load(path)
    loaded_packs << path
  end

  def pack_paths_with_extensions(path)
    if path.end_with?(*Rubyc.suffixes)
      [path]
    else
      Rubyc.suffixes.map { |s| "#{path}#{s}" }
    end
  end
end
