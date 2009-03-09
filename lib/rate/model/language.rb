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
  require "coderay"
rescue LoadError
  require "rubygems"
  require "coderay"
end

module Rate
  # in terms of coderay this is the abstract encoder for the text view element
  # of gtkk
  class Styler
    def initialize()
      @offsets = {}
    end
    
    # push one offset to the list. The name is the  
    # name of the stack, the value the offset that
    # should be saved for later used
    def push_offset(name, value)
      @offsets[name] = [] unless offset?(name)
      @offsets[name] << value
    end
    
    # pops last element of stack of passed name
    def pop_offset(name)
      @offsets[name].shift
    end
    
    # returns true if the stack (name) contains a value
    def offset?(name)
      !@offsets[name].nil? and !@offsets[name].empty?
    end

    # highlight all elements of a tokenlist 
    # start the highlighting with offset
    def highlight(token_list, offset)
      highlight_list = []
      
      token_list.each do |token, token_class|      
        highlight_token(highlight_list, token, token_class, offset)
        offset = calc_offset(offset, token) # move offset ahead
      end
      
      return highlight_list
    end
    
    # create new entry as array of format
    #   [start, end, tag_name]
    def tag_mark(offset, token, scope)
      [offset, offset + token.size, scope]
    end
    
    # calulate new offset based on the string
    def calc_offset(offset, token)
      if token.class == String
        #offset + token.size
        offset + token.unpack("U*").size
      else
        offset
      end
    end
  end

  class Language  
    def initialize(name, options, &block)
      @name, @options = name.to_s, options
    end
    
    def extensions
       @options[:extensions]
    end
    
    def scanner
       @options[:scanner]
    end
    
    def styler
       @options[:styler]
    end
    
    # returns true whenever the document can be hightlighted otherwise false
    def can_highlight?(document)
      extname = File.extname(document.path.gsub("//", "/")) if document.path_given?
    
      if !extname.nil? and !extname.empty?
        return extensions.include?(extname.gsub(".", "").to_sym)
      end
      
      return false
    end 
    
    # hightlight the given text starting at the offset
    def highlight(text, offset = 0)
      @styler ||= self.styler.new
      @styler.highlight(CodeRay.scan(text, scanner), offset)
    end
  end
  
  class LanguageManager
    def initialize()
      @lang = []
      
      Dir["languages/*.rb"].each do |path|
        @lang << Resource.load_language(path)
      end
    end
  
    def self.instance
      @@inst ||= new
    end
    
    def lang_for(document)
      @lang.each do |lang|
        return lang if lang.can_highlight? document
      end
      return nil # if no language was found
    end
  end
end

def language(name, options, &block)
  Rate::Language.new(name, options, &block)
end
