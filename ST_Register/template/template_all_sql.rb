-- ----------------------------------------------------------
-- <%= $basename %> テーブル
-- ----------------------------------------------------------
-- 再作成用
-- ビュー削除
-- DROP VIEW v_<%= $basename %> CASCADE;
-- テーブル削除
-- DROP TABLE <%= $basename %> CASCADE;

-- テーブル作成
CREATE TABLE IF NOT EXISTS `<%= $basename %>` (
<%
    columns = []
    recordset[0,recordset.length].each do |record|
      columns << record["name"].downcase
      
      $name = record["name"].downcase
      
      if record["length"] then
        $length = "(" + record["length"].to_i.to_s + ")"
      else
        $length = ""
      end
      
      $dbtype = record["DBtype"].downcase
      
      if record["DBconstraint"] then
        $dbconstraint = " " + record["DBconstraint"].upcase
      else
        $dbconstraint = ""
      end
      
      if record["comment"] then
        $comment = " COMMENT '" + record["comment"] + "'"
      else
        $comment = ""
      end
%>	`<%= $name %>` <%= $dbtype %><%= $length %><%= $dbconstraint %><%= $comment %>,
<%
    end
    $columns = columns.join(",")
%>
	`delete_flag` tinyint(1) NOT NULL DEFAULT 0,
	`modified` datetime NOT NULL,
	`created` datetime NOT NULL,
	`create_user` integer DEFAULT 0,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- デフォルト値設定
ALTER TABLE `<%= $basename %>` AUTO_INCREMENT = 1;

-- インデックス作成
<%
    recordset.each do |record|
      $name = record["name"].downcase
      if !record["DBindex"].nil? && record["name"] != $primaryKey
%>CREATE INDEX <%= $basename %>_<%= $name %>_index ON <%= $basename %> (<%= $name %>);
<%
      end
    end
%>-- CREATE INDEX <%= $basename %>_delete_flag_index ON <%= $basename %> (delete_flag);
-- CREATE INDEX <%= $basename %>_modified_index ON <%= $basename %> (modified);
-- CREATE INDEX <%= $basename %>_created_index ON <%= $basename %> (created);

-- ビュー作成(v_テーブル名)
-- CREATE VIEW v_<%= $basename %> AS SELECT * FROM <%= $basename %> WHERE flag = 0;




