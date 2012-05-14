package com.doitflash.remote.wp
{
	import com.doitflash.events.WpEvent;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import com.doitflash.tools.URLLoader;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import com.adobe.serialization.json.JSON;
	
	/**
	 * WordPressParser helps you connect to your wordpress blog and extract data out of it and show it in your flash/air projects.
	 * before using this class, you need to install http://wordpress.org/extend/plugins/json-api/ on your wordpress.
	 * 
	 * visit http://myappsnippet.com for mobile example files created using FlashDevelop
	 * 
	 * I am planing to build a sql db cache system for this project which will be a cool improvment! it will make the app work
	 * offline when it's not connected to internet, but for some reason, I have defficulties saving data into the .db file...
	 * I'll fix that later when I found some time :)
	 * 
	 *
	 * @author Hadi Tavakoli - 5/12/2012 10:40 AM
	 * @version 1.0
	 */
	public class WordPressParser extends EventDispatcher 
	{
		public static const POSTS:String = "POSTS";
		public static const CATS:String = "CATS";
		public static const PAGES:String = "PAGES";
		public static const SEARCH:String = "SEARCH";
		
		private var _address:String;
		private var _count:int;
		
		private var _posts:Posts;
		private var _searchPosts:SearchPosts;
		
		private var _loader:URLLoader;
		
		private var _networkAvailable:Boolean = true;
		private var _cache:Cache;
		
		/**
		 * initialize the parser by sending two parameters, the address to the homepage of your wordpress blog and
		 * the number of posts to be loaded on each request.
		 * 
		 * setting the <code>$count</code> value is very important because it will let you load posts on demand.
		 * imagine that you have more than a thousand posts on your blog, you certainly don't want to load all of them
		 * at once into your mobile app, right? so you will set the <code>$count</code> value to 5 or 10 and then you'll
		 * request for more posts by calling <code>getRecentPosts()</code>
		 * 
		 * @param	$address	address to the homepage of your wordpress
		 * @param	$count		number of posts to be loaded on each request
		 */
		public function WordPressParser($address:String, $count:int = 5):void 
		{
			_address = $address;
			_count = Math.max($count, 2);
		}
		
// ----------------------------------------------------------------------------------------------------------------------- funcs
		
		private function initPosts():void
		{
			if (!_posts)
			{
				_posts = new Posts(_address, _count, this);
				_posts.addEventListener(WpEvent.UPDATE_AVAILABLE, onPostsUpdateAvailable);
				_posts.addEventListener(WpEvent.RECENT_POSTS, onRecentPosts);
			}
		}
		
		private function onPostsUpdateAvailable(e:WpEvent):void
		{
			dispatchEvent(new WpEvent(WpEvent.UPDATE_AVAILABLE, e.param));
		}
		
		private function onRecentPosts(e:WpEvent):void
		{
			if (haveCache) // check if we should save data to db
			{
				for (var i:int = 0; i < e.param.length; i++) 
				{
					_cache.addPost(e.param[i]);
				}
			}
			
			dispatchEvent(new WpEvent(WpEvent.RECENT_POSTS, e.param));
		}
		
		private function initSearchPosts():void
		{
			if (!_searchPosts)
			{
				_searchPosts = new SearchPosts(_address, _count);
				_searchPosts.addEventListener(WpEvent.SEARCH_RESULT, onSearchResult);
			}
		}
		
		private function onSearchResult(e:WpEvent):void
		{
			dispatchEvent(new WpEvent(WpEvent.SEARCH_RESULT, e.param));
		}
		
// ----------------------------------------------------------------------------------------------------------------------- Helpful Funcs

		private function onCachePostLoad(e:WpEvent):void
		{
			// copy posts from db cache into _posts.loadedPosts
			initPosts();
			_posts.loadedPosts = e.param.data;
		}

// ----------------------------------------------------------------------------------------------------------------------- Static Methods

		/**
		 * converts a date in the following format <code>2012-04-11 08:24:22</code> to a real AS3 Date object.
		 */
		public static function convertToDate($str:String):Date
		{
			var yearPatt:RegExp = /(\d{4})\-/i;
			var monthAndDayPatt:RegExp = /\-(\d{2})/gi;
			var hourPatt:RegExp = /(\d{2})\:/i;
			var minAndSecPatt:RegExp = /\:(\d{2})/gi;
			
			var year:Number = yearPatt.exec($str)[1];
			var month:Number = Number(monthAndDayPatt.exec($str)[1]) - 1;
			var day:Number = monthAndDayPatt.exec($str)[1];
			var hour:Number = hourPatt.exec($str)[1];
			var min:Number = minAndSecPatt.exec($str)[1];
			var sec:Number = minAndSecPatt.exec($str)[1];
			
			return new Date(year, month, day, hour, min, sec);
		}
		
		/**
		 * @private
		 * @param	$obj
		 * @param	$arr
		 * @return
		 */
		public static function savePost($obj:Object, $arr:Array):Object
		{
			// convert date string to a real Date object
			$obj.date = WordPressParser.convertToDate($obj.date);
			$obj.modified = WordPressParser.convertToDate($obj.modified);
			
			// convert $obj.date to a number so we can later sort them based on post dates
			$obj.dateNum = $obj.date.getTime();
			$obj.modifiedNum = $obj.modified.getTime();
			
			// bad API is sending 'content' and 'comments' also! we don't need them right now, so let's just delete them!
			//delete($obj.content);
			//delete($obj.comments);
			
			$arr.push($obj);
			
			return $obj;
		}
		
		/**
		 * @private
		 * @param	$pager
		 * @param	$count
		 * @param	$loadedPostsLength
		 * @param	$numTotalPosts
		 * @return
		 */
		public static function numShouldHavePosts($pager:Number, $count:Number, $loadedPostsLength:Number, $numTotalPosts:Number):Number
		{
			var result:Number = $pager * $count;
			
			if (result > $numTotalPosts)
			{
				result = $numTotalPosts;
			}
			
			return result;
		}

// ----------------------------------------------------------------------------------------------------------------------- Methods
	
		/**
		 * call this function to load the latest recent posts in your blog. you should have added a listener to your
		 * WordPressParser instance to listen to when the load is completed. 
		 * 
		 * <listing version="3.0">
		 * _wp.addEventListener(WpEvent.RECENT_POSTS, onRecentPosts);
		 * function onRecentPosts(e:WpEvent):void
		 *	{
		 *		for (var i:int = 0; i &lt; e.param.length; i++) 
		 *		{
		 *			var post:Object = e.param[i];
		 *			for (var name:String in post) 
		 *			{
		 *				trace(name + " = " + post[name])
		 *			}
		 *			trace("------------------------------")
		 *		}
		 *		//trace("----- " + _wp.posts.loadedPosts.length + " --------");
		 *	}
		 * </listing>
		 */
		public function getRecentPosts():void
		{
			initPosts();
			_posts.load();
		}
		
		/**
		 * left for future upgrades...
		 * @private
		 */
		public function getPostUpdates():void
		{
			if (!_networkAvailable)
			{
				dispatchEvent(new WpEvent(WpEvent.NETWORK_STATUS, { status:"error", msg:"Network not available" } ));
				return;
			}
			
			_posts.getPostUpdates();
		}
		
		/**
		 * use this method to search the blog for a string like this: <code>_wp.search("sun");</code>
		 * Please note that the number of search results returned depends on the <code>$count</code> 
		 * value that you specified when initializing the class. if you want to receive more results 
		 * from the same search keyword, try calling: <code>_wp.search(null);</code>
		 * 
		 * @param	$keyword	the string to be searched
		 */
		public function search($keyword:String=""):void
		{
			if (!_networkAvailable)
			{
				dispatchEvent(new WpEvent(WpEvent.NETWORK_STATUS, { status:"error", msg:"Network not available" } ));
				return;
			}
			
			initSearchPosts();
			_searchPosts.search($keyword);
		}
		
		/**
		 * use this method to retrive full information about a post by passing the id of the post
		 * @param	$postId
		 */
		public function getPost($postId:int, $listener:Function=null):void
		{
			if (_loader && _loader.hasEventListener(Event.COMPLETE)) return;
			
			var loadedPostsLength:int = _posts.loadedPosts.length;
			var post:Object = {};
			var postFound:Boolean = false;
			for (var i:int = 0; i < loadedPostsLength; i++) 
			{
				// check if the requested post is available in _posts.loadedPosts
				post = _posts.loadedPosts[i];
				if ($postId == post.id)
				{
					postFound = true;
					break;
				}
			}
			
			if (postFound)
			{
				// check if 'content' and 'comments' are available?
				if (post.content && post.comments)
				{
					// call the listener and we're done
					if($listener != null) $listener.call(null, post);
					dispatchEvent(new WpEvent(WpEvent.POST_CONTENT, post));
					return;
				}
				else
				{
					// get information from server
					loadPostContent();
				}
			}
			else
			{
				// get information from server
				loadPostContent();
			}
			
			function loadPostContent():void
			{
				_loader = new URLLoader();
				_loader.addEventListener(Event.COMPLETE, onPostLoaded);
				_loader.load(new URLRequest(_address + "?json=get_post&id=" + $postId +""));
			}
			
			function onPostLoaded(e:Event):void
			{
				_loader.removeEventListener(Event.COMPLETE, onPostLoaded);
				
				var json:Object = com.adobe.serialization.json.JSON.decode(e.target.data);
				if (postFound)
				{
					// save 'content' and 'comments' into _posts.loadedPosts
					post.content = json.post.content;
					post.comments = json.post.comments;
				}
				else
				{
					// push the new loaded post into _posts.loadedPosts
					WordPressParser.savePost(json.post, _posts.loadedPosts);
				}
				
				if (haveCache) _cache.addPost(json.post);
				
				// call the listener and we're done
				if($listener != null) $listener.call(null, json.post);
				dispatchEvent(new WpEvent(WpEvent.POST_CONTENT, json.post));
			}
		}
		
		/**
		 * left for future upgrades
		 * @private
		 * @param	$pageId
		 * @param	$listener
		 */
		public function getPage($pageId:int, $listener:Function = null):void
		{
			
		}
		
		/**
		 * use this method to submit a comment on a post.
		 * 
		 * @param	$name		name of the person who's submitting the comment.
		 * @param	$email		email address of the person who's submitting the comment.
		 * @param	$content 	the content to be posted.
		 * @param	$post_id	the id of the post which we're leaving a comment on.
		 * @param	$listener	optionally a function to be called when the comment results are getting back from the wordpress server.
		 * you may use <code>WpEvent.SUBMIT_COMMENT</code> to listen to server results for a comment.
		 */
		public function submitComment($name:String, $email:String, $content:String, $post_id:int, $listener:Function=null):void
		{
			if (!_networkAvailable)
			{
				dispatchEvent(new WpEvent(WpEvent.NETWORK_STATUS, { status:"error", msg:"Network not available" } ));
				return;
			}
			
			_loader = new URLLoader();
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			_loader.addEventListener(Event.COMPLETE, onCommentSubmited);
			_loader.load(new URLRequest(_address + "?json=respond/submit_comment&post_id=" + $post_id + "&name=" + escape($name) + "&email=" + escape($email) + "&content=" + escape($content) +""));
			
			function onCommentSubmited(e:Event):void
			{
				_loader.removeEventListener(Event.COMPLETE, onCommentSubmited);
				_loader.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
				
				var json:Object = com.adobe.serialization.json.JSON.decode(e.target.data);
				
				// call the listener and we're done
				if($listener != null) $listener.call(null, json);
				dispatchEvent(new WpEvent(WpEvent.SUBMIT_COMMENT, json));
			}
			
			function onIoError(e:IOErrorEvent):void
			{
				_loader.removeEventListener(Event.COMPLETE, onCommentSubmited);
				_loader.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
				
				// call the listener and we're done
				if($listener != null) $listener.call(null, {status:"error", error:"unknown error! maybe duplicate comment?"});
				dispatchEvent(new WpEvent(WpEvent.SUBMIT_COMMENT, {status:"error", error:"unknown error! maybe duplicate comment?"}));
			}
		}
		
		/**
		 * left for future upgrades
		 * @private
		 * @param	$sqlRef
		 * @param	$dbPath
		 * @param	$dbName
		 */
		public function cache($sqlRef:Class, $dbPath:String, $dbName:String):void
		{
			_cache = new Cache($sqlRef, $dbPath, $dbName);
			_cache.addEventListener(WpEvent.CACHE_GET_POST, onCachePostLoad);
		}
// ----------------------------------------------------------------------------------------------------------------------- Properties

		/**
		 * @private
		 */
		public function get posts():Posts
		{
			return _posts;
		}
		
		/**
		 * @private
		 */
		public function get searchPosts():SearchPosts
		{
			return _searchPosts;
		}
		
		/**
		 * left for future upgrades
		 * @private
		 */
		public function get haveCache():Boolean
		{
			if (_cache) return true;
			
			return false;
		}
		
		/**
		 * left for future upgrades
		 * @private
		 */
		public function get networkAvailable():Boolean
		{
			return _networkAvailable;
		}
		
		/**
		 * @private
		 */
		public function set networkAvailable(a:Boolean):void
		{
			if (_networkAvailable != a)
			{
				initPosts();
				_posts.clean();
				
				_networkAvailable = a;
			}
			else
			{
				return;
			}
			
			
			// if no network, try loading data from db into _posts.loadedPosts
			if (!_networkAvailable)
			{
				// check if db is available?
				if (_cache.available)
				{
					_cache.getPost();
				}
			}
			
			
		}
	}
}