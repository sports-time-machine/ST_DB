<?php
Configure::Write('VALIDATE_<%= $MODELNAME %>', array(
<%
	rules = []
	recordset[0,recordset.length].each do |record|
		name = record["name"].downcase

		subrules = []
		$count = 0
		record["rule"].each do |rule|
			count = $count.to_s
			if rule[:rule] != nil
				$subrule = <<-"EOL"
		'rule#{count}' => array(
			'rule' => #{rule[:rule]},
			'message' => '#{rule[:message]}',
			'allowEmpty' => #{rule[:allowEmpty]},
		)
				EOL
				subrules << $subrule.chomp # 末尾の改行を削って配列に追加
				$count += 1
			end
		end
		subrule = subrules.join(",\n")
		$rule = <<-"EOL"
	'#{name}' => array(
#{subrule}
	)
		EOL
		rules << $rule.chomp # 末尾の改行を削って配列に追加
		end
	
	$rule = rules.join(",\n")
	
%><%= $rule %>
));
?>