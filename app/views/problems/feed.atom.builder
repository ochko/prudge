xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Coder.mn ийн бодлогууд"
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'problems', :action => 'feed')
  xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'problems')
  xml.id      url_for(:only_path => false, :controller => 'problems')
  xml.updated @problems.first.created_at.strftime "%Y-%m-%dT%H:%M:%SZ" if @problems.any?
  xml.author  { xml.name "Ochirkhuyag.L" }

  @problems.each do |problem|
    xml.entry do
      xml.title   problem.name
      xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'problems', :action => 'show', :id => problem.id)
      xml.id      url_for(:only_path => false, :controller => 'problems', :action => 'show', :id => problem.id)
      xml.updated problem.created_at.strftime "%Y-%m-%dT%H:%M:%SZ"
      xml.author  { xml.name problem.login }
      xml.summary problem.text
      xml.content "type" => "html" do
        xml.text! problem.text
      end
    end
  end

end
