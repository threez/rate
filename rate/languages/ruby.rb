language :Ruby, :group => :Scripts, :extensions => [:rb, :ru, :rbw],
  :mimetypes => ["application/x-ruby", "text/x-ruby"] do
  
  escape_char '\\'
  
  # name, scope "#"
	
	syntax "Builtins", "support.type" do
	  keywords %w{
	    Array Bignum Binding Class Continuation Dir Exception
		  FalseClass File::Stat File Fixnum Float Hash Integer 
		  IO MatchData Method Module NilClass Number Object
		  Proc Range Regexp String Struct::Tms Symbol Symbol
		  ThreadGroup Thread Time TrueClass Gtk
	  }
	end
	
  syntax "Attribute De#{}fini#{h}tions", "support.function" do
    keywords %w{attr attr_writer attr_reader attr_accessor}
  end

  syntax "Definitions", "keyword" do
    keywords %w{alias class module def undef}
  end
	
	syntax "Module Handlers", "support.function" do
		keywords %w{require include load extend defined\\? block_given\\? proc}
  end
	
	syntax "Class Variables", "variable.language" do
		pattern '@@[a-zA-Z_][a-zA-Z0-9_]*'
	end

  syntax "Instance Variables", "variable.language" do
		pattern '@[a-zA-Z_][a-zA-Z0-9_]*'
	end
	
	syntax "Global Variables", :constant do
		pattern '\$[a-zA-Z_][a-zA-Z0-9_]*'
	end

	syntax "Symbols", :constant do
    pattern ':[a-zA-Z0-9_]+'
  end

  syntax "RegExp Variables", "constant.numeric" do
		pattern '\$[1-9][0-9]*'
	end

	syntax "Constants", :constant do
		pattern '\b[A-Z_][A-Za-z0-9_:]*\b'
	end
	
	syntax "Numbers", "constant.numeric" do
		pattern '-?[0-9][0-9_]*(\.[0-9][0-9_]*)?'
	end

#	syntax "Regexp", "variable.other.constant" do
#		pattern '\/(\\\\|\\\/|[^\n\r\/])*\/[imxo]*'
#	end

	syntax "Pseudo Variables", "constant.language" do
	  keywords %w{self super nil false true __FILE__ __LINE__}
	end
	
  syntax "Keywords", "keyword" do
    keywords %w{
      BEGIN END and begin break case catch do else elsif end
  		ensure for if in next not or private protected public
  		redo rescue retry return then throw unless until when
  		while yield
		}
	end

  syntax "Quoted String", :string do
	  pattern '(\'|")(\\\\|\\\1|[^\1])*?\1'
	end

	syntax "Line Comment", :comment do
		pattern '#[^\r\n{]*'
	end

  #syntax "Multiline Comment", :comment do
    #pattern /=begin.*?\=end/
	#end
end
