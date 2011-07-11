$(function() {
  $('#problem-tabs').tabs({ remote: true, cache: true, spinner: '&nbsp; <img src="/images/loading.gif" /> &nbsp;' });
  $('#tabs').tabs({ remote: true, cache: true, spinner: '&nbsp; <img src="/images/loading.gif" /> &nbsp;' });

  $("#flow_pagination a").live("click", function() {
    $(this).html("").addClass("loading");
    $.get(this.href, null, null, "script");
    return false;
  });

  $('.load-solutions').live("click", function(){
    var href = $(this).attr('href');
    $('#solved').slideUp('fast', function(){
         $('#spinner').show();
         $.get(href, function(resp){
           $('#spinner').hide();
           $('#solved').html(resp);
           $('#solved').slideDown('slow');
         });
         });
    return false;
    });

  $('.watch input').change(
    function(){
      if ($(this).is(':checked')) {
        $.get('/watchers/' + $(this).val() + '/watch');
      }else{
        $.get('/watchers/' + $(this).val() + '/unwatch');  
      }
    }
  );

  $.syntax({root: "/javascripts/syntax/"});
});