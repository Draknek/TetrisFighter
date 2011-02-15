package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Menu extends World
	{
		[Embed(source="images/menu.png")] public static const BgGfx: Class;
		[Embed(source="block-small.png")] public static const SmallBlockGfx: Class;
		[Embed(source="random.png")] public static const RandomGfx: Class;
		
		[Embed(source = 'fonts/MODENINE.TTF', embedAsCFF="false", fontFamily = 'modenine')]
		public static const ModeNineFont:Class;
		
		public var padding1:int = 8;
		public var paddingA:int = 0;
		public var paddingB:int = 10;
		public var size1:int = 64+padding1;
		public var size2:int = size1*3+paddingA*2+paddingB*2;
		
		public var padding2:int = (640 - 64 - size2*2)/3;
		
		public var x1:int = 32+padding2;
		public var x2:int = 640 - 32 - padding2 - size2;
		public var yBlock:int = 96;
		public var yText:int = 96;
		
		public function Menu ()
		{
			addGraphic(new Stamp(BgGfx));
			
			addGraphic(new Stamp(Main.makeBlock(size2, size2)), 0, x1, yBlock);
			addGraphic(new Stamp(Main.makeBlock(size2, size2)), 0, x2, yBlock);
			
			var p1:Text = new Text("P1", 0, 0, {size:40, color:0x0});
			var p2:Text = new Text("P2", 0, 0, {size:40, color:0x0});
			p1.centerOO();
			p2.centerOO();
			addGraphic(p1, -1, x1+size2*0.5, yBlock+size2*0.5);
			addGraphic(p2, -1, x2+size2*0.5, yBlock+size2*0.5);
			
			makeShape("J", 0, 0);
			makeShape("T", 1, 0);
			makeShape("L", 2, 0);
			makeShape("O", 2, 1);
			makeShape("Z", 0, 2);
			makeShape("I", 1, 2);
			makeShape("S", 2, 2);
			
			var random:Image;
			
			random = new Image(RandomGfx);
			random.color = 0xFFFF00;
			random.centerOO();
			
			addGraphic(random, 0, x1 + getDelta(0, true), yBlock + getDelta(1, true));
			
			random = new Image(RandomGfx);
			random.color = 0xFF00FF;
			random.centerOO();
			
			addGraphic(random, 0, x2 + getDelta(2, true), yBlock + getDelta(1, true));
			
			var fightButton:Button = makeButton("FIGHT", function():void{
				FP.world = new Level("", "", true);
			});
			
			fightButton.y = (yBlock + size2 + 480 - 64 - fightButton.height)*0.5;
			
			//fightButton.disabled = true;
			
			add(fightButton);
		}
		
		private function makeShape(shape:String, i:int, j:int):void
		{
			var dx:int = getDelta(i, true);
			var dy:int = getDelta(j, true);
			
			var bitmap:BitmapData = Main.makeShape(shape, SmallBlockGfx);
			
			var image:Image;
			
			image = new Image(bitmap);
			image.color = 0xFFFF00;
			image.centerOO();
			
			addGraphic(image, 0, x1 + dx, yBlock + dy);
			
			image = new Image(bitmap);
			image.color = 0xFF00FF;
			image.centerOO();
			
			if (shape == "O") dx = getDelta(0, true);
			
			addGraphic(image, 0, x2 + dx, yBlock + dy);
		}
		
		public static function makeButton (text:String, callback:Function):Button
		{
			var fight:Text = new Text(text, 0, 0, {size: 30, color: 0x0});
			
			var fightBG:BitmapData = Main.makeBlock(200, fight.height+12);
			
			FP.point.x = (fightBG.width - fight.width)*0.5;
			FP.point.y = 6;
			fight.render(fightBG, FP.point, FP.zero);
			
			var fightButton:Button = new Button(0, 0, fightBG, callback);
			
			fightButton.x = 320 - fightButton.width*0.5;
			
			return fightButton;
		}
		
		private function getDelta (i:int, center:Boolean = false):int
		{
			return paddingB + (paddingA + size1)*i + int(center)*size1*0.5;
		}
		
		public override function update (): void
		{
			Input.mouseCursor = "auto";
			
			super.update();
			
			for (var i:int = 0; i < 3; i++) {
				for (var j:int = 0; j < 3; j++) {
					if (i == 1 && j == 1) continue;
					
					var dx:int = getDelta(i);
					var dy:int = getDelta(j);
					
					if (test(x1 + dx, yBlock + dy, size1, size1) || test(x2 + dx, yBlock + dy, size1, size1)) {
						Input.mouseCursor = "button";
					}
				}
			}
		}
		
		public function test (x:int, y:int, w:int, h:int):Boolean
		{
			var mx:int = Input.mouseX;
			var my:int = Input.mouseY;
			return (mx >= x && mx < x+w && my >= y && my < y+h);
		}
		
		public override function render (): void
		{
			super.render();
			
			var g:Graphics = FP.sprite.graphics;
			
			g.clear();
			
			var i:int;
			var j:int;
			var dx:int;
			var dy:int;
			
			//g.beginFill(0xFFEEEEEE);
			g.lineStyle(2, 0x0000FF);
			
			for (i = 0; i < 3; i++) {
				for (j = 0; j < 3; j++) {
					if (i == 1 && j == 1) continue;
					
					dx = getDelta(i);
					dy = getDelta(j);
					
					if (test(x1 + dx, yBlock + dy, size1, size1)) {
						g.drawRoundRect(x1 + dx, yBlock + dy, size1, size1, padding1);
					}
					
					if (test(x2 + dx, yBlock + dy, size1, size1)) {
						g.drawRoundRect(x2 + dx, yBlock + dy, size1, size1, padding1);
					}
				}
			}
			
			g.endFill();
			
			FP.buffer.draw(FP.sprite);
		}
	}
}

