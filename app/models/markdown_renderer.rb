class MarkdownRenderer < Redcarpet::Render::HTML
  def table(header, body)
    "\n<table class='table table-bordered'><thead>\n#{ header }</thead><tbody>\n#{ body }</tbody></table>\n"
  end

  def self.render(text)
    renderer = new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, tables: true)
    markdown.render(text)
  end
end
