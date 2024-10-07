# frozen_string_literal: true

module Kernel
  def loaded_packs
    @loaded_packs ||= []
  end

  def require_pack(path)
    path = path.to_path if path.respond_to? :to_path

    pack_paths = if File.extname(path).empty?
                   Rubyc.suffixes.map { |s| "#{path}#{s}" }
                 else
                   [path]
                 end

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

  def require_relative_pack(path)
    path = path.to_path if path.respond_to? :to_path

    relative_from = caller_locations(1..1).first
    relative_from_path = relative_from.absolute_path || relative_from.path

    pack_paths = if path.end_with?(*Rubyc.suffixes)
                   [path]
                 else
                   Rubyc.suffixes.map { |s| "#{path}#{s}" }
                 end

    pack_paths.each do |s|
      pack_path = File.expand_path("../#{s}", relative_from_path)
      if File.exist?(pack_path)
        load_pack(pack_path)
        break
      end
    end

    nil
  end

  def require_absolute_pack(path)
    path = path.to_path if path.respond_to? :to_path

    pack_paths = if path.end_with?(*Rubyc.suffixes)
                   [path]
                 else
                   Rubyc.suffixes.map { |s| "#{path}#{s}" }
                 end

    pack_paths.each do |pack_path|
      if File.exist?(pack_path)
        load_pack(pack_path)
        break
      end
    end
  end

  def load_pack(path)
    return if loaded_packs.include?(path)

    Rubyc.load(path)
    loaded_packs << path
  end
end
