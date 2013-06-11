<?php
Configure::Write('COLUMN_LIST_<%= $MODELNAME %>', array(
<%
	recordset[0,recordset.length].each do |record|
		$name = record["name"].downcase
		$comment = record["comment"]
%>	'<%= $name %>' => '<%= $comment %>',
<%
	end
%>));
?>