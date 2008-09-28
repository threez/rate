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
  class Syntax
    extend DslMethods
    dsl_method :pattern, :keywords
    attr_reader :name, :scope
    
    def initialize(name, scope, &block)
      @name, @scope = name.to_s, scope.to_s
      instance_eval &block if block_given?
    end
    
    def regex
      # generate the pattern if the pattern is nil
      # this implyes that keywords is set otherwise
      # throw an error
      if @regex.nil? and @pattern.nil? and !@keywords.nil?
        @pattern = '\b(' + @keywords.join('|') + ')\b'
      elsif @pattern.nil? and !@keywords.nil?
        raise "Error syntax element #{@name} (#{@scope}) has no pattern!"
      end
      
      # return the regex (but generate it once)
      @regex ||= Oniguruma::ORegexp.new(@pattern)
    rescue ArgumentError => ae
      raise "Error in syntax element #{@name} (#{@scope}) illegal pattern syntax!\n#{ae}"    
    end
  end
  
  class Language
    extend DslMethods
    dsl_method "escape_char"
    attr_reader :syntax_patterns
  
    def initialize(name, options, &block)
      @name, @options = name.to_s, options
      @syntax_patterns = []
      begin
        instance_eval &block if block_given?
      rescue => ex
        raise("Error in language definition (#{@name}): #{ex}")
      end
    end
    
    def syntax(name, scope, &block)
      syntax = Syntax.new(name, scope, &block)
      @syntax_patterns << syntax
    end
    
    def group
       @options[:group]
    end
    
    def extensions
       @options[:extensions]
    end
    
    def mimetypes
       @options[:mimetypes]
    end
    
    def method_missing(*args)
    end
  end
  
  class LanguageManager
    def self.instance
      new
    end
    
    def lang_for(document)
      @@lang ||= Resource.load_language("F:/rate/rate/languages/ruby.rb")
    end
  end
end

def language(name, options, &block)
  Rate::Language.new(name, options, &block)
end