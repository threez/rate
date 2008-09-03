$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'gtk2'
require 'gtksourceview'

if __FILE__ == $0 then
  rate = Rate::Editor.new

  while (filename = ARGV.shift)
    rate << Rate::Document.create_from_source_file(filename, rate.theme)
  end

  #rate << Document.create("unknown", Time.now.to_s)
  #rate << Document.create("unknown 1", Time.now.to_s)
  #rate << Document.create("unknown 2", Time.now.to_s)
  #rate << Document.create("unknown 3", Time.now.to_s)

  rate.show_all
  Gtk.main
end