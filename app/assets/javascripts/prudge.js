$(function() {
    var $window = $(window)

    $('#language-logos, #profile-vcard, #header-tooltip, #watcher').tooltip({
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

                $('#solutions-table thead .toggler').click(function(e) {
                    $('#solutions-table tbody tr.failed').toggle();
                    klass = $(this).hasClass('icon-check-empty') ? 'icon-check' : 'icon-check-empty';
                    $(this).removeClass().addClass(klass);
                });

                $("#solutions-table").tablesorter({headers: { 0: {sorter: false},
                                                              1: {sorter: false}
                                                            }});
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

	$('#solution-percent .progress-cirque').cirque ({
		radius: 80,
		total: 100,
		lineWidth: 15,
        arcColor: '#94BA65',
		trackColor: '#CCCCCC',
	});

    $("#topnav > li > a[href*='"+window.location.pathname.split('/')[1]+"']").parent().addClass('active');
});
