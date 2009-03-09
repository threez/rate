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
require 'gtk2'
require 'gtksourceview'

# load general & support files
[:support, :version, "model/theme", "model/language"].each do |file|
  require File.dirname(__FILE__) + "/rate/#{file}"
end

# load the components
%w{filer document notebook menu find runner editor}.each do |component_name|
  # this requires model viev and controller based on the name
  require_mvc component_name
end

if __FILE__ == $0 then
  rate = Rate::EditorController.new(ARGV)
  rate.show_all

  Gtk.main
end
