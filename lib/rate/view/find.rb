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
  class FindView < Gtk::HBox
    attr_accessor :search_close, :search_entry, :search_go_up, :search_go_down
  
    def initialize(search_bar_text = "Search (Regex):")
      super()
    
      # button to close the view
      @search_close = Gtk::ToolButton.new(Gtk::Stock::CLOSE)
      
      # entry where the search expression is passed in
      @search_entry = Gtk::Entry.new()
      
      # find next serach result
      @search_go_up = Gtk::ToolButton.new(Gtk::Stock::GO_DOWN)
      
      # find prev serch result
      @search_go_down = Gtk::ToolButton.new(Gtk::Stock::GO_UP)
      
      # find exerything ignore the case
      #@search_ignore_case = Gtk::CheckButton.new("Ignore case")

      # composite
      pack_start(@search_close, false, false)
      pack_start(Gtk::Label.new(search_bar_text), false, false)
      pack_start(@search_entry)
      pack_start(@search_go_up, false, false)
      pack_start(@search_go_down, false, false)
      #pack_start(@search_ignore_case, false, false)
    end

    # toggle the find dialog
    def toggle_find
      self.visible = !visible?
      @search_entry.grab_focus if visible?
    end
  end
end
