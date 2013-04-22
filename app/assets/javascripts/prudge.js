$(function() {
  var $window = $(window)

  $('#language-logos, #profile-vcard').tooltip({
      selector: "[data-toggle=tooltip]"
  });

  // side bar
  setTimeout(function () {
    $('.prudge-sidenav').affix({
      offset: {
        top: function () { return $window.width() <= 980 ? 290 : 210 }
      , bottom: 270
      }
    })
  }, 100);

  var ajaxBtnIcon;
  $(document).on("ajaxStart", function(e, xhr, settings, exception)  {
    var btn = $("#submit");
    if (btn.length == 0) return;
    btn.attr('disabled', 'disabled');
    var icon = btn.find('i')
    if (icon.length == 0) return;
    ajaxBtnIcon = btn.find('i').attr('class');
    icon.removeClass().addClass('icon-refresh icon-spin');
  });

  $(document).on("ajaxComplete", function(e, xhr, settings, exception)  {
    var btn = $("#submit");
    if (btn.length == 0) return;
    btn.removeAttr('disabled');
    var icon = btn.find('i')
    if (icon.length == 0) return;
    icon.removeClass().addClass(ajaxBtnIcon);
  });

  $('#profile-tabs a, #problem-tabs a').click(function (e) {
    e.preventDefault();
    $(this).tab('show');

    var delegate = $(this).data("delegate");
    if (delegate != undefined) {
      $(delegate).click();
      return;
    }

    var link = $(this).data("link");
    if (link == undefined) return;

    var target = $($(this).attr("href"));
    if (target.data('loaded') != undefined) return;

    var icon = $(this).find('i');
    var iconClass = icon.attr('class');
    icon.removeClass().addClass('icon-refresh icon-spin');
    
    $.ajax({
          url: link,
          type: 'GET',
          success: function(data, status, xhr) {
              target.html(data);
          },
          error: function(xhr, status, message) {
              target.html("Error");
          },
          complete: function(xhr, status){
              icon.removeClass().addClass(iconClass);
              target.data('loaded', 'true');
          }
      });
  });

  $("a.page-flow").click(function(e) {
    e.preventDefault();

    var link = $(this);
    var url  = link.attr("href");
    var page = parseInt(link.data('page'));
    var flow = $(link.data('flow'));
    var icon = link.find('i');

    var iconClass = icon.attr('class');
    icon.removeClass().addClass('icon-refresh icon-spin');
    link.addClass('disabled');
    $.ajax({
      url: url+"?page="+page,
      type: 'GET',
      success: function(data, status, xhr) {
          flow.append(data);
      },
      error: function(xhr, status, message) {
          link.hide();
      },
      complete: function(xhr, status){
          icon.removeClass().addClass(iconClass);
          link.data('page', page + 1);
          link.removeClass('disabled');
      }
    });
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

  $('#check-button').click(function(){
      $('#check-button').hide();
      $('#result-content').hide();
      $('#check-wait').show();
  });

  $('#comment-form').submit(function(e){
      $('#comment-spinner').show();
      $('#comment-message').html('');
      $('#comment-form').disable();

      $.ajax({
          url: $(this).attr("action"),
          type: 'POST',
          data: $(this).serialize(),
          success: function(data, status, xhr) {
              $('#comment_text').val('');
              $('#comments').prepend(data);
          },
          error: function(xhr, status, message) {
              $('#comment-message').html(message);
          },
          complete: function(xhr, status){
              $('#comment-spinner').hide();
              $('#comment-form').enable();
          }
      });

      return false;
  });

});
