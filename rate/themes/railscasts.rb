theme :Railscasts, :author => "Vincent Landgraf",
  :url => "http://www.railscastscom", :comment => "adopted from railscasts theme" do
  
  editor do
    background "#2B2B2B"
    caret "#FFFFFF"
    foreground "#E6E1DC"
		invisibles "#404040"
		line_highlight "#333435"
		selection "#5A6470"
  end
  
  # name, scope
  tag "Constant (built-in)", "constant.language" do
    foreground "#6E9CBE"
  end
  
  tag :Source, :source do
    background "#232323"
  end
  
  tag :Keyword, "keyword, storage" do
    foreground "#CC7833"
  end
  
  tag "Function (definition)", "entity.name.function, keyword.other.name-of-parameter.objc" do
    foreground "#FFC66D"
  end
  
  tag "Class (definition)", "entity.name" do
    foreground "#FFFFFF"
  end
  
  tag :Number, "constant.numeric" do
    foreground "#A5C261"
  end
  
  tag :Variable, "variable.language, variable.other" do
    foreground "#D0D0FF"
  end
  
  tag :Constant, :constant do
    foreground "#6D9CBE"
  end
  
  tag "Constant (other variable)", "variable.other.constant" do
    foreground "#DA4939"
  end
  
  tag "Library function", "support.function" do
    foreground "#DA4939"
  end
  
  tag "Library type", "support.type" do
    foreground "#6E9CBE"
  end
  
  tag "Library constant", "support.constant" do
    foreground "#A5C261"
  end
  
  tag "Markup tag", "meta.tag, declaration.tag, entity.name.tag, entity.other.attribute-name" do
    foreground "#E8BF6A"
  end
  
  tag :Invalid, :invalid do
    background "#990000"
    foreground "#FFFFFF"
  end
  
  tag "String interpolation", "constant.character.escaped, constant.character.escape, string source, string source.ruby" do
    foreground "#519F50"
  end
  
  tag "Diff Add", "markup.inserted" do
    background "#144212"
    foreground "#E6E1DC"
  end
  
  tag "Diff Remove", "markup.deleted" do
    background "#660000"
    foreground "#E6E1DC"
  end
  
  tag "Diff Header", "meta.diff.header, meta.separator.diff, meta.diff.index, meta.diff.range" do
    background "#2F33AB"
  end
  
  
  tag :Comment, :comment do
   # italic true
    foreground "#BC9458"
  end
  
  tag :String, :string do
    foreground "#A5C261"
  end
end
