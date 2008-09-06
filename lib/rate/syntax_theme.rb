module Rate
  class SyntaxTheme
    MIMES = {
      '.rb' => 'text/x-ruby',
      '.ru' => 'text/x-ruby',
      '.html' => 'text/html',
      '.htm' => 'text/html'
    }

    def initialize(theme)
      @theme = theme
      @lang_manager = Gtk::SourceLanguagesManager.new
    end

    def lang_for(ext)
      return nil if MIMES[ext].nil?
      lang = @lang_manager.get_language(MIMES[ext])
      theme_lang(lang)
    end

  private

    def theme_lang(lang)
      for tag in lang.tags do
        cname = Theme::TRANSLATION_TM_THEME[tag.id]
        unless cname.nil?
          style = tag.style

          # foreground color
          if @theme[cname].foreground then
            style.mask |= Gtk::SourceTagStyle::USE_FOREGROUND
            style.foreground = Gdk::Color.parse(@theme[cname].foreground)
          end

          if @theme[cname].background then
            style.mask |= Gtk::SourceTagStyle::USE_BACKGROUND
            style.background = Gdk::Color.parse(@theme[cname].background)
          end

          # options
          style.italic = true if /italic/.match(@theme[cname].fontStyle)

          lang.set_tag_style(tag.id, style)
        end
      end
      return lang
    end
  end
end
