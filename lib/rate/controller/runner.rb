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
  class TaskRunnerController
    def self.exec_start_ruby(document)
      unless document.path.nil?        
        view = TaskRunnerView.new()
        view.open_file(:ruby, document.path)        
      end
      #  system "start ruby -w -- #{document.path}"
      #end
    end
    
    def exec_start_irb
      system "start irb -rubygems"
    end
  end
end