package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class BlockButton extends Entity
	{
		public var image:Image;
		public var player:String;
		public var shape:String;
		public var size:int;
		public var timer:int = 0;
		
		public static var rotations:Object = {};
		
		public function BlockButton (_x:int, _y:int, _size:int, _shape:String, _player:String)
		{
			x = _x - _size*0.5;
			y = _y - _size*0.5;
			
			layer = -20;
			
			size = _size;
			shape = _shape;
			player = _player;
			
			setHitbox(_size, _size);
			
			if (! rotations[shape+player]) rotations[shape+player] = 0;
			
			makeImage();
			
			type = "button";
		}
		
		private function makeImage ():void
		{
			if (shape == "random") {
				image = new Image(Menu.RandomGfx);
			} else {
				image = new Image(Main.makeShape(shape, rotations[shape+player], Menu.SmallBlockGfx));
			}
			
			image.color = (player == "P1") ? 0xFFFF00 : 0xFF00FF;
			image.centerOO();
			image.x = size*0.5;
			image.y = size*0.5;
			
			graphic = image;
		}
		
		public override function update (): void
		{
			if (!world) return;
			
			timer++;
			
			var over:Boolean = collidePoint(x, y, world.mouseX, world.mouseY);
			
			if (over) {
				Input.mouseCursor = "button";
			}
			
			if (over && Input.mousePressed) {
				callback();
			}
		}
		
		public override function render (): void
		{
			var over:Boolean = collidePoint(x, y, world.mouseX, world.mouseY);
			var selected:Boolean = (Settings["menuShape"+player] == shape);
			
			if (over || selected) {
				var g:Graphics = FP.sprite.graphics;
			
				g.clear();
				
				if (selected) {
					g.beginFill((false && over && Input.mouseDown && selected) ? 0xFFBBBBBB : 0xFFDDDDDD);
				}
				
				if (over && (timer % 60) < 30) {
					g.lineStyle(2, 0xFF0000);
				} else if (over) {
					g.lineStyle(2, 0x999999);
				} else if (selected) {
					g.lineStyle(2, 0x0000FF);
				}
				
				g.drawRoundRect(x+1, y+1, width-2, height-2, 10);
				
				g.endFill();
			
				FP.buffer.draw(FP.sprite);
			}
			
			super.render();
			
			if (shape != "random" && shape != "O" && selected && over && !Input.mouseDown) {
				FP.point.x = x+2;
				FP.point.y = y+2;
				
				var rotate:BitmapData = FP.getBitmap(Menu.RotateGfx);
				
				FP.buffer.copyPixels(rotate, rotate.rect, FP.point, null, null, true);
			}
		}
		
		public function callback ():void
		{
			var alreadySelected:Boolean = (Settings["menuShape"+player] == shape);
			
			if (alreadySelected && (shape == "random" || shape == "O")) {
				return;
			}
			
			if (alreadySelected && shape != "random") {
				rotations[shape+player] += 1;
				makeImage();
			}
			
			Settings["menuShape"+player] = shape;
			Settings["menuRotation"+player] = rotations[shape+player] % 4;
			
			Audio.play("block");
		}
		
	}
}

