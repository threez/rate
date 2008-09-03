require 'plist'
require 'pp'
require 'ostruct'

module Rate
  class Theme
    TRANSLATION_TM_THEME = {
      "Keywords"                   => "Keyword",
      "Attribute@32@Definitions"   => "Library function", #NS
      "Definitions"                => "Function (definition)",
      "Pseudo@32@Variables"        => "Variable",
      "Module@32@Handlers"         => "Library function", #NS
      "Builtins"                   => "Number",
      "Class@32@Variables"         => "Constant (other variable)",
      "Instance@32@Variables"      => "Constant (built-in)",
      "Global@32@Variables"        => "Constant (other variable)",
      "Symbols"                    => "Constant (other variable)", #NS
      "RegExp@32@Variables"        => "Variable",
      "Constants"                  => "Constant",
      "Double@32@Quoted@32@String" => "String",
      "Single@32@Quoted@32@String" => "String",
      "Line@32@Comment"            => "Comment",
      "Multiline@32@Comment"       => "Comment"
    }
    attr_reader :name

    def initialize(path)
      @plist = Plist::parse_xml(path)
      @name = @plist["name"]
      @setting = OpenStruct.new(@plist["settings"].first["settings"])
    end

    def [](val)
      settings = nil
      @plist["settings"].each do |entry|
        if entry["name"] == val then
          settings = entry["settings"]
          break
        end
      end

      OpenStruct.new(settings) if settings
    end

    def setting
      @setting
    end
  end
end
