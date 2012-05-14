package pages.wp.comments
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
	import flash.utils.setTimeout;
	
	import com.doitflash.text.modules.MySprite;
	import com.doitflash.remote.wp.WordPressParser;
	import com.doitflash.fl.motion.Color;
	
	import events.AppEvent;
	import assets.CommentMc;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 4/22/2012 4:00 PM
	 */
	public class ItemSub extends MySprite 
	{
		private var _title:TextField;
		private var _txt:TextField;
		private var _avatar:MySprite;
		private var _replyBtn:CommentMc;
		
		public function ItemSub():void 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, stageAdded);
			
			_height = 50;
			
			_margin = 5;
			_bgAlpha = 1;
			_bgColor = 0xF8F8F8;
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
			
			/*for (var name:String in _data) 
			{
				_base.c.log(name)
			}
			
			_base.c.log("---------")*/
			
			_data.date = WordPressParser.convertToDate(_data.date);
			
			initAvatar();
			initTxt();
			initBtn();
			
			onResize();
			
		}
		
// ----------------------------------------------------------------------------------------------------------------------- funcs
		
		private function initAvatar():void
		{
			_avatar = new MySprite();
			_avatar.bgAlpha = 1;
			_avatar.bgColor = 0xBACADF;
			_avatar.drawBg();
			_avatar.width = 25;
			_avatar.height = 25;
			
			this.addChild(_avatar);
		}
		
		private function initTxt():void
		{
			_title = new TextField();
			_title.autoSize = TextFieldAutoSize.LEFT;
			_title.antiAliasType = AntiAliasType.ADVANCED;
			//_title.multiline = true;
			//_title.wordWrap = true;
			_title.embedFonts = true;
			_title.mouseEnabled = false;
			_title.condenseWhite = true;
			_title.htmlText = "<font face='Arimo' size='13' color='#999999'>" + _data.name + " - " + _data.date.toLocaleDateString() + "</font>";
			this.addChild(_title);
			
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
			
			_txt.htmlText = "<font face='Arimo' size='13' color='#999999'>" + _data.content + "</font>";
			
			this.addChild(_txt);
		}
		
		private function initBtn():void
		{
			_replyBtn = new CommentMc();
			_replyBtn.addEventListener(MouseEvent.CLICK, onReply);
			_replyBtn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			_replyBtn.addEventListener(MouseEvent.MOUSE_UP, onUp);
			_replyBtn.addEventListener(MouseEvent.MOUSE_OUT, onUp);
			_replyBtn.data = _data;
			_replyBtn.label_txt.text = "Re";
			_replyBtn.scaleX = _replyBtn.scaleY = 0.75;
			this.addChild(_replyBtn);
			
		}
		
		private function onReply(e:MouseEvent):void
		{
			this.dispatchEvent(new AppEvent(AppEvent.WP_REPLY, _data, true));
		}
		
// ----------------------------------------------------------------------------------------------------------------------- Helpful Funcs

		override protected function onResize(e:*= null):void
		{
			if (_txt)
			{
				_avatar.x = _margin;
				_avatar.y = _margin;
				
				_title.x = _avatar.x + _avatar.width + 5;
				_title.y = (_avatar.y * 2 + _avatar.height) / 2 - _title.height / 2;
				
				_txt.x = _margin;
				_txt.y = _avatar.y + _avatar.height + 5;
				_txt.width = _width - _avatar.width - (_margin*2);
				_height = Math.max(_txt.y + _txt.height, _avatar.height) + _margin * 2;
				
				_replyBtn.x = _width - (_replyBtn.width*0.75) - 0;
				_replyBtn.y = 0;
			}
			
			super.onResize(e);
		}
		
		private function onDown(e:MouseEvent):void
		{
			var item:* = e.currentTarget;
			
			var color:Color = new Color();
			color.setTint(0xA0B6D3, 1);
			
			try
			{
				item.icon_mc.transform.colorTransform = color;
				item.label_txt.htmlText = "<font color='#627AAD' >" + item.label_txt.text;
			}
			catch (err:Error)
			{
				item.transform.colorTransform = color;
			}
		}
		
		private function onUp(e:MouseEvent):void
		{
			var item:* = e.currentTarget;
			
			setTimeout(go, 100);
			function go():void
			{
				var color:Color = new Color();
				color.setTint(0xFFFFFF, 0);
				
				try
				{
					item.icon_mc.transform.colorTransform = color;
					item.label_txt.htmlText = "<font color='#FFFFFF' >" + item.label_txt.text;
				}
				catch (err:Error)
				{
					item.transform.colorTransform = color;
				}
			}
			
			
		}
	
// ----------------------------------------------------------------------------------------------------------------------- Methods

		

// ----------------------------------------------------------------------------------------------------------------------- Properties

		
		
	}
	
}