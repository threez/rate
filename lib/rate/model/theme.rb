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
  class TagTheme
    extend DslMethods
    dsl_method :background, :foreground, :italic, :bold, :underline
    attr_reader :name, :scope
  
    def initialize(name, scope, &block)
      @name, @scope = name.to_s, scope.to_s
      instance_eval &block if block_given?
    end
    
    # return a hash that contains all settings as a hash
    def style_hash
      tmp = {}
      tmp[:background] = @background if @background
      tmp[:foreground] = @foreground if @foreground
      tmp[:style] = Pango::FontDescription::STYLE_ITALIC if @italic
      tmp[:weight] = Pango::FontDescription::WEIGHT_BOLD if @bold
      tmp[:underline] = Pango::AttrUnderline::SINGLE if @underline
      tmp
    end
    
    # returns the scopes of the tag
    def scopes
      @scope.to_s.split /,\s*/
    end
  end

  class EditorTheme
    extend DslMethods
    dsl_method :background, :caret, :foreground, 
      :invisibles, :line_highlight, :selection
      
    def initialize(&block)
      instance_eval &block if block_given?
    end
  end

  class Theme
    attr_reader :name, :tags, :editor
    
    def initialize(name, options, &block)
      @name, @options = name, options
      @tags = []
      instance_eval &block if block_given?
    end
    
    def editor(&block)
      @editor ||= EditorTheme.new(&block)
    end
    
    def tag(name, scope, &block)
      tag = TagTheme.new(name, scope, &block)
      @tags << tag
    end
    
    def author
      @options[:author]
    end
    
    def url
      @options[:url]
    end
    
    def comment
      @options[:comment]
    end
  end
end

def theme(name, options, &block)
  Rate::Theme.new(name, options, &block)
end