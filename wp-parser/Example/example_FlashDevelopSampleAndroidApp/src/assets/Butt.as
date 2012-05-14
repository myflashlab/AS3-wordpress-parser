package assets
{
	import com.doitflash.extendable.MyMovieClip;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 12/12/2011 11:29 AM
	 */
	[Embed (source="graphic_assets.swf", symbol="Library_Butt")]
	public class Butt extends MyMovieClip 
	{
		public var label_txt:TextField;
		public var bg_mc:MovieClip;
		
		public function Butt():void 
		{
			bg_mc.mouseEnabled = false;
			label_txt.mouseEnabled = false;
			label_txt.autoSize = TextFieldAutoSize.LEFT;
			label_txt.antiAliasType = AntiAliasType.ADVANCED;
			
			var rect:Rectangle = this.getRect(this);
			_width = rect.width;
			_height = rect.height;
			
			stop();
			bg_mc.stop();
		}
		
		override protected function onResize(e:*= null):void
		{
			super.onResize(e);
			
			bg_mc.width = _width;
			bg_mc.height = _height;
			
			label_txt.width = _width;
		}
	}
	
}