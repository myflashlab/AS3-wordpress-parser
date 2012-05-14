package com.doitflash.remote.wp
{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import com.doitflash.tools.URLLoader;
	import flash.net.URLRequest;
	
	import com.adobe.serialization.json.JSON;
	import com.doitflash.events.WpEvent;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 4/29/2012 9:19 AM
	 */
	public class SearchPosts extends EventDispatcher 
	{
		private var _address:String;
		private var _count:int;
		
		private var _keyword:String = "";
		
		private var _pager:int = 1;
		private var _numTotal:Number = -1;
		private var _loader:URLLoader;
		private var _arr:Array = []; // holds all the loaded posts
		private var _arrRecent:Array; // holds recent posts
		
		public function SearchPosts($address:String, $count:int):void 
		{
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
			if (json.status != "ok") return;
			
			if (_arr.length == 0)
			{
				_numTotal = json.count_total;
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
			shouldBeAvailablePosts = WordPressParser.numShouldHavePosts(_pager, _count, _arr.length, _numTotal);
			if (_pager < json.pages && shouldBeAvailablePosts == _arr.length)
			{
				// add one value to the _pager to get it ready for the next load() call
				_pager++;
			}
			
			dispatchEvent(new WpEvent(WpEvent.SEARCH_RESULT, _arrRecent));
		}

// ----------------------------------------------------------------------------------------------------------------------- Methods
	
		public function search($keyword:String=""):Boolean
		{
			if (_loader && _loader.hasEventListener(Event.COMPLETE)) return false;
			if ($keyword && $keyword == "") return false;
			
			// save the keyword
			if ($keyword) 
			{
				// reset everything for a new search
				_pager = 1;
				_numTotal = -1;
				_arr = [];
				_keyword = $keyword;
			}
			
			if (_numTotal == _arr.length) return false;
			
			
			
			
			
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onLoadComplete);
			_loader.load(new URLRequest(_address + "?json=get_search_results&search=" + escape(_keyword) + "&count=" + _count + "&page=" + _pager));
			
			return true;
		}
	
// ----------------------------------------------------------------------------------------------------------------------- Properties

		public function get totalPosts():Number
		{
			return _numTotal;
		}
		
		public function get loadedPosts():Array
		{
			return _arr;
		}
	}
}