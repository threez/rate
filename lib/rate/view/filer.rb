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
  class ScrollableFilerView < Gtk::ScrolledWindow
    # minimun with of the FilerView in [px]
    MINIMUM_WIDTH = 200
    attr_accessor :filer_view
  
    def initialize(filer_view)
      super()
      add(@filer_view = filer_view)
      set_size_request(MINIMUM_WIDTH, -1)
    end
  end

  class FilerView < Gtk::TreeView
    def initialize(model, pane_name = "Files")
      # show file icon with basename
      super(model)
      
      # show expanders to easy step through the files and folders
      show_expanders = true
      
      # create the files column containing the icon and column
      column = Gtk::TreeViewColumn.new(pane_name)

      # icon renderer and column
      @cell_renderer_0 = Gtk::CellRendererPixbuf.new
      column.pack_start(@cell_renderer_0, false)
      column.set_cell_data_func(@cell_renderer_0) do |column, cell, model, iter|
        # the value is a stock id
        cell.stock_id = iter.get_value(0)
      end

      # Filename renderer and column
      @cell_renderer_1 = Gtk::CellRendererText.new
      column.pack_start(@cell_renderer_1, true)
      column.set_cell_data_func(@cell_renderer_1) do |column, cell, model, iter|
        # the value is the full name of a file but reduced to its basename
        cell.text = File.basename(iter.get_value(1))
      end

      # append the column and assign expanders to it
      append_column(column)
      expander_column = column
    end
  end
end