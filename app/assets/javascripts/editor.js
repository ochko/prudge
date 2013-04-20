//= require wmd/wmd
//= require wmd/showdown

$(function(){
  if (0<$('#editor-input').length) {
  new WMDEditor({
    input: "editor-input",
    button_bar: "editor-buttons",
    preview: "editor-preview",
    helpLink: "http://daringfireball.net/projects/markdown/syntax"
  });
}
})
