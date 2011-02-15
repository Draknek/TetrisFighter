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
		
		public var paused:Boolean = false;
		
		public var left:Stamp;
		public var right:Stamp;
		
		public var leftCover:Entity;
		public var rightCover:Entity;
		
		public static var livesP1:int = 10;
		public static var livesP2:int = 10;
		
		public var shake:Number = 0;
		
		public var doIntro:Boolean = false;
		
		public function Level (shape1:String="", shape2:String="", doIntro:Boolean = false)
		{
			this.doIntro = doIntro;
			
			add(p1 = new Player(1, shape1));
			add(p2 = new Player(-1, shape2));
			
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
			
			var p1Intro:Text = new Text("Yellow\nO-Block", 180, 160, {size: 30, align:"center"});
			var p2Intro:Text = new Text("Purple\nO-Block", 460, 160, {size: 30, align:"center"});
			var vs:Text = new Text("VS", 320, 160, {size:90});
			
			var p1Controls:Text = new Text("Attack: Z\nBlock: A\nJump: Hold Z+A", 180, 240, {align:"center",size:15});
			var p2Controls:Text = new Text("Attack: M\nBlock: K\nJump: Hold M+K", 460, 240, {align:"center",size:15});
			
			p1Intro.centerOO();
			p2Intro.centerOO();
			vs.centerOO();
			p1Controls.centerOO();
			p2Controls.centerOO();
			
			p1Intro.color = 0xFFFF00;
			p2Intro.color = 0xFF00FF;
			
			addGraphic(p1Intro, -10);
			addGraphic(p2Intro, -10);
			addGraphic(vs, -10);
			addGraphic(p1Controls, -10);
			addGraphic(p2Controls, -10);
			
			if (doIntro) {
				paused = true;
				
				var delay:int = 25;
			
				p1Intro.x -= 300;
				p2Intro.x += 300;
				vs.y -= 300;
				p1.y = -100;
				p2.y = -100;
			
				p1Controls.alpha = 0;
				p2Controls.alpha = 0;
			
				var world:World = this;
			
				FP.alarm(1      , function ():void {FP.tween(p1Intro, {x:180}, delay)});
				FP.alarm(delay  , function ():void {FP.tween(vs, {y: 160}, delay)});
				FP.alarm(delay*2, function ():void {FP.tween(p2Intro, {x:460}, delay)});
				FP.alarm(delay*3, function ():void {FP.tween(p1, {y:p1.floorY}, delay, {tweener:world})});
				FP.alarm(delay*3, function ():void {FP.tween(p2, {y:p2.floorY}, delay, {tweener:world})});
				FP.alarm(delay*4, function ():void {Audio.play("hit");paused = false; doIntro = false; shake = 8; FP.tween(world, {shake: 0}, delay*0.5)});
				FP.alarm(delay*4, function ():void {shake = 8; FP.tween(p1Controls, {alpha: 1}, delay*0.5)});
				FP.alarm(delay*4, function ():void {shake = 8; FP.tween(p2Controls, {alpha: 1}, delay*0.5)});
			}
		}
		
		public override function update (): void
		{
			// super.update(); // calling everything manually for the time being
			
			camera.x = (FP.random - 0.5)*shake;
			camera.y = (FP.random - 0.5)*shake;
			
			if (paused) {
				if (doIntro && (Input.pressed(p1.attackKey) || Input.pressed(p2.attackKey))) {
					paused = false;
					doIntro = false;
					
					var tween:Tween;
					while(tween = FP.tweener._tween) {
						while (tween) {
							tween._time = tween._target;
							tween.update();
							tween.finish();
							tween = tween._next;
						}
					}
					
					FP.tweener.clearTweens();
					
					shake = 0;
				}
			} else {
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
					paused = true;
					
					livesP1--;
				
					doGameover(-1);
				}
			
				if (p2.x >= FP.width - 32) {
					p2.y = p2.floorY;
					p2.x = FP.width - 32;
					paused = true;
					
					livesP2--;
				
					doGameover(1);
				}
			
				if (p1.collideWith(p2, p1.x, p1.y)) {
					p1.x -= 0.5;
					p2.x += 0.5;
				}
			}
		}
		
		private function doGameover (side:int):void
		{
			Audio.play("death");
			
			var victor:Player = (side < 0) ? p2 : p1;
			var loser:Player = (side < 0) ? p1 : p2;
			
			var x:Number = (side < 0) ? 0 : 640-32;
			
			var cover:Image = Image.createRect(p1.width*0.5, FP.height, FP.screen.color);
			var e:Entity = addGraphic(cover, -20, x, 0);
			cover.alpha = 0;
			
			shake = 6;
			
			FP.tween(this, {shake: 0}, 15);
			
			FP.alarm(15, function ():void {
			
			FP.tween(cover, {alpha: 1}, 60, {complete:function ():void {
				var newBlocks:Stamp = (side < 0) ? left : right;
				newBlocks.x = x + side*32;
				
				FP.tween(newBlocks, {x: x}, 60, {complete:function ():void {
					FP.world = new Level;
				}});
				
				((side < 0) ? leftCover : rightCover).layer = -20;
				
				remove(e);
				
				FP.tween(victor, {x: victor.spawn, y: 480-128}, 60, {tweener: FP.tweener});
				
				FP.tween(loser.image, {alpha: 0}, 60);
			}});
			
			});
		}
		
		public override function render (): void
		{
			super.render();
		}
		
		public override function begin ():void
		{
			Input.mouseCursor = "hide";
		}
		
		public override function end ():void
		{
			Input.mouseCursor = "auto";
		}
	}
}

