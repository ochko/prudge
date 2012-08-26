require 'test/unit'
require 'rubygems'
require 'active_support'
require 'action_controller'
require 'action_view'

require File.dirname(__FILE__) + '/../lib/wmd_on_rails'
class WmdOnRailsTest < Test::Unit::TestCase
  include WmdOnRails::EditorHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::JavaScriptHelper
  
  def test_enable_wmd
    js = enable_wmd
    assert_match /script src="\/javascripts\/wmd\/wmd.js"/, js
    assert_match /"output": "Markdown"/, js
    
    js = enable_wmd :autostart => false
    assert_match /"autostart": false/, js
  end
  
  def test_wmd_preview
    html = wmd_preview
    assert_equal html, '<div class="wmd-preview"></div>'
    
    html = wmd_preview(:tag => 'p', :class => 'holy-water')
    assert_equal html, '<p class="holy-water wmd-preview"></p>'
  end
end
