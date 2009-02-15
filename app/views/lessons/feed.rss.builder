xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do

    xml.title       "Coder.mn - Хичээлүүд"
    xml.link        url_for :only_path => false, :controller => 'lessons'
    xml.pubDate     CGI.rfc1123_date @lessons.first.created_at if @lessons.any?
    xml.description "Кодер.МН сайт дээрхи прогррамчлалын хичээлүүд"

    @lessons.each do |lesson|
      xml.item do
        xml.title       lesson.title
        xml.link        url_for :only_path => false, :controller => 'lessons', :action => 'show', :id => lesson.id
        xml.description lesson.text
        xml.pubDate     CGI.rfc1123_date lesson.created_at
        xml.guid        url_for :only_path => false, :controller => 'lessons', :action => 'show', :id => lesson.id
        xml.author      "#{lesson.login}"
      end
    end

  end
end
