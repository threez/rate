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
  class MenuBar < Gtk::MenuBar
    def initialize(menu_controller)
      super()
      @menu_controller = menu_controller
      append(create_file_menu(menu_controller))
      append(create_edit_menu(menu_controller))
      append(create_option_menu(menu_controller))
      append(create_actions_menu(menu_controller))
    end
    
  private
    
    # create edit menu and send every signal to passed controller
    def create_edit_menu(controller)
      edit_menu = Gtk::Menu.new
      map_menu(edit_menu, [
        Gtk::Stock::CUT,
        Gtk::Stock::COPY,
        Gtk::Stock::PASTE,
        Gtk::Stock::DELETE,
        nil,
        Gtk::Stock::ZOOM_100,
        [Gtk::Stock::ZOOM_IN, Menu::ZOOM_IN],
        [Gtk::Stock::ZOOM_OUT, Menu::ZOOM_OUT],
        nil,
        [Gtk::Stock::FIND, Menu::FIND],
        [Gtk::Stock::GO_UP, Menu::FIND_NEXT],
        [Gtk::Stock::GO_DOWN, Menu::FIND_PREV],
        Gtk::Stock::FIND_AND_REPLACE
      ], controller)

      emi = Gtk::MenuItem.new("Edit")
      emi.submenu= edit_menu
      return emi
    end

    # create option menu and send every signal to passed controller
    def create_option_menu(controller)
      option_menu = Gtk::Menu.new
      map_menu(option_menu, [
        ["toggle line nr"],
        ["toggle word wrap"],
        ["toggle syntax highlighting"],
      ], controller)

      omi = Gtk::MenuItem.new("Options")
      omi.submenu = option_menu
      return omi
    end

    # create actions menu and send every signal to passed controller
    def create_actions_menu(controller)
      action_menu = Gtk::Menu.new
      map_menu(action_menu, [
        ["start irb session", Menu::EXEC_IRB],
        ["start ruby", Menu::EXEC_RUBY]
        #Gtk::Stock::EXECUTE
      ], controller)

      ami = Gtk::MenuItem.new("Actions")
      ami.submenu = action_menu
      return ami
    end

    # create file menu and send every signal to passed controller
    def create_file_menu(controller)
      file_menu = Gtk::Menu.new
      map_menu(file_menu, [
        Gtk::Stock::NEW,
        nil,
        [Gtk::Stock::OPEN, Menu::OPEN],
        [Gtk::Stock::SAVE, Menu::SAVE],
        Gtk::Stock::SAVE_AS,
        [Gtk::Stock::CLOSE, Menu::CLOSE],
        nil,
        [Gtk::Stock::QUIT, Menu::QUIT]
      ], controller)

      fmi = Gtk::MenuItem.new("File")
      fmi.submenu = file_menu
      return fmi
    end
    
    # a helper method that creates menuitems based on a stock item list
    def map_menu(menu, items, controller)
      items.each do |stock|
        if stock.nil?
          menu.append(Gtk::SeparatorMenuItem.new)
        else
          stock_id = (stock.respond_to? :each) ? stock[0] : stock
          mi = Gtk::ImageMenuItem.new(stock_id)
          mi.signal_connect("activate") do
            name = stock_id.to_s.gsub("gtk-", "").gsub("-", "_").gsub(" ", "_").downcase
            controller.send "on_menu_#{name}"
          end
          #mi.accel_path = stock[1] if stock.respond_to? :each
          menu.append(mi)
        end
      end
    end
  end
end