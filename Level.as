package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Level extends World
	{
		//[Embed(source="images/bg.png")] public static const BgGfx: Class;
		
		public var p1:Player;
		public var p2:Player;
		
		public var gameOver:Boolean = false;
		
		public var left:Stamp;
		public var right:Stamp;
		
		public var leftCover:Entity;
		public var rightCover:Entity;
		
		public static var livesP1:int = 10;
		public static var livesP2:int = 10;
		
		public function Level ()
		{
			add(p1 = new Player(1));
			add(p2 = new Player(-1));
			
			p1.enemy = p2;
			p2.enemy = p1;
			
			var block:Image = new Image(Player.BlockGfx);
			
			block.color = 0x00FF00;
			
			var stamp:Stamp = new Stamp(new BitmapData(640-64, 64), 32, 480-64);
			left = new Stamp(new BitmapData(32, 480), 0, 0);
			right = new Stamp(new BitmapData(32, 480), 640-32, 0);
			
			var i:int;
			
			for (i = 0; i < 18; i++) {
				FP.point.x = (i) * block.width;
				FP.point.y = 0;
				block.render(stamp.source, FP.point, FP.zero);
			}
			
			block.color = 0x00BB00;
			
			for (i = 0; i < 18; i++) {
				FP.point.x = (i) * block.width;
				FP.point.y = 32;
				block.render(stamp.source, FP.point, FP.zero);
			}
			
			block.color = 0xFF0000;
			
			for (i = 0; i < 15; i++) {
				FP.point.x = 0;
				FP.point.y = 32*i;
				block.render(left.source, FP.point, FP.zero);
				block.render(right.source, FP.point, FP.zero);
			}
			
			addGraphic(stamp);
			addGraphic(left);
			addGraphic(right);
			
			leftCover = addGraphic(Image.createRect(p1.width*0.5, p1.height, FP.screen.color), 0, 0, p1.y);
			rightCover = addGraphic(Image.createRect(p1.width*0.5, p1.height, FP.screen.color), 0, FP.width - p1.width*0.5, p1.y);
			
			addGraphic(new Text("Attack: Z\nBlock: A\nJump: Z+A", 64, 280));
			addGraphic(new Text("Attack: M\nBlock: K\nJump: M+K", 0, 280, {width:640-64, align:"right"}));
		}
		
		private static function drawBlock ():void
		{
			
		}
		
		public override function update (): void
		{
			// super.update(); // calling everything manually for the time being
			
			if (! gameOver) {
				p1.doMovement();
				p2.doMovement();
			
				p1.touching = p2.touching = (p1.collideWith(p2, p1.x, p1.y) != null);
			
				p1.doActions();
				p2.doActions();
			
				//p1.checkPosition();
				//p2.checkPosition();
			
				if (p1.x <= 32) {
					p1.y = p1.floorY;
					p1.x = 32;
					gameOver = true;
					
					livesP1--;
				
					doGameover(-1);
				}
			
				if (p2.x >= FP.width - 32) {
					p2.y = p2.floorY;
					p2.x = FP.width - 32;
					gameOver = true;
					
					livesP2--;
				
					doGameover(1);
				}
			
				while (p1.collideWith(p2, p1.x, p1.y)) {
					p1.x -= 0.5;
					p2.x += 0.5;
				}
			}
		}
		
		private function doGameover (side:int):void
		{
			Audio.play("death");
			
			var x:Number = (side < 0) ? 0 : 640-32;
			
			var cover:Image = Image.createRect(p1.width*0.5, FP.height, FP.screen.color);
			var e:Entity = addGraphic(cover, -20, x, 0);
			cover.alpha = 0;
			
			FP.tween(cover, {alpha: 1}, 60, {complete:function ():void {
				var newBlocks:Stamp = (side < 0) ? left : right;
				newBlocks.x = x + side*32;
				
				FP.tween(newBlocks, {x: x}, 60, {complete:function ():void {
					FP.world = new Level;
				}});
				
				((side < 0) ? leftCover : rightCover).layer = -20;
				
				remove(e);
				
				var victor:Player = (side < 0) ? p2 : p1;
				var loser:Player = (side < 0) ? p1 : p2;
				
				FP.tween(victor, {x: victor.spawn, y: 480-128}, 60, {tweener: FP.tweener});
				
				var cover2:Image = Image.createRect(64, 64, FP.screen.color);
				
				addGraphic(cover2, -20, loser.x-32, loser.y);
				
				cover2.alpha = 0;
				
				FP.tween(cover2, {alpha: 1}, 60);
			}});
		}
		
		public override function render (): void
		{
			super.render();
		}
	}
}

