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
  class DocumentController
    attr_reader :view, :document
  
    def initialize(editor_controller, notebook_controller, theme, document)
      @editor_controller = editor_controller
      @notebook_controller = notebook_controller
      @theme = theme
      @view = DocumentView.new(@document = document, @theme)
      
      # setup syntax highlighting
      @document.create_tags(@theme)
      @document.language = LanguageManager.instance.lang_for(@document)
    end

    # save the document, if the document doesn't point
    # to a real file save_as will automaticlly beeing called
    def save(path = nil)
      if @document.path_given? or !path.nil?
        if @document.save(path) then
          @editor_controller.view.add_status(
            "#{Time.new} '#{document.name}' save in #{document.path} ...", "file")
        else
          @editor_controller.view.add_status(
            "#{Time.new} '#{document.name}' allready saved ...", "file")
        end
      else
        save_as
      end
    end

    # asks the user to find a place for the new file
    def save_as
      dialog = SaveFileDialog.new(@editor_controller.view)

      if dialog.ok?
        save(dialog.filename)
      else
        @editor_controller.view.add_status(
          "#{Time.new} '#{document.name}' saving stopped!", "file")
      end

      dialog.destroy
    end

    # asks the user to find open a new file 
    # returns the path to the object
    def self.open(parent)
      dialog = OpenFileDialog.new(parent)
      
      path = (dialog.ok?) ?
        dialog.filename :
        nil

      dialog.destroy
      
      return path
    end
  end
end