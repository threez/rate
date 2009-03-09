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

begin
  require "oniguruma"
rescue LoadError
  require "rubygems"
  require "oniguruma"
end

module Rate
  # class for supporting the match_all method of Regexp
  class FindMatch < Struct.new(:text, :start_pos, :end_pos)
  end

  class Find < Oniguruma::ORegexp    
    # do a search on the text document
    def search(text)
      @results = []
      match_all(text) do |match|
        @results << match
      end
      @current = 0 # set the cursor to the first match
      
      return false if @results.empty?
      return @results.first
    end
    
    # returns the count of results that are found
    def results
      @results.size
    end
    
    # goto next found item, start from begin if end is reached
    def goto_next()
      return false if @current.nil?
      
      if @current + 1 == results
        # move to first entry if end reached
        @current = 0
      else
        @current += 1
      end
      
      return current_match
    end
    
    # goto prev found item, start from end if stat is reached
    def goto_prev()
      return false if @current.nil?
      
      if @current - 1 == -1
        # move to last entry if end reached
        @current = results - 1
      else
        @current -= 1
      end
      
      return current_match
    end
    
    # returns the match object for the current match
    def current_match
      @results[@current]
    end
  end
end

