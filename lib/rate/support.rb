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

# global helper methods for the rate editor
module Rate
  module DslMethods
    def dsl_method(*methods)
      methods.each do |meth|
        attr_writer meth
        # use litte hack (*value) to be treated as an array
        # and avoid warings that a parameter must be passed
        # this method will be setter and getter all in one
        # if the value array contains a value it is a setter
        # otherwise it's a getter
        define_method(meth) do |*value|
          if value.first.nil?
            # getter
            instance_variable_get("@#{meth}")
          else
            # setter
            send(meth.to_s + "=", (value.size > 1) ? value : value.first)
          end
        end
      end
    end
  end

  module Support
    # adding drag and drop to widget
    def self.add_file_drag_and_drop(widget, &action)
      #require 'uri'
      Gtk::Drag.dest_set(widget, Gtk::Drag::DEST_DEFAULT_ALL,
        [["text/uri-list", 0, 0]],
        Gdk::DragContext::ACTION_DEFAULT)

      widget.signal_connect("drag-data-received") do |this, drag_context, x, y, data, info, time|
        uri = data.data.to_s.gsub("\0", "") # avoid error because of \0
        path = uri.gsub("file:///", "").gsub("%20", " ").chomp
        
        action.call(path, uri)
      end
    end
  end
end

# requires a file from the rate folder
def require_from(folder, name)
  require File.dirname(__FILE__) + "/#{folder}/#{name}.rb"
end

# requires all parts of a component 
def require_mvc(name)
  require_from(:model, name)
  require_from(:view, name)
  require_from(:controller, name)
end