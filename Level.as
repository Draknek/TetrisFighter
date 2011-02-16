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
		
		public static var livesP1:int;
		public static var livesP2:int;
		
		public var shake:Number = 0;
		
		public var doIntro:Boolean = false;
		public var showCursor:Boolean = false;
		
		public var p1Intro:Text;
		public var p2Intro:Text;
		public var vs:Text;
		public var p1Controls:Text;
		public var p2Controls:Text;
		
		public function Level (shape1:String="", shape2:String="", _doIntro:Boolean = false)
		{
			this.doIntro = _doIntro;
			
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
			
			p1Intro = new Text("Yellow\nO-Block", 180, 160, {size: 30, align:"center"});
			p2Intro = new Text("Purple\nO-Block", 460, 160, {size: 30, align:"center"});
			vs = new Text("VS", 320, 160, {size:90});
			p1Controls = new Text("Attack: Z\nJump: Hold A\nBlock: Q", 180, 240, {align:"center",size:15});
			p2Controls = new Text("Attack: M\nJump: Hold K\nBlock: O", 460, 240, {align:"center",size:15});
			
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
				livesP1 = 10;
				livesP2 = 10;
				
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
			if (paused && showCursor) {
				Input.mouseCursor = "auto";
			}
			
			super.update(); // note: this doesn't do anything to players
			
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
			
			var f:Function;
			
			if (livesP1 >= 0 && livesP2 >= 0) {
				f = function ():void {
					var newBlocks:Stamp = (side < 0) ? left : right;
					newBlocks.x = x + side*32;
			
					FP.tween(newBlocks, {x: x}, 60, {complete:function ():void {
						FP.world = new Level;
					}});
			
					((side < 0) ? leftCover : rightCover).layer = -20;
			
					remove(e);
					
					FP.tween(victor, {x: victor.spawn, y: 480-128}, 60, {tweener: FP.tweener});
			
					FP.tween(loser.image, {alpha: 0}, 60);
				}
			} else {
				f = function ():void {
					FP.tween(vs, {alpha: 0}, 30);
					FP.tween(p1Controls, {alpha: 0}, 30);
					FP.tween(p2Controls, {alpha: 0}, 30);
				
					var victorName:Text = (side < 0) ? p2Intro : p1Intro;
					var loserName:Text = (side < 0) ? p1Intro : p2Intro;
				
					FP.tween(loserName, {alpha: 0}, 30);
				
					victorName.size = 60;
					victorName.updateBuffer();
					victorName.centerOO();
					victorName.size = 30;
					victorName.y += victorName.height*0.25;
				
					FP.tween(victorName, {size:60, x:320, y:120}, 30);
					
					//Input.mouseCursor = "auto";
				
					FP.alarm(30, function ():void {
						var wins:Text = new Text("WINS!", 320, 210, {size:50});
					
						wins.centerOO();
						wins.alpha = 0;
					
						addGraphic(wins, -10);
					
						FP.tween(wins, {alpha:1}, 30);
						
						var replay:Button = Menu.makeButton("Rematch?", function ():void {
							FP.world = new Level("", "", true);
						});
						
						replay.y = 270;
						
						Image(replay.graphic).alpha = 0;
						
						add(replay);
					
						FP.tween(replay.graphic, {alpha:1}, 30);
						
						showCursor = true;
					});
				
					FP.tween(loser.image, {alpha: 0}, 60);
				}
			}
			
			FP.alarm(15, function ():void {
				FP.tween(cover, {alpha: 1}, 60, {complete:f});
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

