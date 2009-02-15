xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do

    xml.title       "Coder.mn - Бодлогууд"
    xml.link        url_for :only_path => false, :controller => 'problems'
    xml.pubDate     CGI.rfc1123_date @problems.first.created_at if @problems.any?
    xml.description "Кодер.МН сайт дээр сүүлд нэмэгдсэн бодлогууд"

    @problems.each do |problem|
      xml.item do
        xml.title       problem.name
        xml.link        url_for :only_path => false, :controller => 'problems', :action => 'show', :id => problem.id
        xml.description problem.text
        xml.pubDate     CGI.rfc1123_date problem.created_at
        xml.guid        url_for :only_path => false, :controller => 'problems', :action => 'show', :id => problem.id
        xml.author      "#{problem.login}"
      end
    end

  end
end
