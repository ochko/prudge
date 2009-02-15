xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do

    xml.title       "Coder.mn - Хэлэлцүүлэг"
    xml.link        url_for :only_path => false, :controller => 'topics'
    xml.pubDate     CGI.rfc1123_date @comments.first.created_at if @comments.any?
    xml.description "Кодер.МН ийн хэлэлцүүлгийн сүүлийн бичээсүүд"

    @comments.each do |comment|
      xml.item do
        xml.title       truncate(comment.text)
        xml.link        url_for :only_path => false, :controller => 'topics', :action => 'show', :id => comment.topic_id, :type => comment.topic_type.downcase.pluralize,:anchor=>comment.id
        xml.description comment.text
        xml.pubDate     CGI.rfc1123_date comment.created_at
        xml.guid        url_for :only_path => false, :controller => 'topics', :action => 'show', :id => comment.topic_id, :type => comment.topic_type.downcase.pluralize,:anchor=>comment.id
        xml.author      "#{comment.login}"
      end
    end

  end
end
