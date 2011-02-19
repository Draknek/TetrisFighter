package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import flash.display.*;
	import flash.geom.*;
	
	[SWF(width = "640", height = "480", backgroundColor="#000000")]
	public class Main extends Engine
	{
		public function Main () 
		{
			super(640, 480, 60, true);
			
			Text.font = "modenine";
			
			FP.world = new Level(true);
//			FP.console.enable();
		}
		
		public override function init (): void
		{
			sitelock("draknek.org");
			
			Audio.init(this);
			
			super.init();
		}
		
		public function sitelock (allowed:*):Boolean
		{
			var url:String = FP.stage.loaderInfo.url;
			var startCheck:int = url.indexOf('://' ) + 3;
			
			if (url.substr(0, startCheck) == 'file://') return true;
			
			var domainLen:int = url.indexOf('/', startCheck) - startCheck;
			var host:String = url.substr(startCheck, domainLen);
			
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
		
		public static function makeShape (shape:String, input:*):*
		{
			input = FP.getBitmap(input);
			
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
			
			var output:BitmapData = new BitmapData(w*input.width, h*input.height, true, 0x0);
			
			switch (shape) {
				case "I":
					placeBlocksOnShape(0, 0, 0, 1, 0, 2, 0, 3, input, output);
				break;
				case "J":
					placeBlocksOnShape(1, 0, 1, 1, 1, 2, 0, 2, input, output);
				break;
				case "L":
					placeBlocksOnShape(0, 0, 0, 1, 0, 2, 1, 2, input, output);
				break;
				case "O":
					placeBlocksOnShape(0, 0, 0, 1, 1, 0, 1, 1, input, output);
				break;
				case "S":
					placeBlocksOnShape(1, 0, 2, 0, 0, 1, 1, 1, input, output);
				break;
				case "Z":
					placeBlocksOnShape(0, 0, 1, 0, 1, 1, 2, 1, input, output);
				break;
				case "T":
					placeBlocksOnShape(0, 0, 1, 0, 2, 0, 1, 1, input, output);
				break;
			}
			
			return output;
		}
		
		private static function placeBlocksOnShape (x1:int, y1:int, x2:int, y2:int, x3:int, y3:int, x4:int, y4:int, input:*, output:*):void
		{
			placeBlockOnShape(x1, y1, input, output);
			placeBlockOnShape(x2, y2, input, output);
			placeBlockOnShape(x3, y3, input, output);
			placeBlockOnShape(x4, y4, input, output);
		}
		
		private static function placeBlockOnShape (x:int, y:int, input:*, output:*):void
		{
			FP.point.x = x*input.width;
			FP.point.y = y*input.height;
			
			output.copyPixels(input, input.rect, FP.point);
		}
	}
}

