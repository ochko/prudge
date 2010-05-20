xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do

    xml.title       "Coder.mn - Хичээлүүд"
    xml.link        lessons_url :only_path => false
    xml.pubDate     CGI.rfc1123_date @lessons.first.created_at if @lessons.any?
    xml.description "Кодер.МН сайт дээрхи хичээлүүд"

    @lessons.each do |lesson|
      xml.item do
        xml.title       lesson.title
        xml.link        lesson_url lesson, :only_path => false
        xml.description lesson.text
        xml.pubDate     CGI.rfc1123_date lesson.created_at
        xml.guid        lesson_url lesson, :only_path => false
        xml.author      "#{lesson.author.login}"
      end
    end

  end
end
