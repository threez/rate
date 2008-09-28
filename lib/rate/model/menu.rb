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
  class Menu
    NEW           = "<#{Rate::NAME}>/new"
    SAVE          = "<#{Rate::NAME}>/save"
    OPEN          = "<#{Rate::NAME}>/open"
    CLOSE         = "<#{Rate::NAME}>/close"
    QUIT          = "<#{Rate::NAME}>/quit"
    TOGGLE_FILER  = "<#{Rate::NAME}>/toggle_filer"
    ZOOM_IN       = "<#{Rate::NAME}>/zoom_in"
    ZOOM_OUT      = "<#{Rate::NAME}>/zoom_out"
    FIND          = "<#{Rate::NAME}>/find"
    FIND_NEXT     = "<#{Rate::NAME}>/find_next"
    FIND_PREV     = "<#{Rate::NAME}>/find_prev"
    EXEC_IRB      = "<#{Rate::NAME}>/exec_start_irb"
    EXEC_RUBY     = "<#{Rate::NAME}>/exec_start_ruby"
  end
end