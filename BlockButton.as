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
		public var callback:Function;
		
		public static var rotations:Object = {};
		
		public function BlockButton (_x:int, _y:int, _size:int, _shape:String, _player:String, _callback:Function = null)
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
			
			callback = _callback;
			
			if (callback == null) callback = defaultCallback;
		}
		
		private function makeImage ():void
		{
			if (shape == "random") {
				image = new Image(Menu.RandomGfx);
			} else if (shape == "ai") {
				image = new Image(Menu.AIGfx);
			} else if (shape) {
				image = new Image(Main.makeShape(shape, rotations[shape+player], Menu.SmallBlockGfx));
			}
			
			if (image) {
				if (shape == "ai") {
					image.color = 0xAAAAAA;
				} else {
					image.color = (player == "P1") ? 0xFFFF00 : 0xFF00FF;
				}
				
				image.centerOO();
				image.x = size*0.5;
				image.y = size*0.5;
			
				graphic = image;
			}
		}
		
		public override function update (): void
		{
			if (!world) return;
			
			timer++;
			
			var over:Boolean = isOver();
			
			if (over && ! Settings.arcade) {
				Input.mouseCursor = "button";
			}
			
			var click:Boolean = Input.mousePressed;
			
			if (Settings.arcade) {
				click = Input.pressed("action" + player);
			}
			
			if (over && click) {
				callback();
			}
		}
		
		public override function render (): void
		{
			var over:Boolean = isOver();
			
			var selected:Boolean = (shape && Settings["menuShape"+player] == shape);
			
			if (over || selected) {
				var g:Graphics = FP.sprite.graphics;
			
				g.clear();
				
				if (selected) {
					g.beginFill((false && over && Input.mouseDown && selected) ? 0xFFBBBBBB : 0xFFDDDDDD);
				}
				
				if (over && (timer % 60) < 30) {
					g.lineStyle(2, 0xFF0000);
				} else if (selected) {
					g.lineStyle(2, 0x0000FF);
				} else if (over) {
					g.lineStyle(2, 0x999999);
				}
				
				g.drawRoundRect(x+1, y+1, width-2, height-2, 10);
				
				g.endFill();
			
				FP.buffer.draw(FP.sprite);
			}
			
			super.render();
			
			var mouseDown:Boolean = Input.mouseDown;
			
			if (Settings.arcade) {
				return;
				//mouseDown = Input.check("action" + player);
			}
			
			if (shape != "random" && shape != "O" && selected && over && !mouseDown) {
				FP.point.x = x+2;
				FP.point.y = y+2;
				
				var rotate:BitmapData = FP.getBitmap(Menu.RotateGfx);
				
				FP.buffer.copyPixels(rotate, rotate.rect, FP.point, null, null, true);
			}
		}
		
		public function isOver ():Boolean
		{
			if (Settings.arcade) {
				return (Menu(world)["selected" + player] == this);
			} else {
				return collidePoint(x, y, world.mouseX, world.mouseY);
			}
		}
		
		public function defaultCallback ():void
		{
			var alreadySelected:Boolean = (Settings["menuShape"+player] == shape);
			
			if (alreadySelected && (Settings.arcade || shape == "random" || shape == "O")) {
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

