module Rate
  module EditorFactory
    FILEPANE_MINIMUM_WIDTH = 200

    def create_key_bindings(window)
      Gtk::AccelMap.add_entry("<Rate>/new",Gdk::Keyval::GDK_N, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry("<Rate>/save",Gdk::Keyval::GDK_S, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry("<Rate>/open",Gdk::Keyval::GDK_O, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry("<Rate>/close",Gdk::Keyval::GDK_W, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry("<Rate>/quit",Gdk::Keyval::GDK_Q, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry("<Rate>/toggle_file_pane",Gdk::Keyval::GDK_P, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry("<Rate>/zoom_in",Gdk::Keyval::GDK_plus, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry("<Rate>/zoom_out",Gdk::Keyval::GDK_minus, Gdk::Window::CONTROL_MASK)

      ag = Gtk::AccelGroup.new
      ag.connect("<Rate>/new") { create_new_document }
      ag.connect("<Rate>/save") { save_document(current_document) }
      ag.connect("<Rate>/open") { open_document_chooser() }
      ag.connect("<Rate>/close") { remove_document(current_document) }
      ag.connect("<Rate>/quit") { quit_editor }
      ag.connect("<Rate>/toggle_file_pane") { toggle_file_pane }
      ag.connect("<Rate>/zoom_in") { increase_editor_font }
      ag.connect("<Rate>/zoom_out") { decrease_editor_font }
      return ag
    end

    def create_file_chooser
      chooser = FilePane.new(self)
      scroll = Gtk::ScrolledWindow.new
      scroll.add(chooser)
      scroll.set_size_request(FILEPANE_MINIMUM_WIDTH, -1)
      return [scroll, chooser]
    end

    def create_nootbook
      notebook = Gtk::Notebook.new
      notebook.show_border = false
      notebook.signal_connect("switch-page") { |a,b,c| on_select_node(a, b, c) }
      notebook.signal_connect("select-page") { |a,b,c| on_select_node(a, b, c) }
      notebook.scrollable = true
      notebook.enable_popup = true
      notebook.set_size_request(800, -1)
      return notebook
    end

    def create_main_window(notebook, chooser, status, menubar)
      window = Gtk::Window.new("Rade")
      window.signal_connect("delete-event") { quit_editor }

      # editing area
      hpaned = Gtk::HPaned.new
      hpaned.pack1(chooser, true, false)
      hpaned.pack2(notebook, true, false)

      box = Gtk::VBox.new()
      box.pack_start(menubar, false, false)
      box.pack_start(hpaned)
      box.pack_end(status, false, false)

      window.add(box)
      return window
    end

    def create_menu
      menubar = Gtk::MenuBar.new
      menubar.append(create_file_menu)
      menubar.append(create_edit_menu)
      menubar.append(create_option_menu)
      return menubar
    end

    def create_edit_menu
      edit_menu = Gtk::Menu.new
      map_menu(edit_menu, [
        [Gtk::Stock::CUT,"<Rate>/cut"],
        [Gtk::Stock::COPY, "<Rate>/copy"],
        Gtk::Stock::PASTE,
        Gtk::Stock::DELETE,
        nil,
        Gtk::Stock::ZOOM_100,
        Gtk::Stock::ZOOM_IN,
        Gtk::Stock::ZOOM_OUT,
        nil,
        Gtk::Stock::FIND,
        Gtk::Stock::FIND_AND_REPLACE
      ])

      emi = Gtk::MenuItem.new("Edit")
      emi.submenu= edit_menu
      return emi
    end

    def create_option_menu
      option_menu = Gtk::Menu.new

      # show line numbers (toggle)
      show_line = Gtk::CheckMenuItem.new("Show line numbers")
      show_line.active = true
      show_line.signal_connect("toggled") { toggle_line_nr }
      option_menu.append(show_line)

      # word wrap (toggle)
      word_wrap = Gtk::CheckMenuItem.new("Word wrap")
      word_wrap.active = false
      word_wrap.signal_connect("toggled") { toggle_word_wrap }
      option_menu.append(word_wrap)

      # syntax highlighting (toogle)
      syntax_high = Gtk::CheckMenuItem.new("Show syntax highlighting")
      syntax_high.active = true
      syntax_high.signal_connect("toggled") { toggle_syntax_highlighting }
      option_menu.append(syntax_high)

      omi = Gtk::MenuItem.new("Option")
      omi.submenu= option_menu
      return omi
    end


    def map_menu(menu, items)
      items.each do |stock|
        if stock.nil?
          menu.append(Gtk::SeparatorMenuItem.new)
        else
          stock_id = (stock.respond_to? :each) ? stock[0] : stock
          mi = Gtk::ImageMenuItem.new(stock_id)
          mi.signal_connect("activate") do
            name = stock_id.to_s.gsub("gtk-", "").gsub("-", "_").downcase
            self.send "on_menu_#{name}"
          end
          #mi.accel_path = stock[1] if stock.respond_to? :each
          menu.append(mi)
        end
      end
    end

    def create_file_menu
      file_menu = Gtk::Menu.new
      map_menu(file_menu, [
        Gtk::Stock::NEW,
        nil,
        [Gtk::Stock::OPEN, "<Rate>/open"],
        [Gtk::Stock::SAVE, "<Rate>/save"],
        Gtk::Stock::SAVE_AS,
        [Gtk::Stock::CLOSE, "<Rate>/close"],
        nil,
        [Gtk::Stock::QUIT, "<Rate>/quit"]
      ])

      fmi = Gtk::MenuItem.new("File")
      fmi.submenu= file_menu
      return fmi
    end

    def add_source_view(rate, documents, document)
      source = create_source_view(rate.theme, rate.editor_font, document.buffer)
      document.source_view = source

      scroll = Gtk::ScrolledWindow.new
      scroll.add(source)

      button = Gtk::ToolButton.new(Gtk::Stock::CLOSE)
      button.set_size_request(18, 18)
      button.signal_connect("clicked") { remove_document document }

      label = Gtk::Label.new(document.name)
      document.source_label = label
      document.buffer.signal_connect("changed") do
        title = document.name + " *"
        label.text = title
        document.modified = true
        rate.set_title(title)
      end

      box = Gtk::HBox.new
      box.add button
      box.add label
      box.show_all

      notebook = rate.notebook
      document.notebook = notebook
      pa = notebook.append_page(scroll, box)
      notebook.show_all
      notebook.page = documents.size - 1
      add_status("#{Time.new} '#{document.name}' opened ...", "file")
      source.grab_focus

      return source
    end

    def create_source_view(theme, editor_font, buffer)
      source = Gtk::SourceView.new(buffer)
      source.show_line_numbers = true
      source.auto_indent = true
      source.indent_on_tab = true
      source.insert_spaces_instead_of_tabs = true
      source.tabs_width = 2
      source.margin = 80
      source.show_line_markers = true
      source.smart_home_end = true
      source.modify_fg(Gtk::StateType::NORMAL, Gdk::Color.parse(theme.setting.caret))
      source.modify_bg(Gtk::StateType::NORMAL, Gdk::Color.parse(theme.setting.invisibles))
      source.modify_base(Gtk::StateType::NORMAL, Gdk::Color.parse(theme.setting.background))
      source.modify_text(Gtk::StateType::NORMAL, Gdk::Color.parse(theme.setting.foreground))
      source.modify_base(Gtk::StateType::ACTIVE, Gdk::Color.parse(theme.setting.lineHighlight))
      source.modify_base(Gtk::StateType::PRELIGHT, Gdk::Color.parse(theme.setting.lineHighlight))
      source.modify_text(Gtk::StateType::SELECTED, Gdk::Color.parse(theme.setting.caret))
      source.modify_base(Gtk::StateType::SELECTED, Gdk::Color.parse(theme.setting.selection))

      font_for_source source, editor_font
      return source
    end
  end
end
