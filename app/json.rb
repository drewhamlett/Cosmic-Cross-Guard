module Json
  def self.to_json(obj, **opts)
    defaults = {
      indent: 4,
      keep_sym: false
    }
    opts = defaults.merge opts

    case obj
    when Array
      return "[]" if obj.empty?
      str = obj.map { |v| to_json(v, **opts) }
      return "[\n#{str.join(",\n")}".indent_lines(opts[:indent]) << "\n]" if opts[:indent]
      "[#{str.join ","}]"
    when Hash
      return "{}" if obj.empty?
      str = obj.map { |k, v| "#{to_json(k, **opts)}: #{to_json(v, **opts)}" }
      return "{\n#{str.join(",\n")}".indent_lines(opts[:indent]) << "\n}" if opts[:indent]
      "{#{str.join ","}}"
    when String
      obj.quote
    when Symbol
      return obj.inspect.quote if opts[:keep_sym]
      obj.to_s.quote
    when NilClass
      "null"
    else
      obj.to_s
    end
  end
end
