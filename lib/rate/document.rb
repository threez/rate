module Rate
  class Document
    attr_accessor :buffer, :syntax, :source_view, :theme, :source_label, :notebook
    attr_writer :modified
    attr_reader :name, :path

    def initialize(name, path = nil)
      @name = name
      @path = path

      if block_given? then
        yield(self)
      end
    end

    def path=(new_path)
      @path = new_path
      self.name = File.basename(path)
    end

    def name=(new_name)
      @name = new_name
      @source_label.text = @name
    end

    def modified?
      @modified
    end

    def save()
      if modified?
        File.open(@path, "w") do |f|
          f.print @buffer.text
        end

        self.name = File.basename(@path)
        @modified = false

        # retry to get syntax highlighting
        if @syntax.nil?
          Document.syntax_for_document(self)
        end

        return true
      else
        return false
      end
    end

    def path_given?
      !@path.nil?
    end

    def empty?
      @buffer.text.size == 0
    end

    def toggle_syntax_highlighting
      @buffer.highlight = !@buffer.highlight?
    end

    def self.create_from_file(path, theme)
      source = File.open(path, "r") do |f|
        f.read
      end
      create(File.basename(path), source, theme, path)
    end

    def self.create_from_source_file(path, theme)
      document = create_from_file(path, theme)
      syntax_for_document(document)
      return document
    end

    def self.create(name, source, theme, path = nil)
      Document.new(name, path) do |document|
        document.buffer = Gtk::SourceBuffer.new()
        document.buffer.text = source
        document.theme = theme
      end
    end

    def self.syntax_for_document(document)
      syntax = SyntaxTheme.new(document.theme)
      lang = syntax.lang_for(File.extname(document.path))

      # do we have syntax highlighting?
      unless lang.nil?
        document.syntax = syntax
        document.buffer.language = lang
        document.buffer.highlight = true
      end
    end
  end
end
