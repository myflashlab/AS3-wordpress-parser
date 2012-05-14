package assets
{
	import com.doitflash.extendable.MyMovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 12/12/2011 11:29 AM
	 */
	[Embed (source="graphic_assets.swf", symbol="Library_Preloader")]
	public class PreloaderAnimation extends MyMovieClip 
	{
		public var msg:TextField;
		
		public function PreloaderAnimation():void 
		{
			var rect:Rectangle = this.getRect(this);
			_width = rect.width;
			_height = rect.height;
			
			stop();
		}
		
		
	}
	
}