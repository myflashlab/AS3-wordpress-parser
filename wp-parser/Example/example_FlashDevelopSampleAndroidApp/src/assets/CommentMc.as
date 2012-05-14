package assets
{
	import com.doitflash.extendable.MyMovieClip;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 12/12/2011 11:29 AM
	 */
	[Embed (source="graphic_assets.swf", symbol="Library_CommentMc")]
	public class CommentMc extends MyMovieClip 
	{
		public var label_txt:TextField;
		public var icon_mc:MovieClip;
		
		public function CommentMc():void 
		{
			label_txt.mouseEnabled = false;
			icon_mc.mouseEnabled = false;
			
			var rect:Rectangle = this.getRect(this);
			_width = rect.width;
			_height = rect.height;
			
			stop();
		}
		
		
	}
	
}