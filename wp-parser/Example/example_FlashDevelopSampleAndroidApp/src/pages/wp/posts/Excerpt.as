package pages.wp.posts
{
	import com.doitflash.events.WpEvent;
	import events.AppEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
	
	import com.doitflash.text.modules.MySprite;
	import pages.wp.WordPress;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 4/10/2012 12:48 PM
	 */
	public class Excerpt extends MySprite 
	{
		private var _header:ExcerptHeader;
		private var _txt:TextField;
		
		public function Excerpt():void 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, stageAdded);
			
			_margin = 5;
			_bgAlpha = 1;
			_bgColor = 0xFFFFFF;
			_bgStrokeAlpha = 1;
			_bgStrokeColor = 0xE1E1E1;
			_bgStrokeThickness = 1;
			drawBg();
			
		}
		
		private function stageRemoved(e:Event = null):void 
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, stageRemoved);
			this.addEventListener(Event.ADDED_TO_STAGE, stageAdded);
			
			
		}
		
		private function stageAdded(e:Event = null):void 
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, stageAdded);
			this.addEventListener(Event.REMOVED_FROM_STAGE, stageRemoved);
			
			initHeader();
			initBody();
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onUp);
			this.addEventListener(MouseEvent.MOUSE_OUT, onUp);
			this.addEventListener(MouseEvent.MOUSE_MOVE, onUp);
			this.addEventListener(MouseEvent.CLICK, onClick);
			
			onResize();
			
		}
		
// ----------------------------------------------------------------------------------------------------------------------- funcs
		
		private function initHeader():void
		{
			_header = new ExcerptHeader();
			_header.margin = _margin;
			_header.base = _base;
			_header.data = _data;
			
			this.addChild(_header);
		}
		
		private function initBody():void
		{
			_txt = new TextField();
			//_txt.autoSize = TextFieldAutoSize.LEFT;
			_txt.antiAliasType = AntiAliasType.ADVANCED;
			_txt.multiline = true;
			_txt.wordWrap = true;
			_txt.embedFonts = true;
			_txt.mouseEnabled = false;
			
			var str:String = _data.excerpt;
			str = str.replace("&hellip;", "... ");
			str = str.replace("&rarr;", "");
			str = str.replace("Continue reading", "<font color='#990000'>Continue reading</font>");
			
			_txt.htmlText = "<font face='Arimo' size='13' color='#999999'>" + str + "</font>";
			
			this.addChild(_txt);
		}
		
// ----------------------------------------------------------------------------------------------------------------------- Helpful Funcs

		override protected function onResize(e:*= null):void
		{
			super.onResize(e);
			
			
			if (_header)
			{
				_header.x = _margin;
				_header.width = _width - _margin * 2;
				_header.height = 70;
			}
			
			if (_txt)
			{
				//_txt.scaleX = _txt.scaleY = _base.deviceInfo.dpiScaleMultiplier;
				
				_txt.x = _margin;
				_txt.y = _header.y + _header.height;
				_txt.width = (_width - _margin * 2) /** (1/_base.deviceInfo.dpiScaleMultiplier)*/;
				_txt.height = (_height - _txt.y) /** (1/_base.deviceInfo.dpiScaleMultiplier)*/;
			}
		}
		
		public function onDown(e:MouseEvent=null):void
		{
			_bgColor = 0xF8F8F8;
			drawBg();
			
			if(_header) _header.toCoverTitle(_bgColor);
		}
		
		public function onUp(e:MouseEvent=null):void
		{
			_bgColor = 0xFFFFFF;
			drawBg();
			
			if(_header) _header.toCoverTitle(_bgColor);
		}
		
		private function onClick(e:MouseEvent):void
		{
			/*if (_currItem && e) unselect();
			
			if(e) _currItem = e.currentTarget as Item;
			select();
			
			this.dispatchEvent(new WpEvent(WpEvent.REQUEST_DATA, _currItem.data));*/
			
			this.dispatchEvent(new AppEvent(AppEvent.REQUEST_POST, _data, true));
		}
	
// ----------------------------------------------------------------------------------------------------------------------- Methods

		

// ----------------------------------------------------------------------------------------------------------------------- Properties

		
		
	}
	
}