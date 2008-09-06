
require 'gtk2'
require 'gtksourceview'

require File.dirname(__FILE__) + "/rate/editor"

if __FILE__ == $0 then
  rate = Rate::Editor.new

  files = 0
  begin
    if !ARGV.first.nil? and File.directory? ARGV.first
      # just open the directory in the file_pane
      rate.open_directory(ARGV.shift)
    else
      # add all files
      while (filename = ARGV.shift)
        rate << Rate::Document.create_from_source_file(filename, rate.theme)
        files += 1
      end
    end
  rescue
  ensure
    # display new tab is file or directory is wrong
    rate.create_new_document if files == 0
  end


#  begin
#    require 'plist'
#  rescue LoadError
#    require 'rubygems'
#    require 'plist'
#  end
 ## require "pp"

  #module Rate
  #  class Syntax
  #    def initialize(path)
  #      @path = path
  #      @plist = Plist::parse_xml(path)#

        #pp @plist
  #    end

  #    def to_s
  #      names = []
  #      @plist.each do |item|
  #        puts "=== " * 10
  #        puts item.inspect
  #        names << item["name"] if item.class == Hash
  #      end
  #      names.join("\n")
  #    end
  #  end
  #end

  #syntax = Rate::Syntax.new("bundles/Ruby.tmbundle/Syntaxes/Ruby.plist")
  #rate << Rate::Document.create("Ruby.plist", syntax.to_s, rate.theme)

  Gtk.main
end
