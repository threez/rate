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
    def initialize(title= "Ruby - running")
      super(title)
    
      @term = Vte::Terminal.new
       
      set_default_size(640,240)
      add Gtk::ScrolledWindow.new.add(@term)
      show_all
    end
    
    def open_file(interpreter, file_path)
      @term.fork_command(nil, [interpreter, "-w", "--", file_path], 
        envv=nil, directory=File.dirname(file_path))
    end
  end
end
