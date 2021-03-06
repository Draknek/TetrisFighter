package
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.SharedObject;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import net.flashpunk.utils.Key;
	import net.flashpunk.*;
	
	public class Audio
	{
		[Embed(source="audio/death.mp3")]
		public static var DeathSfx:Class;
		
		[Embed(source="audio/blip.mp3")]
		public static var HitSfx:Class;
		
		[Embed(source="audio/blip2.mp3")]
		public static var Hit2Sfx:Class;
		
		[Embed(source="audio/music.mp3")]
		public static var MusicSfx:Class;
		
		private static var music:Sfx;
		private static var musicTween:Tween;
		
		private static var sounds:Object = {};
		
		private static var _mute:Boolean = false;
		private static var so:SharedObject;
		private static var menuItem:ContextMenuItem;
		
		public static function init (o:InteractiveObject):void
		{
			// Setup
			
			so = SharedObject.getLocal("audio", "/");
			
			_mute = so.data.mute;
			
			addContextMenu(o);
			
			if (o.stage) {
				addKeyListener(o.stage);
			} else {
				o.addEventListener(Event.ADDED_TO_STAGE, stageAdd);
			}
			
			// Create sounds
			
			music = new Sfx(MusicSfx);
			
			sounds["death"] = new Sfx(DeathSfx);
			sounds["hit"] = new Sfx(Hit2Sfx);
			sounds["block"] = new Sfx(HitSfx);
			//sounds["hit"] = new RandomSfx([HitSfx, Hit2Sfx]);
		}
		
		public static function startMusic ():void
		{
			if (_mute) return;
			
			if (musicTween) {
				musicTween.cancel();
			}
			
			if (! music.playing || musicTween) {
				music.loop();
			}
			
			musicTween = null;
		}
		
		public static function stopMusic ():void
		{
			if (_mute || ! music) return;
			
			musicTween = FP.tween(music, {volume: 0}, 240);
		}
		
		public static function play (sound:String):void
		{
			if (! _mute) {
				sounds[sound].play();
			}
		}
		
		// Getter and setter for mute property
		
		public static function get mute (): Boolean { return _mute; }
		
		public static function set mute (newValue:Boolean): void
		{
			if (_mute == newValue) return;
			
			_mute = newValue;
			
			menuItem.caption = _mute ? "Unmute" : "Mute";
			
			so.data.mute = _mute;
			so.flush();
		}
		
		// Implementation details
		
		private static function stageAdd (e:Event):void
		{
			addKeyListener(e.target.stage);
		}
		
		private static function addContextMenu (o:InteractiveObject):void
		{
			var menu:ContextMenu = o.contextMenu || new ContextMenu;
			
			menu.hideBuiltInItems();
			
			menuItem = new ContextMenuItem(_mute ? "Unmute" : "Mute");
			
			menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuListener);
			
			menu.customItems.push(menuItem);
			
			o.contextMenu = menu;
		}
		
		private static function addKeyListener (stage:Stage):void
		{
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener);
		}
		
		private static function keyListener (e:KeyboardEvent):void
		{
			if (e.keyCode == Key.M) {
				mute = ! mute;
			}
		}
		
		private static function menuListener (e:ContextMenuEvent):void
		{
			mute = ! mute;
		}
	}
}

