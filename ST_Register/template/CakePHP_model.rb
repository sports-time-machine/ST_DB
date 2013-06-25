<?php
App::uses('AppModel', 'Model');

class <%= $ModelName %> extends AppModel
{
	public $name = '<%= $ModelName %>';
	public $useTable = '<%= $basename %>';
	public $primaryKey = '<%= $primaryKey %>';
	
	// app_model.phpでconfig/column_list/<%= $ModelName %>.php, config/validate/<%= $ModelName %>.phpを読み込み
	public $column_list = array();
	public $validate = array();
}
