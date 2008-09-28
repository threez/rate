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
  class Filer < Gtk::TreeStore
    attr_reader :path
  
    def initialize()
      super(Symbol, String)
    end
    
    # loads the structure of the passed path in 
    # the tree store
    def open_directory(path)
      clear # remove old content
      Filer.build_tree(self, @path = path, parent = nil)
    end
    
    # returns the file path of given node path
    def file_path(node_path)
      get_iter(node_path)[1]
    end
    
    # recursively step to files and folders of
    # the file system and append them to a TreeViewModel
    def self.build_tree(model, path, parent = nil)
      # find every file in a folder
      Dir[path + "/*"].each do |fobj|
        # append a new row for a file/folder
        row = model.append(parent)

        # depending on the type of the file add a
        # directory or a file
        if File.directory? fobj then
          row[0] = Gtk::Stock::OPEN
          # build the tree for the directory (recursive)
          # to see every file of every folder
          build_tree(model, fobj, row)
        else
          row[0] = Gtk::Stock::FILE
        end
        
        # assign the name of the file/folder to the icon
        row[1] = fobj
      end
    end
  end
end
