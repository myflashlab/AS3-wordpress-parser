package 
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.setTimeout;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.ui.Keyboard;
	
	import assets.CommentMc;
	import pages.wp.toolbar.Toolbar;
	import pages.wp.posts.Posts;
	import pages.wp.comments.Comments;
	import pages.wp.comments.Reply;
	import events.AppEvent;
	
	import com.doitflash.remote.wp.WordPressParser;
	import com.doitflash.events.WpEvent;
	
	import pl.mateuszmackowiak.nativeANE.alert.NativeAlert;
	import pl.mateuszmackowiak.nativeANE.NativeDialogEvent;
	import pl.mateuszmackowiak.nativeANE.dialogs.NativeListDialog;
	import pl.mateuszmackowiak.nativeANE.dialogs.NativeTextField;
	import pl.mateuszmackowiak.nativeANE.dialogs.NativeTextInputDialog;
	import pl.mateuszmackowiak.nativeANE.NativeDialogListEvent;
	import pl.mateuszmackowiak.nativeANE.notification.NativeNotifiction;
	import pl.mateuszmackowiak.nativeANE.progress.NativeProgress;
	import pl.mateuszmackowiak.nativeANE.properties.SystemProperties;
	import pl.mateuszmackowiak.nativeANE.toast.Toast;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 5/10/2012 4:02 PM
	 */
	public class Main extends Sprite 
	{
		private var _xml:XML;
		private var _toolbar:Toolbar;
		private var _posts:Posts;
		private var _comments:Comments;
		private var _reply:Reply;
		
		private var _stageWebView:StageWebView;
		private var _rect:Rectangle;
		
		private var _wpParser:WordPressParser;
		private var _searchDialog:NativeTextInputDialog;
		private var _keyword:String = "";
		
		private var _backBtnEngaged:Boolean = false;
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys, false, 0, true);
			
			// entry point
			
			_xml = new XML(
			<data>
				<wp>http://emstris.com/</wp>
				<icons>
					<item name="SEARCH" label="search" />
					<item name="POSTS" label="posts" />
				</icons>
			</data>
			)
			
			init();
			onResize();
		}
		
		private function deactivate(e:Event):void 
		{
			// auto-close
			//NativeApplication.nativeApplication.exit();
		}
		
		private function init():void
		{
			_wpParser = new WordPressParser(_xml.wp.text(), 2);
			_wpParser.addEventListener(WpEvent.RECENT_POSTS, onRecentPosts);
			_wpParser.addEventListener(WpEvent.POST_CONTENT, onPostContentListener);
			_wpParser.addEventListener(WpEvent.SEARCH_RESULT, onSearchResult);
			_wpParser.addEventListener(WpEvent.SUBMIT_COMMENT, onCommentResult);
			initToolbar();
			
			initPosts();
		}
		
		private function initToolbar():void
		{
			_toolbar = new Toolbar();
			_toolbar.addEventListener(AppEvent.REQUEST_DATA, onNavRequest, false, 0, true);
			_toolbar.xml = new XML(_xml.icons);
			_toolbar.base = this;
			
			this.addChild(_toolbar);
		}
		
		private function initPosts():void
		{
			if (!_posts) _posts = new Posts();
			_posts.addEventListener(AppEvent.REQUEST_RECENT_POSTS, requestPosts, false, 0, true);
			_posts.addEventListener(AppEvent.REQUEST_POST, toShowPostContent, false, 0, true);
			_posts.base = this;
			
			this.addChild(_posts);
			
			requestPosts();
		}
		
		private function requestPosts(e:AppEvent=null):void
		{
			if (_posts.isSearch)
			{
				if (_wpParser.searchPosts && _wpParser.searchPosts.loadedPosts.length == _wpParser.searchPosts.totalPosts) return;
				
				//_base.showPreloader(true);
				_wpParser.search(null);
			}
			else
			{
				if (_wpParser.posts && _wpParser.posts.loadedPosts.length == (_wpParser.posts.totalPosts - _wpParser.posts.updates)) return;
				
				//_base.showPreloader(true);
				_wpParser.getRecentPosts();
			}
		}
		
		private function onRecentPosts(e:WpEvent):void
		{
			//_base.showPreloader(false);
			_posts.update(e.param);
			onResize();
		}
		
		private function onSearchResult(e:WpEvent):void
		{
			//_base.showPreloader(false);
			_posts.update(e.param);
		}
		
		private function onPostContentListener(e:WpEvent):void
		{
			//_base.showPreloader(false);
			
			if (!_stageWebView) _stageWebView = new StageWebView();
			if (!_rect) _rect = new Rectangle(0, _toolbar.height, stage.stageWidth, stage.stageHeight - _toolbar.height);
			
			_posts.visible = false;
			
			_stageWebView.stage = this.stage;
			_stageWebView.loadString(e.param.content);
			
			if (e.param.comment_status == "open")
			{
				var commentMc:CommentMc = new CommentMc();
				commentMc.addEventListener(MouseEvent.CLICK, toShowComments);
				commentMc.data = e.param;
				commentMc.label_txt.text = e.param.comment_count;
				_toolbar._list_right.add(commentMc);
			}
			
			onResize();
		}
		
		private function toShowPostContent(e:AppEvent):void
		{
			_backBtnEngaged = true;
			//this.dispatchEvent(new AppEvent(AppEvent.BACK_BUTTON_ENGAGED, _backBtnEngaged));
			
			/*if (_base.nativeExtensions.vibration.isSupported) 
			{ 
				_vibe = new _base.nativeExtensions["vibration"](); 
				_vibe.vibrate(25);
			}*/
			
			//_base.showPreloader(true);
			if (e.param.type == "post") _wpParser.getPost(e.param.id);
		}
		
		private function toShowComments(e:MouseEvent):void
		{
			_stageWebView.dispose();
			_stageWebView = null;
			
			initComments(e.currentTarget.data);
		}
		
		private function initComments($data:Object):void
		{
			_toolbar._list_right.removeAll();
			createGeneralReply($data);
			
			_comments = new Comments();
			//_comments.addEventListener(AppEvent.WP_REPLY, initReply);
			_comments.base = this;
			_comments.data = $data;
			
			this.addChild(_comments);
			onResize();
			
			_backBtnEngaged = true;
			//this.dispatchEvent(new AppEvent(AppEvent.BACK_BUTTON_ENGAGED, _backBtnEngaged));
		}
		
		private function initReply(e:*):void
		{
			_toolbar._list_right.removeAll();
			
			_reply = new Reply();
			_reply.addEventListener(AppEvent.SUBMIT_COMMENT, onSubmitComment, false, 0, true);
			_reply.base = this;
			_reply.data = e.target.data;
			
			_comments.visible = false;
			
			this.addChild(_reply);
			onResize();
			
			_backBtnEngaged = true;
			//this.dispatchEvent(new AppEvent(AppEvent.BACK_BUTTON_ENGAGED, _backBtnEngaged));
		}
		
		private function onSubmitComment(e:AppEvent):void
		{
			//_base.showPreloader(true);
			_wpParser.submitComment(e.param.name, e.param.email, e.param.content, e.param.post_id);
		}
		
		private function onCommentResult(e:WpEvent):void
		{
			
			if (e.param.status == "error")
			{
				Toast.show(e.param.error, 2);
			}
			else if (e.param.status == "pending")
			{
				Toast.show("your comment is waited for moderation...", 2);
			}
			else if (e.param.status == "ok")
			{
				Toast.show("successfully posted.", 2);
			}
		}
		
		private function onNavRequest(e:AppEvent):void
		{
			switch (String(e.param.name)) 
			{
				case "SEARCH":
					
					if (NativeTextInputDialog.isSupported)
					{
						if (!_searchDialog) _searchDialog = new NativeTextInputDialog();
						_searchDialog.theme = NativeAlert.ANDROID_HOLO_LIGHT_THEME;
						_searchDialog.addEventListener(NativeDialogEvent.CLOSED, onSearchdialogHandler, false, 0, true);
						
						var v:Vector.<NativeTextField> = new Vector.<NativeTextField>();
						var ti:* = new NativeTextField("keyword");
						ti.prompText = "search";
						ti.text = "";
						v.push(ti);
						
						var b:Vector.<String> = new Vector.<String>();
						b.push("cancel", "Search");
						
						_searchDialog.show(v, b);
						
					}
					
				break;
				case "POSTS":
					
					onDeviceBackButtClick();
					onDeviceBackButtClick();
					
					_posts.isSearch = false;
					_posts.clean();
					_wpParser.posts.clean();
					initPosts();
					
				break;
				default:
			}
		}
		
		private function onResize():void
		{
			if (_toolbar)
			{
				_toolbar.width = stage.stageWidth;
				_toolbar.height = 50;
			}
			
			if (_posts)
			{
				_posts.width = stage.stageWidth;
				_posts.height = stage.stageHeight - _toolbar.height;
				_posts.y = _toolbar.height;
			}
			
			if (_stageWebView && _stageWebView.stage)
			{
				_rect.topLeft = new Point(0, _toolbar.height);
				_rect.bottomRight = new Point(stage.stageWidth, stage.stageHeight);
				_stageWebView.viewPort = _rect;
			}
			
			if (_comments)
			{
				_comments.width = stage.stageWidth;
				_comments.height = stage.stageHeight - _toolbar.height;
				_comments.y = _toolbar.height;
			}
			
			if (_reply)
			{
				_reply.width = stage.stageWidth;
				_reply.height = stage.stageHeight - _toolbar.height;
				_reply.y = _toolbar.height;
			}
		}
		
		private function createGeneralReply($data:Object):void
		{
			var commentMc:CommentMc = new CommentMc();
			commentMc.addEventListener(MouseEvent.CLICK, initReply, false, 0, true);
			commentMc.data = $data;
			commentMc.label_txt.text = "Re";
			_toolbar._list_right.add(commentMc);
		}
		
		private function onSearchdialogHandler(e:*):void
		{
			_searchDialog.removeEventListener(e.type, onSearchdialogHandler);
			
			_keyword = e.target.textInputs[0].text;
			if (e.index > 1 && _keyword.length > 0)
			{
				_posts.clean();
				_posts.isSearch = true;
				_wpParser.search(_keyword);
				//_base.showPreloader(true);
				
				onDeviceBackButtClick();
				onDeviceBackButtClick();
			}
		}
		
		private function handleKeys(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.BACK)
            {
				if (_backBtnEngaged)
				{
					e.preventDefault();
				}
				
				
				onDeviceBackButtClick();
				
            }
		}
		
		private function onDeviceBackButtClick():void
		{
			if (_stageWebView && _stageWebView.stage)
			{
				_stageWebView.dispose();
				_stageWebView = null;
				
				_posts.visible = true;
				
				_toolbar._list_right.removeAll();
				
				_backBtnEngaged = false;
			}
			
			if (_reply)
			{
				_toolbar._list_right.removeAll();
				createGeneralReply(_reply.data);
				
				_comments.visible = true;
				
				this.removeChild(_reply);
				_reply = null;
				
				return;
			}
			
			if (_comments)
			{
				this.removeChild(_comments);
				_comments = null;
				
				_posts.visible = true;
				
				_toolbar._list_right.removeAll();
				
				_backBtnEngaged = false;
			}
		}
		
	}
	
}