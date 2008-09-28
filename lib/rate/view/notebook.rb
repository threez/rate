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
  class NotebookView < Gtk::Notebook
    def initialize()
      super()
      self.show_border = false
      self.scrollable = true
      self.enable_popup = true
      set_size_request(800, -1)
    end
  end

  class NotebookTabView < Gtk::ScrolledWindow
    attr_accessor :source_view
  
    def initialize(source_view)
      super()
      add(@source_view = source_view)
    end

    # shows the notebook tab and let the 
    # source view grab the focus
    def activate
      show_all
    end
  end

  class NotebookTabButton < Gtk::HBox
    attr_reader :button, :label, :menu

    def initialize(name)
      super()

      # creates a X button to close the tab
      @button = Gtk::ToolButton.new(Gtk::Stock::CLOSE)
      @button.set_size_request(18, 18)

      # create the label that contains the document name
      @label = Gtk::Label.new(name)
      
      # create the label for the drop down menu
      @menu = Gtk::MenuItem.new(name)

      # add the elements to the TabButton
      add(@button)
      add(@label)
      
      show_all
    end
    
    # set the text of the menu item and the tab label
    def text=(new_text)
      @label.text = @menu.children.first.text = new_text
    end
  end
end