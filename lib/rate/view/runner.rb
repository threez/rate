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
  class TaskRunnerView < Gtk::Window
    def initialize(rate, title= "Ruby - running", font_size = 10)
      super(title)
    
      @source_view = Gtk::SourceView.new()
      @source_view.show_line_numbers = true
      @source_view.editable = false
      
      scroll = Gtk::ScrolledWindow.new
      scroll.add(@source_view)
      
      #format_text_view text, rate.theme
      #font_for_source text, [font_size]
       
      set_default_size(640,240)
      add scroll
      show_all
    end
  end
end
