package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import flash.display.*;
	import flash.geom.*;
	
	import flash.display.StageDisplayState;
	
	[SWF(width = "640", height = "480", backgroundColor="#000000")]
	public class Main extends Engine
	{
		public static var host:String;
		
		public function Main () 
		{
			var w:int = 640;
			var h:int = 480;
			
			if (Settings.arcade) {
				w = 1024;
				h = 768;
			}
			
			super(w, h, 60, true);
			
			Text.font = "modenine";
			
			//FP.world = new Level(true);
			//FP.console.enable();
		}
		
		public override function init (): void
		{
			sitelock("draknek.org");
			
			Settings.init();
			
			if (Settings.arcade) {
				FP.stage.displayState = StageDisplayState.FULL_SCREEN;
				
				FP.screen.x = (FP.stage.stageWidth - FP.width) * 0.5;
			}
			
			FP.world = new Menu;
			
			Audio.init(this);
			
			super.init();
		}
		
		public override function focusLost():void
		{
			if (Settings.arcade) {
				FP.focused = true;
			}
		}
		
		public function sitelock (allowed:*):Boolean
		{
			var url:String = FP.stage.loaderInfo.url;
			var startCheck:int = url.indexOf('://' ) + 3;
			
			if (url.substr(0, startCheck) == 'file://') return true;
			
			var domainLen:int = url.indexOf('/', startCheck) - startCheck;
			host = url.substr(startCheck, domainLen);
			
			if (allowed is String) allowed = [allowed];
			for each (var d:String in allowed)
			{
				if (host.substr(-d.length, d.length) == d) return true;
			}
			
			parent.removeChild(this);
			throw new Error("Error: this game is sitelocked");
			
			return false;
		}
		
		public static function makeBlock (w:int, h:int):BitmapData
		{
			var orig:BitmapData = FP.getBitmap(Player.BlockGfx).clone();
			
			var source:Bitmap = new ScaleBitmap(orig);
			
			var r:Rectangle = new Rectangle(6, 6, 20, 20);
			
			source.scale9Grid = r;
			
			source.width = w;
			source.height = h;
			
			return source.bitmapData.clone();
		}
		
		public static function makeShape (shape:String, rotation:int, input:*):*
		{
			if (input is Class) input = FP.getBitmap(input);
			
			var w:int;
			var h:int;
			
			switch (shape) {
				case "I": w = 1; h = 4; break;
				case "J": w = 2; h = 3; break;
				case "L": w = 2; h = 3; break;
				case "O": w = 2; h = 2; break;
				case "S": w = 3; h = 2; break;
				case "Z": w = 3; h = 2; break;
				case "T": w = 3; h = 2; break;
			}
			
			rotation = rotation % 4;
			
			if (rotation == 1 || rotation == 3) {
				var tmp:int = w;
				w = h;
				h = tmp;
			}
			
			var output:*;
			
			if (input is BitmapData) output = new BitmapData(w*input.width, h*input.height, true, 0x0);
			else output = new Grid(w*input.width, h*input.height, input.width, input.height);
			
			switch (shape) {
				case "I":
					placeBlocksOnShape(0, 0, 0, 1, 0, 2, 0, 3, input, output, rotation);
				break;
				case "J":
					placeBlocksOnShape(1, 0, 1, 1, 1, 2, 0, 2, input, output, rotation);
				break;
				case "L":
					placeBlocksOnShape(0, 0, 0, 1, 0, 2, 1, 2, input, output, rotation);
				break;
				case "O":
					placeBlocksOnShape(0, 0, 0, 1, 1, 0, 1, 1, input, output, rotation);
				break;
				case "S":
					placeBlocksOnShape(1, 0, 2, 0, 0, 1, 1, 1, input, output, rotation);
				break;
				case "Z":
					placeBlocksOnShape(0, 0, 1, 0, 1, 1, 2, 1, input, output, rotation);
				break;
				case "T":
					placeBlocksOnShape(0, 0, 1, 0, 2, 0, 1, 1, input, output, rotation);
				break;
			}
			
			return output;
		}
		
		private static function placeBlocksOnShape (x1:int, y1:int, x2:int, y2:int, x3:int, y3:int, x4:int, y4:int, input:*, output:*, rotation:int):void
		{
			placeBlockOnShape(x1, y1, input, output, rotation);
			placeBlockOnShape(x2, y2, input, output, rotation);
			placeBlockOnShape(x3, y3, input, output, rotation);
			placeBlockOnShape(x4, y4, input, output, rotation);
		}
		
		private static function placeBlockOnShape (x1:int, y1:int, input:*, output:*, rotation:int):void
		{
			var w:int = output.width / input.width;
			var h:int = output.height / input.height;
			
			var x:int = x1;
			var y:int = y1;
			
			if (rotation == 1) {
				x = w - 1 - y1
				y = x1;
			} else if (rotation == 2) {
				x = w - 1 - x1;
				y = h - 1 - y1;
			} else if (rotation == 3) {
				x = y1
				y = h - 1 - x1;
			}
			
			if (output is BitmapData) {
				FP.point.x = x*input.width;
				FP.point.y = y*input.height;
			
				output.copyPixels(input, input.rect, FP.point);
			} else {
				output.setTile(x, y, true);
			}
		}
		
		public static const SHAPES:Array = ["I", "J", "L", "O", "S", "Z", "T"];
			
	}
}

