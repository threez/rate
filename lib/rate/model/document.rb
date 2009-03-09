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
      signal_connect("end-user-action") do |buffer|
        apply_syntax_highlight!
      end
      
      #signal_connect("insert-child-anchor") do |oself, iter, anchor|
      #  puts [iter.offset, anchor].inspect
      #end
      
      #signal_connect("insert-text") do |oself, iter, text, len|
      #  puts [iter.offset, text, len].inspect
      #  syntax_highlight!(text, iter.offset)
      #end
      
      # try to fill the object if path is given
      unless (@path = path).nil?
        # one can't undo the initial filling of the document object
        self.non_undoable_action do
          self.text = File.open(path, "r") do |f|
            f.read.gsub("\r\n", "\n") # remove windows CRLF
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
        # kill the latest highlighter becasue we want the newest changes
        @highlighter.kill if @highlighter
        
        @highlighter = Thread.new do
          sleep 0.010 # sleep to reduce overhead of multiple begins
          
          begin
            syntax_highlight!(self.text, 0)
          rescue => ex
            puts "Error on hightlight: #{ex}"
            ex.backtrace.each { |l| puts " --> #{l}" }
          end
          
          # no current highlighter
          @highlighter = nil
        end
      end
    end
    
    # apply syntax highklighting to the textmodel
    def syntax_highlight!(text, offset)
      last_end_i = get_iter_at_offset(offset)
      
      if @language and highlight?
        @language.highlight(text, offset).each do |start_pos, end_pos, scope|
          # start and end position for the tag
          start_i = get_iter_at_offset(start_pos)
          end_i = get_iter_at_offset(end_pos)

          # remove all tags that where there before
          remove_all_tags last_end_i, start_i
          
          # apply the new tag
          apply_tag scope, start_i, end_i
          
          last_end_i = end_i
        end
      end
    end
    
    # find a language to accomplish highlighting the document
    def setup_highlight!
      self.language = LanguageManager.instance.lang_for(self)
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
      #ntext = text.gsub("\r\n", "\n")

      # remove spaces on empty lines (avoid errors for git)
      #ntext = ntext.gsub(/^\s+$/, "")

      # remove spaces at end of lines
      #ntext = ntext.gsub(/\s+$/, "")

      # assign new text
      #self.text = ntext
    end

    def after_save()
      self.modified = false
      setup_highlight! unless highlight?# will highlight after save 
      signal_emit("end-user-action")
    end

    # save the document with the given path
    def save(path = nil)
      if modified? or !path.nil?
        before_save()

        # save the new path of the file
        @path = path unless path.nil?

        # write buffer text to file stream
        File.open(@path, "w") do |f|
          f.print text
        end

        after_save()   
      end
    end
    
    # setup the language of the document and enables highlighting
    def language=(lang, syntax_highlight = true)
      @language = lang
      if syntax_highlight and !lang.nil?
        self.highlight = true      
        apply_syntax_highlight!
      end
    end
    
    # creates style tags based on the given theme
    def create_tags(theme)
      for tag in theme.tags do
        for scope in tag.scopes do 
          ttag = create_tag(scope, tag.style_hash)
          #puts " TAG: #{scope} - priority: #{ttag.priority}"
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
      if highlight?
        apply_syntax_highlight!
      else
        remove_all_tags start_iter, end_iter
      end 
    end
  end
end
