package assets
{
	import com.doitflash.extendable.MyMovieClip;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 4/10/2012 4:29 PM
	 */
	[Embed (source="graphic_assets.swf", symbol="Library_WpNavButtons")]
	public class WpNavButtons extends MyMovieClip 
	{
		public var label_txt:TextField;
		public var icon_mc:MovieClip;
		
		public function WpNavButtons():void 
		{
			label_txt.autoSize = TextFieldAutoSize.LEFT;
			//label_txt.mouseEnabled = false;
			//icon_mc.mouseChildren = false;
			//icon_mc.mouseEnabled = false;
			
			stop();
			
			refresh();
		}
		
		public function refresh():void
		{
			var rect:Rectangle = this.getRect(this);
			_width = rect.width;
			_height = rect.height;
		}
		
		
	}
	
}