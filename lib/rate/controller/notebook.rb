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
  class NotebookController
    attr_accessor :view

    def initialize(editor_controller)
      @editor_controller = editor_controller
      @tabs = []
      @view = NotebookView.new()

      # add signals
      @view.signal_connect("switch-page") do |x, y, notebook_tab_nr| 
        change_document_name(@tabs[notebook_tab_nr].document)
      end
      @view.signal_connect("select-page") do |x, y, notebook_tab_nr|
        change_document_name(@tabs[notebook_tab_nr].document)
      end
    end

    # change the editor document name (window title and tab title)
    def change_document_name(document)
      @editor_controller.view.document_name =
        tab(document).view_title.text = 
          document.name
    end

    # return true if the document is allready opened in another tab
    def exist_tab?(document)
      !tab(document).nil?
    end
    
    # return the tab that holds the passed document or nil
    def tab(document)
      @tabs.select { |tab| tab.document == document }.first
    end

    # returns the number of a document or nil if it doesn't exist
    def tab_num(tab)
      @tabs.index(tab)
    end

    # returns false if the document allready exists and switch to it.
    # returns true if the document has been added.
    def add_tab(document)
      if exist_tab?(document)
        # if the tab is allready available switch to it
        @view.page = tab_num(tab(document))
        return false
      else
        # FIXME: remove first document if it is new and unchanged
        #if @tabs.size == 1 
        #  tab = @tabs.first
        #  remove_tab(tab) unless tab.document.modified?
        #end

        append_tab(create_tab(document))

        return true
      end
    end
    
    alias << add_tab
    
    # remove a tab by passing the document object.
    # returns true on success false otherwise
    def remove_tab(document)
      return false if document.nil?
    
      if document.class == Document
        tab = tab(document)        
        @view.remove_page(tab_num(tab))
        @tabs.delete tab
        tab.destroy
        
        @editor_controller.view.add_status(
          "#{Time.new} '#{document.name}' closed ...", "file")
        
        if @tabs.empty?
          @editor_controller.view.no_document!
        end
        
        return true
      else
        return false
      end
    end
    
    alias - remove_tab
    
    # removes the current tab
    def remove_current_tab()
      remove_tab(current_document) if current_document
    end
    
    # returns the current active tab
    def current_tab
      @tabs[@view.page]
    end
    
    # saves the current tab content
    def save_current_tab
      current_tab.controller.save if current_tab
    end
    
    # saves the current tab content to a new file
    def save_as_current_tab
      current_tab.controller.save_as if current_tab
    end
    
    # returns the document of the current active tab 
    def current_document
      current_tab.document if current_tab
    end

    # returns the source view of the current tab
    def current_source_view
      current_tab.view.source_view if current_tab
    end
    
    # open a file from passed path
    def open_file(path)
      # FIXME: report error if file can't be opened
      add_tab Document.new(path)
    end
    
    # open a new empty source view
    def open_empty
      open_file(nil)
    end
    
  private
  
    # append a notebook tab object
    def append_tab(tab)
      @tabs << tab

      # append the page
      @view.append_page_menu(tab.view, tab.view_title, tab.view_title.menu)
      
      # focus the new tab
      tab.view.activate
      @view.page = tab_num(tab)

      # check for douplicate names
      # if there are some change the naming to be dirbased 
      # in this cases
      tabs = @tabs.select do |t|
        # remove the modified tag (* ) if nessessary      
        t.document.name.gsub(/[* ]*$/, "") == tab.document.name.gsub(/[* ]*$/, "")
      end
      #  display folder too if there are more documents equaly named
      if tabs.size > 1
        tabs.each do |tab|
          tab.document.naming = :dir_name
          tab.view_title.text = tab.document.name
        end
      end

      @editor_controller.view.add_status(
        "#{Time.now} '#{tab.document.name}' opened ...", "file")
        
      return tab
    end
    
    # create new notebook tab
    def create_tab(document)
      document_controller = DocumentController.new(@editor_controller, 
        self, @editor_controller.theme, document)
      view = NotebookTabView.new(document_controller.view)
      view_title = NotebookTabButton.new(document.name)

      document.signal_connect("modified-changed") do
        # remove local search results
        # FIXME: unfind

        # change the document name in the editor if 
        # the document buffer was modified
        change_document_name(document)
      end
      
      document.signal_connect("end-user-action") do |buffer|
        change_document_name(document)
      end
      
      document.signal_connect("changed") do
        # change name if there is no change after undo
        change_document_name(document)
      end
      
      Rate::Support.add_file_drag_and_drop(document_controller.view) do |path, uri|
        if File.exist?(path) and !File.directory?(path) then
          self.open_file(path)
        end
      end

      view_title.button.signal_connect("clicked") do
        # remove the document if the X button is pressed
        # FIXME: ask to save if the buffer is modified
        remove_tab(document)
      end

      NotebookTab.new(view, view_title, document_controller)
    end
  end
end