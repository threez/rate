module Rate
  class Document
    attr_accessor :name, :buffer, :syntax

    def initialize(name)
      @name = name
      @buffer = buffer
      if block_given? then
        yield(self)
      end
    end

    def self.create_from_file(path)
      source = File.open(path, "r") do |f|
        f.read
      end
      create(File.basename(path), source)
    end

    def self.create_from_source_file(path, theme)
      d = create_from_file(path)
      @syntax = SyntaxTheme.new(theme)
      lang = @syntax.lang_for(File.extname(path))
      d.buffer.language = lang
      d.buffer.highlight = true
      return d
    end

    def self.create(name, text)
      Document.new(name) do |d|
        d.buffer = Gtk::SourceBuffer.new()
        d.buffer.text = text
      end
    end
  end
end
