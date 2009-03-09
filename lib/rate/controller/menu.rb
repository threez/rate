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
  class MenuController
    attr_reader :view
  
    def initialize(editor_controller, notebook_controller, find_controller)
      @editor_controller = editor_controller
      @notebook_controller = notebook_controller
      @find_controller = find_controller
      
      @view = MenuBar.new(self)
    end
    
    # add key bindings to the window
    def add_key_bindings(window)
      @key_bindings ||= create_key_bindings()
      window.add_accel_group(@key_bindings)
    end
  
    # EVENTS #####################
  
    def on_menu_cut
      current_source_view.cut_clipboard if current_source_view
    end
    
    def on_menu_copy
      current_source_view.copy_clipboard if current_source_view
    end
    
    def on_menu_paste
      current_source_view.paste_clipboard if current_source_view
    end
    
    def on_menu_delete
      current_source_view.delete_from_cursor(Gtk::DeleteType::CHARS, 0) if current_source_view
    end
    
    def on_menu_zoom_100
      current_source_view.font.default! if current_source_view
    end
    
    def on_menu_zoom_in
      current_source_view.font.increase! if current_source_view
    end
    
    def on_menu_zoom_out
      current_source_view.font.decrease! if current_source_view
    end
    
    def on_menu_find
      @find_controller.toggle_find
    end
    
    def on_menu_go_up
      @find_controller.find_prev
    end
    
    def on_menu_go_down
      @find_controller.find_next
    end
    
    def on_menu_find_and_replace
      # FIXME: Implement find and replace
    end
    
    def on_menu_new
      @notebook_controller.open_empty
    end
    
    def on_menu_save
      @notebook_controller.save_current_tab
    end
    
    def on_menu_save_as
      @notebook_controller.save_as_current_tab
    end
    
    def on_menu_open
      if path = DocumentController.open(@editor_controller.view)
        @notebook_controller.open_file(path)
      end
    end
    
    def on_menu_close
      @notebook_controller.remove_current_tab()
    end
    
    def on_menu_quit 
      @editor_controller.quit_editor
    end
    
    def on_menu_start_irb_session
      #exec_start_irb
    end
    
    def on_menu_start_ruby
      TaskRunnerController.exec_start_ruby(current_tab.document)
    end
    
    def on_menu_toggle_line_nr
      current_source_view.toggle_line_nr if current_source_view
    end
    
    def on_menu_toggle_word_wrap
      current_source_view.toggle_word_wrap if current_source_view
    end
    
    def on_menu_toggle_syntax_highlighting
      current_source_view.toggle_highlighting if current_source_view
    end
    
    def on_toggle_filer
    end
  
  private
  
    def create_key_bindings()
      Gtk::AccelMap.add_entry(Menu::NEW, Gdk::Keyval::GDK_N, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry(Menu::SAVE, Gdk::Keyval::GDK_S, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry(Menu::OPEN, Gdk::Keyval::GDK_O, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry(Menu::CLOSE, Gdk::Keyval::GDK_W, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry(Menu::QUIT, Gdk::Keyval::GDK_Q, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry(Menu::TOGGLE_FILER, Gdk::Keyval::GDK_P, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry(Menu::ZOOM_IN, Gdk::Keyval::GDK_plus, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry(Menu::ZOOM_OUT, Gdk::Keyval::GDK_minus, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry(Menu::FIND, Gdk::Keyval::GDK_F, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry(Menu::FIND_NEXT, Gdk::Keyval::GDK_F3, 0)
      Gtk::AccelMap.add_entry(Menu::FIND_PREV, Gdk::Keyval::GDK_F4, 0)
      Gtk::AccelMap.add_entry(Menu::EXEC_IRB, Gdk::Keyval::GDK_I, Gdk::Window::CONTROL_MASK)
      Gtk::AccelMap.add_entry(Menu::EXEC_RUBY, Gdk::Keyval::GDK_R, Gdk::Window::CONTROL_MASK | Gdk::Keyval::GDK_Shift_L)

      ag = Gtk::AccelGroup.new
      ag.connect(Menu::NEW) { on_menu_new }
      ag.connect(Menu::SAVE) { on_menu_save }
      ag.connect(Menu::OPEN) { on_menu_open }
      ag.connect(Menu::CLOSE) { on_menu_close }
      ag.connect(Menu::QUIT) { on_menu_quit }
      ag.connect(Menu::TOGGLE_FILER) { on_toggle_filer }
      ag.connect(Menu::ZOOM_IN) { on_menu_zoom_in }
      ag.connect(Menu::ZOOM_OUT) { on_menu_zoom_out }
      ag.connect(Menu::FIND) { on_menu_find }
      ag.connect(Menu::FIND_NEXT) { on_menu_go_down }
      ag.connect(Menu::FIND_PREV) { on_menu_go_up }
      ag.connect(Menu::EXEC_IRB) { on_menu_start_irb_session }
      ag.connect(Menu::EXEC_RUBY) { on_menu_start_ruby }
      return ag
    end
    
    # returns the current notebook tab or nil if there i none
    def current_tab
      @notebook_controller.current_tab
    end
    
    # returns the source view of the current notebook tab or nil if there i none
    def current_source_view
      current_tab.view.source_view if current_tab
    end
  end
end