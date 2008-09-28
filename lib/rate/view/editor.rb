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
  class EditorView < Gtk::Window
    def initialize(menubar, filer_view, notebook_view, find_view,
        icon_path = "./images/icon.png")
      super(Rate::NAME)
      # hold views in instance variables
      @menubar, @filer_view, @notebook_view, @find_view = 
        menubar, filer_view, notebook_view, find_view
        
      # create status bar
      @status_bar = Gtk::Statusbar.new

      # editing area
      @content = Gtk::HPaned.new
      @content.pack1(filer_view, true, false)
      @content.pack2(notebook_view, true, false)

      # main area (composition)
      box = Gtk::VBox.new()
      box.pack_start(@menubar, false, false)
      box.pack_start(@content)
      box.pack_start(@find_view, false, false)
      box.pack_end(@status_bar, false, false)
      add(box)
      
      # default window dimension
      set_default_size(800,600)
      
      # setuo the icon
      icon = Gdk::Pixbuf.new(icon_path)
      Gtk::Window.set_default_icon(icon)
    end
    
    # display the find component (if it isn't allready) and
    # focus the search field
    def open_find
      unless @search.visible?
        @find_view.visible = true
      end
      
      @find_view.search_entry.grab_focus
    end
    
    # sets the editors text to the given document name
    def document_name=(document_name)
      self.title = "#{NAME} - #{document_name}"
    end
    
    # resets the window title to display just the name of the app
    def no_document!
      self.title = "#{NAME}"
    end
    
    # adds a new message to the status stack
    def add_status(msg, context_desc = "default")
      context = @status_bar.get_context_id(context_desc)
      @status_bar.push(context, msg)
    end
  
    # show all elements of the window except the 
    def show_all
      super()

      # disable some things by default
      #[@filer_view, @find_view].each do |widget|
      #  widget.visible = false
      #end
    end
  end
end
