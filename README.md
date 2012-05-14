AS3-wordpress-parser
================

Our wordpress parser classes are just some abstarct codes to control the pure wordpress data such as your posts, comments, etc... and treat these data in any way that 
you like inside your AS3 projects; for example you can use it to create a Wordpress mobile application for your client or creating a wprdpress flash plugin or anything 
else related to wordpress... so you need something easy and handy to provide you the needed information :)

<h1>Usage:</h1>

<pre>
import com.doitflash.remote.wp.WordPressParser;
import com.doitflash.remote.wp.Sql;
import com.doitflash.events.WpEvent;

var _wp:WordPressParser = new WordPressParser("http://localhost/wordpress/", 2); // arguments: address of my WP blog, load 2 posts on each request

_wp.addEventListener(WpEvent.RECENT_POSTS, onRecentPosts);
_wp.addEventListener(WpEvent.POST_CONTENT, onPostContent);
_wp.addEventListener(WpEvent.SEARCH_RESULT, onSearchResult);
_wp.addEventListener(WpEvent.SUBMIT_COMMENT, onCommentResult);

_wp.getRecentPosts(); // start loading recent posts

// after loading some recent posts, we know the posts id, so we can call one of them to get its information
//_wp.getPost(1); // load the post id: 1 content information

_wp.search("title");

// submit a new comment to the post id: 1
//_wp.submitComment("Ali", "info@company.com", "my message!", 1);


// after we have called _wp.getRecentPosts() and our recent posts are loaded, this function will be triggered
private function onRecentPosts(e:WpEvent):void
{
	trace(_wp.posts.totalPosts); // get the total posts number
	trace(_wp.posts.loadedPosts.length); // get the loaded posts number
	
	// e.param.length is 2 right now, as we have set to load 2 recent posts each time we call _wp.getRecentPosts(), when we were initializing our class
	for (var i:int = 0; i &lt; e.param.length; i++) 
	{
		var post:Object = e.param[i];
		
		// e.param[i] includes all of the posts information such as id, type, slug, url and etc...
		trace("post.id = " + post.id);
	}
}

// after we have called _wp.getPost(1) and our specified post content is loaded, this function will be triggered
private function onPostContent(e:WpEvent):void
{
	for (var name:String in e.param) // e.param includes the specified post content information
	{
		trace(name)
	}
}

// after we have called _wp.search("title") and our search result is ready, this function will be triggered
private function onSearchResult(e:WpEvent):void
{
	trace(_wp.searchPosts.totalPosts); // get the total posts number which contain the word "title" 
	trace(_wp.searchPosts.loadedPosts.length); // get the loaded posts number which contain the word "title"
	
	// e.param.length is 2 right now, as we have set 2 as the value of the second argument of our class when we were initializing it
	// so it gives us 2 posts which contain the word "title"; so if we like to see more results, we call _wp.search(null), to search the last word we have searched once again and give us the rest of the results
	for (var i:int = 0; i &lt; e.param.length; i++) 
	{
		var post:Object = e.param[i];
		trace("post.id = " + post.id)
	}
}

// after we have called _wp.submitComment("Ali", "info@company.com", "my message!", 1), this function will be triggered
private function onCommentResult(e:WpEvent):void
{
	trace(e.param.status); // we get our comment status, whether it is waiting for moderation or couldn't be sent or is ok!
}
</pre>