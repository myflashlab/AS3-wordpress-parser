package com.doitflash.remote.wp
{
	import com.doitflash.events.WpEvent;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import com.doitflash.tools.URLLoader;
	import flash.net.URLRequest;
	
	import com.adobe.serialization.json.JSON;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 4/29/2012 9:08 AM
	 */
	public class Posts extends EventDispatcher 
	{
		private var _holder:WordPressParser;
		private var _address:String;
		private var _count:int;
		
		private var _updates:int;
		
		private var _pager:int = 1;
		private var _numTotal:Number = -1;
		private var _loader:URLLoader;
		private var _arr:Array = []; // holds all the loaded posts
		private var _arrRecent:Array; // holds recent posts (will be reset with each load() or getPostUpdates() call)
		
		public function Posts($address:String, $count:int, $holder:WordPressParser):void 
		{
			_holder = $holder;
			
			_address = $address;
			_count = $count;
		}
		
// ----------------------------------------------------------------------------------------------------------------------- funcs
	
		
	
// ----------------------------------------------------------------------------------------------------------------------- Helpful Funcs

		private function onLoadComplete(e:Event):void
		{
			_loader.removeEventListener(Event.COMPLETE, onLoadComplete);
			_arrRecent = []; // holds recent posts
			
			var json:Object = com.adobe.serialization.json.JSON.decode(e.target.data);
			if (_arr.length == 0) // check if this is the first time we're loading the api
			{
				_numTotal = json.count_total;
			}
			
			// check if we have updates
			if (json.count_total > _numTotal)
			{
				_updates += json.count_total - _numTotal;
				dispatchEvent(new WpEvent(WpEvent.UPDATE_AVAILABLE, _updates));
				
				_numTotal = json.count_total;
			}
			
			// reset _updates to '0' after loading them
			if (_loader.obj.type == "getPostUpdates")
			{
				_updates = 0;
			}
			
			var post:Object;
			var jsonPostsLength:int = json.posts.length;
			var currPostId:int;
			var duplicateFound:Boolean;
			var id:int;
			for (var i:int = 0; i < jsonPostsLength; i++) 
			{
				post = json.posts[i];
				
				// save the post
				if (_arr.length == 0)
				{
					// push the post into _arr
					_arrRecent.push(WordPressParser.savePost(post, _arr));
				}
				else // check if current post is already saved
				{
					currPostId = post.id;
					duplicateFound = false;
					for (var j:int = 0; j < _arr.length; j++) 
					{
						id = _arr[j].id;
						if (id == currPostId)
						{
							duplicateFound = true;
							break;
						}
					}
					
					if (!duplicateFound)
					{
						// push the post into _arr
						_arrRecent.push(WordPressParser.savePost(post, _arr));
					}
				}
			}
			
			// sort posts
			_arr.sortOn("dateNum",  Array.NUMERIC | Array.DESCENDING);
			
			var shouldBeAvailablePosts:Number;
			
			// check the number of posts that should be available (we must make sure no posts are forgotten while loading!)
			if (_loader.obj.type == "get_recent_posts")
			{
				shouldBeAvailablePosts = WordPressParser.numShouldHavePosts(_pager, _count, _arr.length, _numTotal - _updates);
				
				if (_pager < json.pages && shouldBeAvailablePosts == _arr.length)
				{
					// add one value to the _pager to get it ready for the next load() call
					_pager++;
				}
			}
			
			dispatchEvent(new WpEvent(WpEvent.RECENT_POSTS, _arrRecent));
		}

// ----------------------------------------------------------------------------------------------------------------------- Methods
	
		/**
		 * 
		 * @return	if <code>false</code> it means the loader is loading some other posts already. 
		 * you must wait for the current load process to finish before you start a new one.
		 */
		public function load():Boolean
		{
			if (_loader && _loader.hasEventListener(Event.COMPLETE)) return false;
			
			if (_numTotal - _updates == _arr.length) return false;
			
			if(_holder.networkAvailable)
			{
				_loader = new URLLoader();
				_loader.obj = {type:"get_recent_posts"};
				_loader.addEventListener(Event.COMPLETE, onLoadComplete);
				_loader.load(new URLRequest(_address + "?json=get_recent_posts&count=" + _count +"&page=" + _pager +""));
			}
			else
			{
				_numTotal = _arr.length;
				_arr.sortOn("dateNum",  Array.NUMERIC | Array.DESCENDING);
				dispatchEvent(new WpEvent(WpEvent.RECENT_POSTS, _arr));
			}
			
			return true;
		}
		
		/**
		 * 
		 * @return	if <code>false</code> it means the loader is loading posts already. you must wait for the current
		 * load process to finish before you start a new process.
		 */
		public function getPostUpdates():Boolean
		{
			if (_loader && _loader.hasEventListener(Event.COMPLETE)) return false;
			
			_loader = new URLLoader();
			_loader.obj = {type:"getPostUpdates"};
			_loader.addEventListener(Event.COMPLETE, onLoadComplete);
			_loader.load(new URLRequest(_address + "?json=get_recent_posts&count=" + _updates +"&page=" + "1" +""));
			
			return true;
		}
		
		public function clean():void
		{
			// reset everything
			_pager = 1;
			_numTotal = -1;
			_arr = [];
		}
	
// ----------------------------------------------------------------------------------------------------------------------- Properties

		/**
		 * Returns the total number of posts on the server
		 */
		public function get totalPosts():Number
		{
			return _numTotal;
		}
		
		/**
		 * Returns the number of already loaded posts
		 */
		public function get loadedPosts():Array
		{
			return _arr;
		}
		
		/**
		 * @private
		 */
		public function set loadedPosts(a:Array):void
		{
			_arr = a;
		}
		
		/**
		 * Returns the number of post updates which are not loaded yet. use getPostUpdates() method to
		 * load the updates. (may not work properly right now! maybe I'll fix that in future versions)
		 */
		public function get updates():int
		{
			return _updates;
		}
	}
}