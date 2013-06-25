#! ruby -Ku
# このファイルは UTF-8(BOM無) で保存すること
# 
require 'kconv'
require 'erb'
require 'rubygems'
require 'roo'
require 'active_record'
require 'active_support'
require 'active_support/inflector'

# ------------------------------------------------------------
# 変数
# ------------------------------------------------------------
# OpenOffice, Google SpreadSheet, xls, xlsx
DOCUMENT_FILE   = "db.xlsx"
GENERATE_DIR    = "generate"
TEMPLATE_DIR    = "template"
OUTPUT_ENCODING = Kconv::UTF8
# Directory Separator '/' or '\\'
DS              = File::ALT_SEPARATOR || File::SEPARATOR

# ------------------------------------------------------------
# ディレクトリの準備
# ------------------------------------------------------------
# ディレクトリを作成
Dir::mkdir GENERATE_DIR if !FileTest.exists?(GENERATE_DIR)
Dir::mkdir GENERATE_DIR + DS + "CakePHP_models" if !FileTest.exists?(GENERATE_DIR + DS + "CakePHP_models")
Dir::mkdir GENERATE_DIR + DS + "CakePHP_config" if !FileTest.exists?(GENERATE_DIR + DS + "CakePHP_config")
Dir::mkdir GENERATE_DIR + DS + "CakePHP_config" + DS + "column_list" if !FileTest.exists?(GENERATE_DIR + DS + "CakePHP_config" + DS + "column_list")
Dir::mkdir GENERATE_DIR + DS + "CakePHP_config" + DS + "validate" if !FileTest.exists?(GENERATE_DIR + DS + "CakePHP_config" + DS + "validate")


# all.sqlを空にしておく
filename = GENERATE_DIR + DS + "all.sql"
f = open(filename, "w")
f.close
# all_drop.sqlを空にしておく
filename = GENERATE_DIR + DS + "all_drop.sql"
f = open(filename, "w")
f.close

# ------------------------------------------------------------

def upcaseFirst msg
  return msg.slice(0, 1).upcase + msg.slice(1, msg.length)
end

def downcaseFirst msg
  return msg.slice(0, 1).downcase + msg.slice(1, msg.length)
end



# Excelファイルを開く
spreadsheet = Roo::Spreadsheet.open(DOCUMENT_FILE)


# リスト
$basename_list = []
$sheetname_list = []

# シート毎の処理
spreadsheet.sheets.each do |sheet|
	# 出力先ディレクトリ＝シート名
	dirname = sheet
	# 出力先ディレクトリ作成
	Dir::mkdir GENERATE_DIR + DS + "#{dirname}" if !FileTest.exists?(GENERATE_DIR + DS + "#{dirname}")

	# テーブル名 = セルC2
	tablename = spreadsheet.cell(2, 3, sheet).downcase
	next if tablename.nil?  ### テーブル名がNullの時はスキップする

	# ベース名 = テーブル名
	basename    = tablename
	puts basename
	# モデル名 = テーブル名の単数形、キャメルケース
	$ModelName = tablename.singularize.camelize
	$MODELNAME = $ModelName.upcase
	# 埋め込み用
	$sheetname  = sheet
	$basename   = basename
	$Basename   = upcaseFirst(basename)
	$BASENAME   = basename.upcase
	$primaryKey = nil;

	$basename_list << basename
	$sheetname_list << $sheetname
	recordset = []

	# 4行目～最終行までの値を取得
	4.upto(spreadsheet.last_row(sheet)) do |row|
		next if spreadsheet.cell(row, 2, sheet).nil? # 名前が入っていない行は無視

		record = {}
		record["name"]         = spreadsheet.cell(row, 2, sheet)
		record["DBtype"]       = spreadsheet.cell(row, 3, sheet)
		record["length"]       = spreadsheet.cell(row, 4, sheet)
		record["DBconstraint"] = spreadsheet.cell(row, 5, sheet)
		record["DBindex"]      = spreadsheet.cell(row, 6, sheet)
		record["DBprimarykey"] = spreadsheet.cell(row, 2, sheet) if !spreadsheet.cell(row, 7, sheet).nil? # ○が付いていればその名前をプライマリキーとする
		record["comment"]      = spreadsheet.cell(row, 8, sheet)
		# ルール
		record["rule"] = Array.new(3)
		record["rule"][0] = {:rule => spreadsheet.cell(row,  9, sheet), :message => spreadsheet.cell(row, 10, sheet), :allowEmpty => spreadsheet.cell(row, 11, sheet)}
		record["rule"][1] = {:rule => spreadsheet.cell(row, 12, sheet), :message => spreadsheet.cell(row, 13, sheet), :allowEmpty => spreadsheet.cell(row, 14, sheet)}
		record["rule"][2] = {:rule => spreadsheet.cell(row, 15, sheet), :message => spreadsheet.cell(row, 16, sheet), :allowEmpty => spreadsheet.cell(row, 17, sheet)}

		# 最初に現れたプライマリキーをセット(通常はid)
		$primaryKey = record["DBprimarykey"] if $primaryKey.nil?

		recordset << record
	end

	# プライマリキーが無いときはidをセット
	$primaryKey = "id" if $primaryKey.nil?



	# DB作成用SQL xxxx.sql テンプレート
	# ------------------------------------------------------------
	erb = ERB.new(File.read(TEMPLATE_DIR + DS + "template_sql.rb"))
	buf = erb.result(binding)

