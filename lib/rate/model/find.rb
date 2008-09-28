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
  # class for supporting the match_all method of Regexp
  class FindMatch < Struct.new(:text, :start_pos, :end_pos)
  end

  class Find < Regexp
    def initialize(search_expression)
      super(search_expression, Regexp::MULTILINE + Regexp::EXTENDED)
    end
    
    # do a search on the text document
    def search(text)
      # make use of the match_all method that is defined in
      # support.rb
      if md = match_all(text) and md.size > 0
        @results = md
        @current = 0
        return current_match
      else
        return false
      end
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
    
  private
  
    # matches all occurences of the Regexp in the passed text.
    #   tm = "asd a asd asd
    #   asd a a a asd sd a asd"
    #   /\basd\b/ix.match_all(tm)  #=> [["asd", 0, 3],["asd", 6, 9],["asd", 10, 13],["asd", 14, 17],["asd", 24, 27],["asd", 33, 36]]
    def match_all(text, offset = 0, matches = [])
      if md = self.match(text)
        # calc position in text stream based on offset
        begin_match = md.begin(0) + offset
        end_match = md.end(0) + offset

        # add results to the metches table
        matches << FindMatch.new(md[0], begin_match, end_match)

        # try to find more
        if (md.end(0) - md.begin(0)) > 0
          match_all(md.post_match, end_match, matches)
        end
      else
        return matches
      end
    end
  end
end

