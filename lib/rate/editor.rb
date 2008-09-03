require 'theme'
require 'syntax_theme'
require 'document'

module Rate
  class Editor
    TITLE = "Rate (RubyMate)"
    NAME = "Rate"
    
    attr_reader :theme

    def initialize
      @documents = []
      @theme = Theme.new("./themes/Railscasts.tmTheme")

      @notebook = create_nootbook()
      @chooser = create_file_chooser()
      @window = create_main_window(@notebook, @chooser)
    end

    def add_document(document)
      @documents << document

      source = create_source_view(@theme)
      source.buffer = document.buffer

      scroll = Gtk::ScrolledWindow.new
      scroll.add(source)

      button = Gtk::Button.new(" X ")
      button.signal_connect("clicked") { remove_document document }

      box = Gtk::HBox.new
      box.add button
      box.add Gtk::Label.new(document.name)
      box.show_all

      @notebook.append_page(scroll, box)
    end

    def remove_document(document)
      nr = @documents.index document
      @documents.delete document
      @notebook.remove_page(nr)
    end

    alias << add_document

    def show_all
      @window.show_all
    end

  private

    def create_file_chooser
      #chooser = Gtk::FileChooserWidget.new(Gtk::FileChooser::ACTION_OPEN)
      chooser = Gtk::Label.new("<filelist>")
      return chooser
    end

    def create_nootbook
      notebook = Gtk::Notebook.new
      notebook.show_border = false
      notebook.signal_connect("switch-page") { on_select_node(notebook) }
      notebook.signal_connect("select-page") { on_select_node(notebook) }
      return notebook
    end

    def create_main_window(notebook, chooser)
      window = Gtk::Window.new("Rade")
      window.signal_connect("delete-event") { Gtk::main_quit }

      hpaned = Gtk::HPaned.new

      #hpaned.set_size_request(200, -1)
      hpaned.pack1(chooser, true, false)
      hpaned.pack2(notebook, true, false)
      #frame1.set_size_request(50, -1)

      window.add(hpaned)
      window.set_default_size(800,600)
      return window
    end

    def create_source_view(theme)
      source = Gtk::SourceView.new
      source.show_line_numbers = true
      source.auto_indent = true
      source.indent_on_tab = true
      source.insert_spaces_instead_of_tabs = true
      source.tabs_width = 2
      source.margin = 80
      source.modify_fg(Gtk::StateType::NORMAL, Gdk::Color.parse(theme.setting.caret))
      source.modify_bg(Gtk::StateType::NORMAL, Gdk::Color.parse(theme.setting.invisibles))
      source.modify_base(Gtk::StateType::NORMAL, Gdk::Color.parse(theme.setting.background))
      source.modify_text(Gtk::StateType::NORMAL, Gdk::Color.parse(theme.setting.foreground))
      source.modify_base(Gtk::StateType::ACTIVE, Gdk::Color.parse(theme.setting.lineHighlight))
      source.modify_base(Gtk::StateType::PRELIGHT, Gdk::Color.parse(theme.setting.lineHighlight))
      source.modify_text(Gtk::StateType::SELECTED, Gdk::Color.parse(theme.setting.caret))
      source.modify_base(Gtk::StateType::SELECTED, Gdk::Color.parse(theme.setting.selection))

      fonts = ["Courier New", "Bitstream Vera Sans Mono", "Monaco"]
      source.modify_font Pango::FontDescription.new("#{fonts[1]} 9")
      return source
    end

    def on_select_node(notebook)
      #pp @documents
      document = @documents[notebook.page]
      @window.title = "#{NAME} - #{document.name}"
      #@source.buffer = document.buffer
    end
  end
end