#puts buf

	# ファイルに書き込み
	filename = GENERATE_DIR + DS + "#{dirname}" + DS + "#{tablename}.sql"
	f = open(filename, "w")
	f.puts buf.kconv(Kconv::UTF8, OUTPUT_ENCODING)
	f.close



	# 一括DB作成用SQL xxxx.sql テンプレート
	# ------------------------------------------------------------
	erb = ERB.new(File.read(TEMPLATE_DIR + DS + "template_all_sql.rb"))
	buf = erb.result(binding)

#puts buf

	# ファイルに書き込み（すべて結合したもの）
	filename = GENERATE_DIR + DS + "all.sql"
	f = open(filename, "a")
	f.puts buf.kconv(Kconv::UTF8, OUTPUT_ENCODING)
	f.close



	# 一括DB削除用SQL xxxx.sql テンプレート
	# ------------------------------------------------------------
	erb = ERB.new(File.read(TEMPLATE_DIR + DS + "template_all_drop_sql.rb"))
	buf = erb.result(binding)

#puts buf

	# ファイルに書き込み（すべて結合したもの）
	filename = GENERATE_DIR + DS + "all_drop.sql"
	f = open(filename, "a")
	f.puts buf.kconv(Kconv::UTF8, OUTPUT_ENCODING)
	f.close



	# CakePHP Model テンプレート
	# ------------------------------------------------------------
	erb = ERB.new(File.read(TEMPLATE_DIR + DS + "CakePHP_model.rb"))
	buf = erb.result(binding)

#puts buf

	# ファイルに書き込み
	filename = GENERATE_DIR + DS + "CakePHP_models" + DS + "#{$ModelName}.php"
	f = open(filename, "w")
	f.puts buf.kconv(Kconv::UTF8, OUTPUT_ENCODING)
	f.close



	# CakePHP Config_column_list テンプレート
	# ------------------------------------------------------------
	erb = ERB.new(File.read(TEMPLATE_DIR + DS + "CakePHP_config_column_list.rb"))
	buf = erb.result(binding)

#puts buf

	# ファイルに書き込み
	filename = GENERATE_DIR + DS + "CakePHP_config" + DS + "column_list" + DS + "#{$ModelName}.php"
	f = open(filename, "w")
	f.puts buf.kconv(Kconv::UTF8, OUTPUT_ENCODING)
	f.close



	# CakePHP Config_validate テンプレート
	# ------------------------------------------------------------
	erb = ERB.new(File.read(TEMPLATE_DIR + DS + "CakePHP_config_validate.rb"))
	buf = erb.result(binding)

#puts buf

	# ファイルに書き込み
	filename = GENERATE_DIR + DS + "CakePHP_config" + DS + "validate" + DS + "#{$ModelName}.php"
	f = open(filename, "w")
	f.puts buf.kconv(Kconv::UTF8, OUTPUT_ENCODING)
	f.close



end

