module ApplicationHelper
  def source_label(article)
    case article.source
    when "reddit"
      "r/#{article.source_name}"
    when "hackernews"
      "HN"
    when "lobsters"
      "Lobste.rs"
    when "devto"
      "Dev.to"
    when "indiehackers"
      "IH"
    else
      article.source_name
    end
  end
end
