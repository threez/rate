#
# Copyright (c) 2008 Vincent Landgraf
#
# This file is part of the Rate (the ruby editor).
# 
# Rate (the ruby editor) is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Rate (the ruby editor) is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Rate (the ruby editor).  If not, see <http://www.gnu.org/licenses/>.
#
module Rate
  class EditorFont
    # default editor fonts
    FONTS = ["Courier New", "Bitstream Vera Sans Mono", "Monaco"]
    
    # default editor font size
    DEFAULT_FONT_SIZE = 10
    
    def initialize(widget)
      @widget = widget
      default!
    end
    
    # set default editor font (Bitstream..., Size:10)
    def default!
      @editor_font = [FONTS[1], DEFAULT_FONT_SIZE]
      
      # apply the default font
      font_for(@widget)
    end
  
    # increase editor font by 1pt
    def increase!
      editor_font = @editor_font[0..-2] + [@editor_font[-1] + 1]
      font_for @widget, editor_font
    end

    # decrease editor font by 1pt
    def decrease!
      editor_font = @editor_font[0..-2] + [@editor_font[-1] - 1]
      font_for @widget, editor_font
    end
  
    # set the font for given widget
    def font_for(widget, arry = nil)
      @editor_font = arry if arry
      font_desc = @editor_font.join(" ")
      widget.modify_font Pango::FontDescription.new(font_desc)
    end
  end

  class DocumentView < Gtk::SourceView
    attr_reader :font
  
    # build a niew source view out of the document
    def initialize(document, theme)
      super(document)
      @document = document
      @font = EditorFont.new(self)
      @theme = theme

      # set default settings (ruby optimized)
      self.show_line_numbers = true
      self.auto_indent = true
      self.indent_on_tab = true
      self.insert_spaces_instead_of_tabs = true
      self.tabs_width = 2
      self.margin = 80
      self.smart_home_end = true
      #self.show_line_markers = true
      
      # highlight and beautify
      format!(@theme)
    end
    
    # toggle line numbers on/off
    def toggle_line_nr
      self.show_line_numbers = !show_line_numbers?
    end

    # toggle word wrap on/off 
    def toggle_word_wrap
      self.wrap_mode = (wrap_mode == Gtk::TextTag::WRAP_NONE) ?
        Gtk::TextTag::WRAP_CHAR : Gtk::TextTag::WRAP_NONE
    end
    
    # toggle syntax highlighting
    def toggle_highlighting
      @document.toggle_highlighting
    end

  private

    # format the the source view by given theme
    # (will change colours of the text, background and foreground)
    def format!(theme)    
      modify_fg(Gtk::StateType::NORMAL, Gdk::Color.parse(theme.editor.caret))
      modify_bg(Gtk::StateType::NORMAL, Gdk::Color.parse(theme.editor.invisibles))
      modify_base(Gtk::StateType::NORMAL, Gdk::Color.parse(theme.editor.background))
      modify_text(Gtk::StateType::NORMAL, Gdk::Color.parse(theme.editor.foreground))
      modify_base(Gtk::StateType::ACTIVE, Gdk::Color.parse(theme.editor.line_highlight))
      modify_base(Gtk::StateType::PRELIGHT, Gdk::Color.parse(theme.editor.line_highlight))
      modify_text(Gtk::StateType::SELECTED, Gdk::Color.parse(theme.editor.caret))
      modify_base(Gtk::StateType::SELECTED, Gdk::Color.parse(theme.editor.selection))
      coloring_text_view_cursor!(theme.editor.caret)
    end
    
    # using a hack to style the cursor color of the source view
    # color is a RGB color eg. #FFFFFF or a name like red or blue
    def coloring_text_view_cursor!(color)
      self.name = "rate-source-view-#{object_id}"
      style = 'style "default-' + name + '" { 
        GtkTextView::cursor_color = "' + color.to_s + '"
      }
      widget "*.' + name + '" style "default-' + name + '"'
      Gtk::RC.parse_string(style) 
    end
  end
  
  # super clas that makes creation of file dialoges easyer
  class SimpleFileDialog < Gtk::FileChooserDialog
    def initialize(title, parent_window, action, type)
      super(title, parent_window, action, nil,
        [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
        [type, Gtk::Dialog::RESPONSE_ACCEPT])
    end

    # runs the dialog and returns true if the Dialog button accept was pressed
    def ok?
      run == Gtk::Dialog::RESPONSE_ACCEPT
    end
  end

  class SaveFileDialog < SimpleFileDialog
    # create a new save as FileChooser Dialog
    def initialize(parent_window, title = "Save file as")
      super(title, parent_window, 
        Gtk::FileChooser::ACTION_SAVE, 
        Gtk::Stock::SAVE)
    end
  end

  class OpenFileDialog < SimpleFileDialog
    # create a new open FileChooser Dialog
    def initialize(parent_window, title = "Open file")
      super(title, parent_window, 
        Gtk::FileChooser::ACTION_OPEN, 
        Gtk::Stock::OPEN)
    end
  end
end