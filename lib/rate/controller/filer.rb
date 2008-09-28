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
  class FilerController  
    def initialize(notebook_controller, path = nil)
      @notebook_controller = notebook_controller
      @model = Filer.new()
      @view = FilerView.new(@model)
      @scrollable = ScrollableFilerView.new(@view)
    
      # adds the signal when ever a row was selected
      # this will be used to open files and rebuild the
      # views file system tree
      @view.signal_connect("row-activated") do |sel, node_path, column|
        file_path = @model.file_path(node_path)
        unless File.directory? file_path
          notebook_controller.open_file(file_path)
        else
          # rebuild tree if directory was clicked
          open_directory(@model.path)
        end
      end    
      
      open_directory(path) unless path.nil?
    end

    # opens the diretory and show the result in the filer view
    def open_directory(path)
      @model.open_directory(path)
      @scrollable.visible = true
      @view.expand_all
    end

    # display or hide the filer pane
    def toggle_filer_pane
      @scrollable.visible = !@scrollable.visible?
    end
    
    # returns the view that should be inserted in the main editor window
    def view
      @scrollable
    end
  end
end
