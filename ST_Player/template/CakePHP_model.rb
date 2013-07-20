<?php
App::uses('AppModel', 'Model');

class <%= $ModelName %> extends AppModel
{
	public $name = '<%= $ModelName %>';
	public $useTable = '<%= $basename %>';
	public $primaryKey = '<%= $primaryKey %>';
	
	// app_model.phpでconfig/validate/<%= $ModelName %>.phpを読み込み
	public $validate = array();
}
