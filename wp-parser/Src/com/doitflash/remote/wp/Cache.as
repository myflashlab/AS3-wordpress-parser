package com.doitflash.remote.wp
{
	import com.doitflash.events.WpEvent;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 5/6/2012 12:32 PM
	 */
	public class Cache extends EventDispatcher 
	{
		private var _sqlRef:Class;
		private var _dbPath:String;
		private var _dbName:String;
		
		private var _dbFile:*;
		private var _sqlConn:*;
		private var _sqlStmt:*;
		private var _sqlStr:String;
		
		public function Cache($sqlRef:Class, $dbPath:String, $dbName:String):void 
		{
			_sqlRef = $sqlRef;
			_dbPath = $dbPath;
			_dbName = $dbName;
			
			
		}
		
		public function connect():Boolean
		{
			if (_sqlConn && _sqlConn.connected) return false;
			
			toResolvePath();
			
			_sqlConn = new _sqlRef["sQLConnection"]();
			_sqlConn.open(_dbFile);
			
			// create table: wp_posts
			_sqlStmt = new _sqlRef["sQLStatement"]();
			_sqlStr =		"	CREATE TABLE IF NOT EXISTS wp_posts (" +
							"	id INTEGER, " + 
							"	type TEXT, " +
							"	dateNum INTEGER, " + 
							"	modifiedNum INTEGER, " + 
							"	modified DATE, " + 
							"	date DATE, " + 
							"	title_plain TEXT, " +
							"	title TEXT, " +
							"	excerpt TEXT, " +
							"	content BLOB, " +
							"	author OBJECT, " +
							"	comment_count INTEGER, " + 
							"	comments OBJECT, " +
							"	comment_status TEXT, " +
							"	attachments OBJECT, " +
							"	categories OBJECT, " +
							"	tags OBJECT, " +
							"	slug TEXT, " +
							"	url TEXT " +
							"	); ";
						
			_sqlStmt.sqlConnection = _sqlConn;
			_sqlStmt.text = _sqlStr;
			_sqlStmt.execute();
			
			return true;
		}
		
		public function getPost():void
		{
			connect();
			
			_sqlStmt = new _sqlRef["sQLStatement"]();
			_sqlStmt.addEventListener(_sqlRef["sQLEvent"].RESULT, onResult);
			_sqlStr = "SELECT * FROM wp_posts";
			_sqlStmt.sqlConnection = _sqlConn;
			_sqlStmt.text = _sqlStr;
			_sqlStmt.execute();
			
			function onResult(e:*):void
			{
				dispatchEvent(new WpEvent(WpEvent.CACHE_GET_POST, e.currentTarget.getResult()));
			}
		}
		
		/**
		 * if the post is already available in db, it will be updated with the new data using updatePost() method.
		 * and if it's not available, it will be added using savePost()
		 * 
		 * @param	$obj
		 * 
		 * @see #updatePost()
		 * @see #savePost()
		 */
		public function addPost($obj:Object):void
		{
			connect();
			
			// check if this post is already in db?
			_sqlStmt = new _sqlRef["sQLStatement"]();
			_sqlStmt.addEventListener(_sqlRef["sQLEvent"].RESULT, onResult);
			_sqlStr = "SELECT id FROM wp_posts WHERE id='" + $obj.id + "'";
			_sqlStmt.sqlConnection = _sqlConn;
			_sqlStmt.text = _sqlStr;
			_sqlStmt.execute();
			
			var foundRecordsArr:Array;
			function onResult(e:*):void
			{
				var result:* = e.currentTarget.getResult();
				if (result && result.data)
				{
					foundRecordsArr = result.data;
				}
			}
			
			if (foundRecordsArr)
			{
				// update the post
				updatePost($obj);
			}
			else
			{
				// save the new post
				savePost($obj);
			}
		}
		
		public function updatePost($obj:Object):void
		{
			connect();
			
			// update the post into wp_posts
			_sqlStmt = new _sqlRef["sQLStatement"]();
			_sqlStr =											"	UPDATE wp_posts SET ";
			if($obj.type) 			_sqlStr = _sqlStr.concat(	"	type='" + $obj.type + "', ");
			if($obj.dateNum)		_sqlStr = _sqlStr.concat(	"	dateNum='" + $obj.dateNum + "', ");
			if($obj.modifiedNum)	_sqlStr = _sqlStr.concat(	"	modifiedNum='" + $obj.modifiedNum + "', ");
			if($obj.modified) 		_sqlStr = _sqlStr.concat(	"	modified=STRFTIME('%J','" + formatDateToSTRFTIME($obj.modified) + "'), ");
			if($obj.date) 			_sqlStr = _sqlStr.concat(	"	date=STRFTIME('%J','" + formatDateToSTRFTIME($obj.date) + "'), ");
			if($obj.title_plain)	_sqlStr = _sqlStr.concat(	"	title_plain='" + $obj.title_plain + "', ");
			if($obj.title) 			_sqlStr = _sqlStr.concat(	"	title='" + $obj.title + "', ");
			if($obj.excerpt) 		_sqlStr = _sqlStr.concat(	"	excerpt='" + $obj.excerpt + "', ");
			if($obj.content) 		_sqlStr = _sqlStr.concat(	"	content='" + $obj.content + "', ");
			if($obj.author) 		_sqlStr = _sqlStr.concat(	"	author='" + $obj.author + "', ");
			if($obj.comment_count)	_sqlStr = _sqlStr.concat(	"	comment_count='" + $obj.comment_count + "', ");
			if($obj.comments) 		_sqlStr = _sqlStr.concat(	"	comments='" + $obj.comments + "', ");
			if($obj.comment_status)	_sqlStr = _sqlStr.concat(	"	comment_status='" + $obj.comment_status + "', ");
			if($obj.attachments)	_sqlStr = _sqlStr.concat(	"	attachments='" + $obj.attachments + "', ");
			if($obj.categories)		_sqlStr = _sqlStr.concat(	"	categories='" + $obj.categories + "', ");
			if($obj.tags) 			_sqlStr = _sqlStr.concat(	"	tags='" + $obj.tags + "', ");
			if($obj.slug) 			_sqlStr = _sqlStr.concat(	"	slug='" + $obj.slug + "', ");
			if($obj.url) 			_sqlStr = _sqlStr.concat(	"	url='" + $obj.url + "', ");
			_sqlStr = _sqlStr.concat(							"	id='" + $obj.id + "' ");
			_sqlStr = _sqlStr.concat(							"	WHERE id='" + $obj.id + "' ");
			
			_sqlStmt.sqlConnection = _sqlConn;
			_sqlStmt.text = _sqlStr;
			_sqlStmt.execute();
		}
		
		public function savePost($obj:Object):void
		{
			connect();
			
			// save new data into wp_posts
			_sqlStmt = new _sqlRef["sQLStatement"]();
			_sqlStr =		"	INSERT INTO wp_posts (	id, " +
							"							type, " +
							"							dateNum, " +
							"							modifiedNum, " +
							"							modified, " +
							"							date, " +
							"							title_plain, " +
							"							title, " +
							"							excerpt, " +
							"							content, " +
							"							author, " +
							"							comment_count, " +
							"							comments, " +
							"							comment_status, " +
							"							attachments, " +
							"							categories, " +
							"							tags, " +
							"							slug, " +
							"							url) " +
							"	VALUES ('" + $obj.id + "', " +
							"	'" + $obj.type + "', " +
							"	'" + $obj.dateNum + "', " +
							"	'" + $obj.modifiedNum + "', " +
							"	STRFTIME('%J','" + formatDateToSTRFTIME($obj.modified) + "'), " +
							"	STRFTIME('%J','" + formatDateToSTRFTIME($obj.date) + "'), " +
							"	'" + $obj.title_plain + "', " +
							"	'" + $obj.title + "', " +
							"	'" + $obj.excerpt + "', " +
							"	'" + String(($obj.content) ? $obj.content : "") + "', " +
							"	'" + $obj.author + "', " +
							"	'" + $obj.comment_count + "', " +
							"	'" + String(($obj.comments) ? $obj.comments : "") + "', " +
							"	'" + $obj.comment_status + "', " +
							"	'" + $obj.attachments + "', " +
							"	'" + $obj.categories + "', " +
							"	'" + $obj.tags + "', " +
							"	'" + $obj.slug + "', " +
							"	'" + $obj.url + "'" +
							"	)";
							
			_sqlStmt.sqlConnection = _sqlConn;
			_sqlStmt.text = _sqlStr;
			_sqlStmt.execute();
		}
		
		public function get available():Boolean
		{
			var result:Boolean = false;
			
			if (!_dbFile)
			{
				toResolvePath();
			}
			
			result = _dbFile.exists;
			
			return result;
		}
		
// ----------------------------------------------------------------------------------------------------------------------- funcs

		private function toResolvePath():void
		{
			_dbFile = _sqlRef["file"].documentsDirectory.resolvePath(_dbPath);
			_dbFile.createDirectory();
			_dbFile = _sqlRef["file"].documentsDirectory.resolvePath(_dbPath + "/" + _dbName + ".db");
			
		}
		
		private function formatDateToSTRFTIME($date:*):String
		{
			if ($date is String) return $date;
			
			var year:String = refine($date.getFullYear());
			var month:String = refine(Number($date.getMonth() + 1));
			var date:String = refine($date.getDate());
			var hour:String = refine($date.getHours());
			var minute:String = refine($date.getMinutes());
			var second:String = refine($date.getSeconds());
			
			var result:String = year + "-" + month + "-" + date + " " + hour + ":" + minute + ":" + second;
			
			function refine($num:Number):String
			{
				var str:String = "" + $num;
				if ($num < 10)
				{
					str = "0" + $num;
				}
				
				return str;
			}
			
			return result;
		}
	}
}