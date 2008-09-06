module Rate
  class FilePane < Gtk::TreeView
    TEXT_COLUMN = 0
    COLOR_COLUMN = 1

    def initialize(editor)
      super(Gtk::TreeStore.new(Symbol, String))
      @editor = editor
      show_expanders = true
      column = Gtk::TreeViewColumn.new "Files"

      # icon renderer and column
      @cell_renderer_0 = Gtk::CellRendererPixbuf.new
      column.pack_start(@cell_renderer_0, false)
      column.set_cell_data_func(@cell_renderer_0) do |column, cell, model, iter|
        cell.stock_id = iter.get_value(0)
      end

      # Filename renderer and column
      @cell_renderer_1 = Gtk::CellRendererText.new
      column.pack_start(@cell_renderer_1, true)
      column.set_cell_data_func(@cell_renderer_1) do |column, cell, model, iter|
        cell.text = File.basename(iter.get_value(1))
      end

      append_column(column)
      expander_column = column

      signal_connect "row-activated" do |sel, path, column|
        fpath = model.get_iter(path)[1]
        unless File.directory? fpath
          @editor << Document.create_from_source_file(fpath, @editor.theme)
        end
      end
    end

    def build_tree(path, parent = nil)
      Dir[path  + "/*"].each do |fobj|
        text = fobj

        row = model.append(parent)

        if File.directory? fobj then
          row[0] = Gtk::Stock::OPEN
          build_tree(fobj, row)
        else
          row[0] = Gtk::Stock::FILE
        end
        row[1] = text
      end
    end
  end
end
