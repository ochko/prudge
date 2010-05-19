$(function() {
	$('#tabs').tabs();
	$('#problem-tabs').tabs({ remote: true });
	$("#flow_pagination a").live("click", function() {
		$(this).html("").addClass("loading");
		$.get(this.href, null, null, "script");
		return false;
	    });
    });