require File.dirname(__FILE__) + '/theme'
require File.dirname(__FILE__) + '/syntax_theme'
require File.dirname(__FILE__) + '/document'
require File.dirname(__FILE__) + '/file_pane'
require File.dirname(__FILE__) + '/editor_factory'

module Rate
  class Editor
    include EditorFactory

    TITLE = "Rate (RubyMate)"
    NAME = "Rate"
    FONTS = ["Courier New", "Bitstream Vera Sans Mono", "Monaco"]
    DEFAULT_FONT_SIZE = 9
    attr_reader :theme, :editor_font, :window, :notebook

    def initialize
      @documents = []
      @source_views = []
      @new_file_id = 1
      @theme = Theme.new("./themes/Railscasts.tmTheme")
      @editor_font = [FONTS[1], DEFAULT_FONT_SIZE]

      @notebook = create_nootbook()
      @chooser_scroll, @chooser = create_file_chooser()
      @status = Gtk::Statusbar.new
      @menubar = create_menu
      @window = create_main_window(@notebook, @chooser_scroll, @status, @menubar)
      @key_bindings = create_key_bindings(@window)
      @window.add_accel_group(@key_bindings)
      @window.set_default_size(800,600)
      @window.show_all
      @chooser_scroll.visible = false
    end

    def file_opened?(document)
      @documents.select { |d| d.path == document.path }.size > 0
    end

    def number_document(document)
      d = @documents.select { |d| d if d.path == document.path }.first
      @documents.index(d)
    end

    def add_document(document)
      if !document.path.nil? and file_opened? document
        # if the tab is allready available switch to it
        @notebook.page = number_document(document)
        return false
      end

      # remove New if empty
      if @documents.size == 1 and
        @documents.first.empty? and
        @documents.first.path.nil?  then
        remove_document(@documents.first)
      end

      @documents << document
      @source_views << add_source_view(self, @documents, document)
    end

    def set_title(title)
      @window.title = "#{NAME} - #{title}"
    end

    def remove_document(document)
      return if document.nil?
      nr = @documents.index document
      @documents.delete document
      @source_views.delete document.source_view
      @notebook.remove_page(nr)
      add_status("#{Time.new} '#{document.name}' closed ...", "file")
    end

    alias << add_document

    def show
      @window.show_all
      @chooser_scroll.visible = false
    end

    def current_document
      @documents[@notebook.page]
    end

    def current_source_view
      @source_views[number_document(current_document)]
    end

    def save_document(document)
      if document.path_given?
        if document.save then
          add_status("#{Time.new} '#{document.name}' save in #{document.path} ...", "file")
        else
          add_status("#{Time.new} '#{document.name}' allready saved ...", "file")
        end
      else
        save_document_as(document)
      end
    end

    def save_document_as(document)
      dialog = Gtk::FileChooserDialog.new("Save file as",
        @window, Gtk::FileChooser::ACTION_SAVE, nil,
        [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
        [Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_ACCEPT])

      if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
        document.path = dialog.filename
        save_document(document)
      end

      dialog.destroy
    end

    def create_new_document
      file_id = @new_file_id
      @new_file_id += 1
      name = "New #{file_id}"
      self << Document.create(name, "", @theme)
      add_status("#{Time.new} '#{name}' created ...", "file")
    end

    def open_directory(path)
      @chooser.build_tree(path)
      @chooser_scroll.visible = true
      @chooser.expand_all
    end

    def open_document_chooser()
      dialog = Gtk::FileChooserDialog.new("Open file",
        @window, Gtk::FileChooser::ACTION_OPEN, nil,
        [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
        [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])

      if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
        document =  Document.create_from_source_file(dialog.filename, @theme)
        self << document
      end

      dialog.destroy
    end

    def quit_editor
      Gtk::main_quit
    end

    def increase_editor_font
      editor_font = @editor_font[0..-2] + [@editor_font[-1] + 1]
      @source_views.each do |view|
        font_for_source view, editor_font
      end
    end

    def decrease_editor_font
      editor_font = @editor_font[0..-2] + [@editor_font[-1] - 1]
      @source_views.each do |view|
        font_for_source view, editor_font
      end
    end


    def toggle_line_nr
      @source_views.each do |view|
        view.show_line_numbers = !view.show_line_numbers?
      end
    end

    def toggle_file_pane
      @chooser_scroll.visible = !@chooser_scroll.visible?
    end

    def toggle_word_wrap
      @source_views.each do |view|
        case view.wrap_mode
          when Gtk::TextTag::WRAP_NONE
            view.wrap_mode = Gtk::TextTag::WRAP_CHAR
          when Gtk::TextTag::WRAP_CHAR
            view.wrap_mode = Gtk::TextTag::WRAP_NONE
        end
      end
    end

    def toggle_syntax_highlighting
      @documents.each do |document|
        document.toggle_syntax_highlighting
      end
    end

  private

    def add_status(msg, context_desc = "default")
      context = @status.get_context_id(context_desc)
      @status.push(context, msg)
    end

    def on_menu_cut; current_source_view.cut_clipboard ; end
    def on_menu_copy; current_source_view.copy_clipboard; end
    def on_menu_paste; current_source_view.paste_clipboard; end
    def on_menu_delete; current_source_view.delete_from_cursor(Gtk::DeleteType::CHARS, 0); end
    def on_menu_zoom_100; @source_views.each { |v| font_for_source v, [FONTS[1], DEFAULT_FONT_SIZE] }; end
    def on_menu_zoom_in; increase_editor_font; end
    def on_menu_zoom_out; decrease_editor_font; end
    def on_menu_find; p "c"; end
    def on_menu_find_and_replace; p "c"; end
    def on_menu_new; create_new_document; end
    def on_menu_save; save_document(current_document); end
    def on_menu_save_as; save_document_as(current_document); end
    def on_menu_open; open_document_chooser; end
    def on_menu_close; remove_document(current_document); end
    def on_menu_quit; quit_editor; end


    def font_for_source(source, arry)
      @editor_font = arry
      arry[0] = arry[0]
      font_desc = arry.join(" ")
      source.modify_font Pango::FontDescription.new(font_desc)
    end

    def on_select_node(sel, page, page_num)
      set_title(@documents[page_num].source_label.text)
    end
  end
end
