$(function() {
    var $window = $(window);

    var searchHints;

    $('#search').typeahead({
        source: function (query, process) {
            if (searchHints == undefined) {
                $.get('/searches.json', {}, function (data) {
                    searchHints = data;
                    return searchHints;
                });
            }else{
                return searchHints;
            }
        }
    });

    $('#language-logos, #profile-vcard, #header-tooltip, #watcher').tooltip({
        selector: "[data-toggle=tooltip]"
    });

  $('.markdown-editor .help-link span').click(function(){
    window.open($(this).attr('href'), '_blank');
  });
  $('.markdown-preview').click(function(){
    var text = $('#editor-input textarea').val(),
        preview = $('#editor-preview');

    preview.html('<div class="icon-container"><i class="muted icon-spin icon-spinner x6"></i></div>');

    $.ajax({
      url: '/markdown',
      type: 'POST',
      dataType: 'html',
      data: {text: text},
      success: function(data) {
        preview.html(data);
      },
      error: function(){
        preview.html('<div class="icon-container"><i class="muted icon-warning-sign x6"></i></div>');
      }
    });
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

  // polls submission check
  function pollSolutionCheck() {
    var checkWait = $('#check-wait-link'),
        resultContent = $('#result-content');
    if (checkWait.length > 0) {
      $.ajax({
        url: checkWait.attr('href'),
        type: 'GET',
        dataType: 'html',
        success: function(data) {
          if (data.length !== 0 && data.trim()){
            resultContent.replaceWith(data);
          }
        },
        complete: function(xhr, status){
          if (!status.match(/error/)) {
            setTimeout(pollSolutionCheck, 5000);
          }
        }
      });
    }
  }

  if ($('#check-wait-link').length > 0){
    setTimeout(pollSolutionCheck, 5000);
  }

    $('#watch').click(function(e) {
        $(this).hide();
        $('#unwatch').show();
    });
    $('#unwatch').click(function(e) {
        $(this).hide();
        $('#watch').show();
    });

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

    $('#profile-tabs a, #problem-tabs a, #contest-tabs a').click(function (e) {
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
              var solutionsTable = $('#solutions-table');
              if (solutionsTable.length > 0) {
                solutionsTable.find('thead .toggler').click(function(e) {
                  solutionsTable.find('tbody tr.failed').toggle();
                    var klass = $(this).hasClass('icon-check-empty') ? 'icon-check' : 'icon-check-empty';
                    $(this).removeClass().addClass(klass);
                });

                solutionsTable.tablesorter({headers: { 0: {sorter: false},
                                                       1: {sorter: false}
                                                     }});
              }
            },
            error: function(xhr, message) {
              if (xhr.status === 200 && message === 'parsererror') {
                // response is text, but jquery is trying to convert to json or js
                target.html(xhr.responseText);
              }else{
                target.html('AJAX Error');
              }
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

    $('#contestants .loader').live("click", function(){
        var href = $(this).attr('href');
        var icon = $(this).find('i');
        var standing = $(this).closest('tr').find('.standing');
        $('#solved').slideUp('fast', function(){
            icon.addClass('icon-spin');
            $.get(href, function(resp){
                icon.removeClass('icon-spin');
                $('#solved').html(resp);
                $('#solved').slideDown('slow');
                if(window.innerWidth <= 800) {
                    $(document.body).scrollTop($('#standing').offset().top);
                }
            });
        });
        return false;
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

	$('#solution-percent .progress-cirque').cirque ({
		radius: 80,
		total: 100,
		lineWidth: 15,
        arcColor: '#94BA65',
		trackColor: '#CCCCCC',
	});

    $("#topnav > li > a[href*='"+window.location.pathname.split('/')[1]+"']").parent().addClass('active');
});
