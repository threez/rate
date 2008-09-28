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
  class Document < Gtk::SourceBuffer
    include Comparable
    
    # basename of an unnamed document
    UNNAMED = "Unnamed" 

    attr_accessor :path, 
      :naming # can be :name or :dir_name

    # open a Document by passed path
    # if path is nil a "Unnamed" document will be generated
    def initialize(path = nil)
      super()
      @naming = :name
      @language = false
      
      # setup handler for formatting the document
      signal_connect("changed") do |buffer|
        apply_syntax_highlight!
      end
      
      # try to fill the object if path is given
      unless (@path = path).nil?
        # one can't undo the initial filling of the document object
        self.non_undoable_action do
          self.text = File.open(path, "r") do |f|
            f.read
          end
        end
        
        # don't notifiy the initial filling of the document
        self.modified = false
      end
    end
    
    # parse the text and place syntax hightlighting where the
    # language syntax matches
    def apply_syntax_highlight!
      if @language and highlight?
        # remove all tags from buffer
        remove_all_tags(start_iter, end_iter)
        
        # and setup new tags for all patterns in the language
        for syntax_element in @language.syntax_patterns do
          apply_tag_regex(syntax_element.scope, syntax_element.regex)
        end
      end
    end

    # return the basename of the opened document
    def name
      if @path.nil?
        name = UNNAMED
      else
        case @naming
        when :name 
          name = File.basename(@path)
        else :dir_name
          name = File.basename(File.dirname(@path)) + 
            File::SEPARATOR + File.basename(@path)
        end
      end

      # add modified marker if document is modified
      if modified?
        return "#{name} *"
      else
        return name
      end
    end

    # do some cleanup of the file (unix like)
    # remove some \r\n and blank lines
    def before_save()
      # convert every thing to unix line feeds
      ntext = text.gsub("\r\n", "\n")

      # remove spaces on empty lines (avoid errors for git)
      ntext = ntext.gsub(/^\s+$/, "")

      # remove spaces at end of lines
      ntext = ntext.gsub(/\s+$/, "")

      # assign new text
      text = ntext
    end

    def after_save()
      self.modified = false
      signal_emit("changed")
    end

    # save the document with the given path
    def save(path = nil)
      if modified? or !path.nil?
        return false if before_save() == false

        # save the new path of the file
        @path = path unless path.nil?

        # write buffer text to file stream
        File.open(@path, "w") do |f|
          f.print text
        end

        return false if after_save() == false
        return true
      else
        return false        
      end
    end
    
    # setup the language of the document and enables highlighting
    def language=(lang, syntax_highlight = true)
      @language = lang
      if syntax_highlight
        self.highlight = true      
        apply_syntax_highlight!
      end
    end
    
    # applys a tag_name by searching for matches of the regex
    def apply_tag_regex(tag_name, regex)
      # make use of match_all method that is defined in support.rb
      raise "#{tag_name} has a nil regex" if regex.nil?
      regex.match_all(text) do |match|
        start_of_region = get_iter_at_offset(match.begin(0))
        end_of_region = get_iter_at_offset(match.end(0))
        apply_tag(tag_name, start_of_region, end_of_region)
      end
    end
    
    # creates style tags based on the given theme
    def create_tags(theme)
      for tag in theme.tags do
        for scope in tag.scopes do 
          ttag = create_tag(scope, tag.style_hash)
          puts " TAG: #{scope} - priority: #{ttag.priority}"
        end
      end
    end
    
    # compare a document trough it's path if the
    # document has no path that it can't be compared
    def <=>(document)
      return 1 if document.path.nil?
      return -1 if @path.nil? 
      return 0 if @path == document.path
    end

    # returns true if there is no text in the buffer 
    def empty?
      text.size == 0
    end

    # returns is the document as a file that belongs to it
    def path_given?
      !@path.nil?
    end

    # will turn syntax highlighting on/off
    def toggle_highlighting
      self.highlight = !highlight?
    end
  end
end
