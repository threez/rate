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
  module Resource
    # creates a new theme object based on the path
    def self.load_theme(path)
      theme_src = File.open(path, 'r') { |f| f.read }
      eval(theme_src)
    end
    
    def self.load_language(path)
      language_src = File.open(path, 'r') { |f| f.read }
      eval(language_src)
    end
  end

  class EditorController
    attr_reader :theme, :view
  
    def initialize(files)
      # initialize all editor components
      @notebook_controller = NotebookController.new(self)
      @filer_controller = FilerController.new(
        @notebook_controller, "F:/rate/lib/")
      @find_controller = FindController.new(self, @notebook_controller)
      @menu_controller = MenuController.new(
        self, @notebook_controller,  @find_controller)
    
      views = [@menu_controller.view, @filer_controller.view, 
               @notebook_controller.view, @find_controller.view]
    
      @view = EditorView.new(*views)
      @menu_controller.add_key_bindings(@view)
      
      # add drag and drop to all widgets
      add_drag_n_drop! views
        
      # load the default syntax theme
      @theme = Resource.load_theme('F:/rate/rate/themes/railscasts.rb')
      #Theme.new("./themes/Railscasts.tmTheme")
      
      # open files or folder
      open(files)
      
      # add event handling if the editor should be closed
      @view.signal_connect("delete-event") { quit_editor }
    end
    
    # add the drag and drop handlers to all views
    def add_drag_n_drop!(widgets)
      widgets.each do |widget|
        Rate::Support.add_file_drag_and_drop(widget) do |path, uri|
          if File.exist?(path) and !File.directory?(path) then
            @notebook_controller.open_file(path)
          end
        end
      end
    end
    
    # open every passed file, if the argument contains a directory
    # open just the directory in the filer pane
    def open(files)
      count = 0
      begin
        if files.size > 0 and File.directory?(files.first)
          # just open the directory in the file_pane
          @filer_controller.open_directory(files.shift)
          count += 1
        else
          # add all files
          while (file = files.shift)
            @notebook_controller.open_file(file)
            count += 1
          end
        end
      rescue
        # FIXME: report the error
      ensure
        # display new tab if file or directory is wrong not set or empty
        @notebook_controller.open_empty if count == 0
      end
    end
    
    # displays the main editor view
    def show_all()
      @view.show_all
    end
    
    # quit programm execution
    def quit_editor
      # FIXME: if there is an unsaved change ask before close
      Gtk::main_quit
    end
  end
end
