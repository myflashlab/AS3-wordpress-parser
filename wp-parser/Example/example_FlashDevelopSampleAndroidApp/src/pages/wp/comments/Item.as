package pages.wp.comments
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
	
	import com.doitflash.text.modules.MySprite;
	import com.doitflash.remote.wp.WordPressParser;
	import com.doitflash.utils.lists.List;
	import com.doitflash.events.ListEvent;
	import com.doitflash.consts.Direction;
	import com.doitflash.consts.Orientation;
	
	import events.AppEvent;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 4/20/2012 9:14 PM
	 */
	public class Item extends MySprite 
	{
		private var _txt:TextField;
		private var _avatar:MySprite;
		
		private var _list:List;
		private var _subComments:Array;
		
		public function Item():void 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, stageAdded);
			
			_height = 50;
			
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
			
			if (_data.date is String) _data.date = WordPressParser.convertToDate(_data.date);
			
			initAvatar();
			initTxt();
			if(_subComments.length > 0) initSubs();
			
			
			onResize();
			
		}
		
// ----------------------------------------------------------------------------------------------------------------------- funcs
		
		private function initAvatar():void
		{
			_avatar = new MySprite();
			_avatar.bgAlpha = 1;
			_avatar.bgColor = 0xBACADF;
			_avatar.drawBg();
			_avatar.width = 50;
			_avatar.height = 50;
			
			this.addChild(_avatar);
		}
		
		private function initTxt():void
		{
			_txt = new TextField();
			_txt.autoSize = TextFieldAutoSize.LEFT;
			_txt.antiAliasType = AntiAliasType.ADVANCED;
			_txt.multiline = true;
			_txt.wordWrap = true;
			_txt.embedFonts = true;
			_txt.mouseEnabled = false;
			_txt.condenseWhite = true;
			
			//var str:String = _data.name;
			//str = str.replace("&hellip;", "... ");
			//str = str.replace("&rarr;", "");
			//str = str.replace("Continue reading", "<font color='#990000'>Continue reading</font>");
			
			_txt.htmlText = "<font face='Arimo' size='13' color='#999999'>" + _data.name + " - " + _data.date.toLocaleDateString() + "<br>" + _data.content + "</font>";
			
			this.addChild(_txt);
		}
		
		private function initSubs():void
		{
			_list = new List();
			_list.addEventListener(ListEvent.RESIZE, onResize);
			_list.direction = Direction.LEFT_TO_RIGHT;
			_list.orientation = Orientation.VERTICAL;
			_list.table = false;
			_list.space = 0;
			_list.speed = 0;
			
			this.addChild(_list);
			
			for (var i:int = 0; i < _subComments.length; i++) 
			{
				var item:ItemSub = new ItemSub();
				item.base = _base;
				item.data = _subComments[i];
				
				//item.width = _width - (_margin * 2);
				
				_list.add(item);
			}
		}
		
// ----------------------------------------------------------------------------------------------------------------------- Helpful Funcs

		override protected function onResize(e:*= null):void
		{
			if (_txt)
			{
				_avatar.x = _margin;
				_avatar.y = _margin;
				_txt.x = _avatar.x + _avatar.width + 5;
				_txt.y = _margin;
				//_txt.width = _width - _avatar.x - _avatar.width - (_margin*2);
				
				//_txt.scaleX = _txt.scaleY = _base.deviceInfo.dpiScaleMultiplier;
				_txt.width = (_width - _avatar.x - _avatar.width - (_margin * 2))/* * (1 / _base.deviceInfo.dpiScaleMultiplier)*/;
				
				_height = Math.max(_txt.height, _avatar.height) + _margin * 2;
			}
			
			if (_list)
			{
				_list.x = _txt.x;
				_list.y = Math.max(_txt.y + _txt.height, _avatar.y + _avatar.height) + 5;
				_height = _list.y + _list.height + _margin
				
				for (var i:int = 0; i < _list.items.length; i++) 
				{
					var item:ItemSub = _list.items[i].content as ItemSub;
					item.width = _width - (_margin * 2) - _txt.x;
					//item.height = _scroller.maskHeight;
				}
			}
			
			super.onResize(e);
		}
	
// ----------------------------------------------------------------------------------------------------------------------- Methods

		

// ----------------------------------------------------------------------------------------------------------------------- Properties

		public function set subComments(a:Array):void
		{
			_subComments = a;
		}
		
	}
	
}