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
  class FindController
    attr_reader :view
    
    def initialize(editor_controller, notebook_controller)
      @editor_controller = editor_controller
      @notebook_controller = notebook_controller
      @view = FindView.new()
      
      @view.search_close.signal_connect("clicked") { toggle_find }
      @view.search_entry.signal_connect("activate") { |entry, b| find(entry.text) }
      @view.search_go_up.signal_connect("clicked") { find_next }
      @view.search_go_down.signal_connect("clicked") { find_prev }
    end
  
    # hide find/show find window
    def toggle_find
      @view.toggle_find
      @find = nil
      
      # make continue editiong easyer
      current_source_view.grab_focus unless @view.visible? if current_source_view
    end
  
    # execute the search with a regular expression
    def find(search_expression)
      begin
        @find = Find.new(search_expression)
        if match = @find.search(current_document.text)
          @editor_controller.view.add_status(
            "Search for /#{search_expression}/ has #{@find.results} results", "find")
          select_text(match)
          @view.controll_mode(true)
        else
          @editor_controller.view.add_status(
            "Search for /#{search_expression}/ has ended with no results", "find")
          @find = nil # remove the find object
          @view.controll_mode(false)
        end
      rescue ArgumentError => ex # OnigurumaError
        @editor_controller.view.add_status(
          "The search expression contains an error: [#{ex.message}]", "find")  
        @find = nil # remove the find object
        @view.controll_mode(false)
      end
    end
    
    # select the next found text or begin from start if there in no more
    def find_next()
      if @find
        match = @find.goto_next()
        select_text(match)
      end
    end

    # select the previous found text or begin at end if there is no more
    def find_prev()
      if @find
        match = @find.goto_prev()
        select_text(match)
      end
    end
    
  private

    # select the text that is positioned by the FindMatch object
    # This will scroll the window if the text is out of the viewport.
    def select_text(match)
      start_of_region = current_document.get_iter_at_offset(match.begin(0))
      end_of_region = current_document.get_iter_at_offset(match.end(0))
      
      # place the cursor and select the text
      current_document.place_cursor start_of_region
      current_document.select_range start_of_region, end_of_region
      
      # scroll to current selection
      current_source_view.scroll_to_iter(start_of_region, 0.0, true, 0.0, 0.0)
      
      # grag focus for fast editing
      current_source_view.grab_focus
    end
    
    def current_document
      @notebook_controller.current_document 
    end
    
    def current_source_view
      @notebook_controller.current_source_view
    end
  end
end