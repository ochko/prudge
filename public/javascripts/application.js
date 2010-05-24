$(function() {
	$('#problem-tabs').tabs({ remote: true, cache: true, spinner: '&nbsp; <img src="/images/loading.gif" /> &nbsp;' });
	$('#tabs').tabs({ remote: true, cache: true, spinner: '&nbsp; <img src="/images/loading.gif" /> &nbsp;' });

  $("#flow_pagination a").live("click", function() {
    $(this).html("").addClass("loading");
    $.get(this.href, null, null, "script");
    return false;
  });
});