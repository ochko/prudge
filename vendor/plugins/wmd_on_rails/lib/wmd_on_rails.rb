module WmdOnRails
  module EditorHelper
    def enable_wmd(user_params = {})
      default_params = {
        :output => 'Markdown', :autostart => false
      }
      params = default_params.merge(user_params)
      
      output = javascript_tag "wmd_options = #{params.to_json}"
      output += javascript_include_tag "wmd/wmd"
      output
    end
    
    def wmd_preview(params = {})
      id = params[:id] || 'wmd-preview'
      params = { :tag => :div, :class => '' }.merge(params)
      
      tag = params[:tag]
      html_class = params[:class].split(/\s+/).push('wmd-preview').join(" ")
      
      content_tag(tag, '', :class => html_class, :id => id)
    end

    def create_wmd(textarea_id, preview_id = nil)
      js = <<EOF
var #{textarea_id} = document.getElementById(#{textarea_id.inspect});
EOF
      if preview_id
        js += <<EOF
var #{textarea_id}_preview = document.getElementById(#{preview_id.inspect});
var #{textarea_id}_panes = {input: #{textarea_id}, preview: #{textarea_id}_preview, output: null};
var #{textarea_id}_previewManager = new Attacklab.wmd.previewManager(#{textarea_id}_panes);
var #{textarea_id}_editor = new Attacklab.wmd.editor(#{textarea_id}, #{textarea_id}_previewManager.refresh);
EOF
      else
        js += <<EOF
var #{textarea_id}_editor = new Attacklab.wmd.editor(#{textarea_id});
EOF
      end

      javascript_tag js
    end

  end
end
