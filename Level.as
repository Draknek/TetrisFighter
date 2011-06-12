package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Level extends World
	{
		public var p1:Player;
		public var p2:Player;
		
		public var paused:Boolean = false;
		public var doIntro:Boolean = false;
		public var gameOver:Boolean = false;
		public var showCursor:Boolean = false;
		
		public var left:Stamp;
		public var right:Stamp;
		
		public static var livesP1:int;
		public static var livesP2:int;
		
		public var shake:Number = 0;
		
		public var p1Intro:Text;
		public var p2Intro:Text;
		public var vs:Text;
		public var p1Controls:Text;
		public var p2Controls:Text;
		
		private var buttonPressQuit:Boolean;
		
		private static var block:Image = new Image(Player.BlockGfx);
		
		public static function makeFloor():Stamp
		{
			var h:int = 64;
			
			if (Settings.arcade) h = 128;
			
			var stamp:Stamp = new Stamp(new BitmapData(FP.width-64, h), 32, 0);
			
			stamp.y = FP.height - stamp.height;
			
			var i:int;
			var count:int = stamp.width / block.width;
			
			block.color = 0x00FF00;
			
			for (i = 0; i < count; i++) {
				FP.point.x = (i) * block.width;
				FP.point.y = 0;
				block.render(stamp.source, FP.point, FP.zero);
			}
			
			block.color = 0x00BB00;
			
			for (i = 0; i < count; i++) {
				FP.point.x = (i) * block.width;
				FP.point.y = 32;
				block.render(stamp.source, FP.point, FP.zero);
			}
			
			block.color = 0x007700;
			
			for (i = 0; i < count; i++) {
				FP.point.x = (i) * block.width;
				FP.point.y = 64;
				block.render(stamp.source, FP.point, FP.zero);
			}
			
			block.color = 0x004400;
			
			for (i = 0; i < count; i++) {
				FP.point.x = (i) * block.width;
				FP.point.y = 96;
				block.render(stamp.source, FP.point, FP.zero);
			}
			
			return stamp;
		}
		
		public static function makeWall(moving:Boolean, dx:int):Stamp
		{
			var sideHeight:int = FP.height + 64;
			
			if (moving) sideHeight *= 2;
			
			var stamp:Stamp = new Stamp(new BitmapData(32, sideHeight), 0, -64);
			
			if (dx > 0) stamp.x = FP.width - stamp.width;
			
			var i:int;
			
			block.color = 0xFF0000;
			
			FP.point.x = 0;
			FP.point.y = 0;
			while (FP.point.y < sideHeight) {
				block.render(stamp.source, FP.point, FP.zero);
				FP.point.y += 32;
			}
			
			return stamp;
		}
		
		public function Level (_doIntro:Boolean = false)
		{
			this.doIntro = _doIntro;
			
			if (Settings.shapeP1 == "random") {
				Settings.shapeP1 = FP.choose(Main.SHAPES);
				Settings.rotationP1 = FP.rand(4);
			}
			
			if (Settings.shapeP2 == "random") {
				Settings.shapeP2 = FP.choose(Main.SHAPES);
				Settings.rotationP1 = FP.rand(4);
			}
			
			add(p1 = new Settings.classP1(1, Settings.shapeP1, Settings.rotationP1));
			add(p2 = new Settings.classP2(-1, Settings.shapeP2, Settings.rotationP2));
			
			p1.enemy = p2;
			p2.enemy = p1;
			
			block.color = 0x00FF00;
			
			addGraphic(makeFloor());
			
			left = makeWall(Settings.movingSides, -1);
			right = makeWall(Settings.movingSides, 1);
			
			addGraphic(left);
			addGraphic(right);
			
			p1.makeHole(left.source);
			p2.makeHole(right.source);
			
			var vsSize:int = Settings.arcade ? 150 : 90;
			var introSize:int = Settings.arcade ? 60 : 30;
			var controlsSize:int = Settings.arcade ? 20 : 15;
			
			p1Intro = new Text("Yellow\n" + Settings.shapeP1 + "-Block", FP.width*0.5, 160, {size: introSize, align:"center"});
			p2Intro = new Text("Purple\n" + Settings.shapeP2 + "-Block", FP.width*0.5, 160, {size: introSize, align:"center"});
			vs = new Text("VS", FP.width*0.5, 160, {size: vsSize});
			p1Controls = new Text("Attack: D\n  Jump: " + (Settings.chargeJump ? "Hold " : "") + "S\n Block: A", FP.width*0.5, 240, {size:controlsSize});
			p2Controls = new Text("Attack: J\n  Jump: " + (Settings.chargeJump ? "Hold " : "") + "K\n Block: L", FP.width*0.5, 240, {size:controlsSize});
			
			if (Settings.arcade) {
				p1Controls.text = "Attack: RIGHT\n  Jump: UP\n Block: LEFT";
				p2Controls.text = "Attack: LEFT\n  Jump: UP\n Block: RIGHT";
				
				p1Controls.y += 150;
				p2Controls.y += 150;
			}
			
			var introOffset:int = Settings.arcade ? (vs.width + p1Intro.width)*0.5 + 30 : 140;
			
			p1Intro.x -= introOffset;
			p2Intro.x += introOffset;
			p1Controls.x -= introOffset;
			p2Controls.x += introOffset;
			
			p1Intro.centerOO();
			p2Intro.centerOO();
			vs.centerOO();
			p1Controls.centerOO();
			p2Controls.centerOO();
			
			FP.watch("touching", "width", "height", "dir");
			
			p1Intro.color = 0xFFFF00;
			p2Intro.color = 0xFF00FF;
			
			addGraphic(p1Intro, -10);
			addGraphic(p2Intro, -10);
			addGraphic(vs, -10);
			
			if (Settings.classP1 == HumanPlayer) addGraphic(p1Controls, -10);
			if (Settings.classP2 == HumanPlayer) addGraphic(p2Controls, -10);
			
			if (doIntro) {
				livesP1 = Settings.livesP1;
				livesP2 = Settings.livesP2;
				
				paused = true;
				
				var delay:int = 25;
			
				p1Intro.x -= FP.width*0.5 + 120;
				p2Intro.x += FP.width*0.5 + 120;
				vs.y -= 300;
				p1.y = -96;
				p2.y = -96;
			
				p1Controls.alpha = 0;
				p2Controls.alpha = 0;
			
				var world:World = this;
				
				FP.alarm(1      , function ():void {FP.tween(p1Intro, {x:FP.width*0.5-introOffset}, delay)});
				FP.alarm(delay  , function ():void {FP.tween(vs, {y: 160}, delay)});
				FP.alarm(delay*2, function ():void {FP.tween(p2Intro, {x:FP.width*0.5+introOffset}, delay)});
				FP.alarm(delay*3, function ():void {FP.tween(p1, {y:p1.floorY}, delay, {tweener:FP.tweener})});
				FP.alarm(delay*3, function ():void {FP.tween(p2, {y:p2.floorY}, delay, {tweener:FP.tweener})});
				FP.alarm(delay*4, function ():void {Audio.play("hit");paused = false; doIntro = false; shake = 8; FP.tween(world, {shake: 0}, delay*0.5)});
				
				FP.alarm(delay*4, function ():void {shake = 8; FP.tween(p1Controls, {alpha: 1}, delay*0.5)});
				FP.alarm(delay*4, function ():void {shake = 8; FP.tween(p2Controls, {alpha: 1}, delay*0.5)});
			}
		}
		
		public override function update (): void
		{
			if (paused && showCursor && ! Settings.arcade) {
				Input.mouseCursor = "auto";
			}
			
			if (buttonPressQuit && Input.pressed("anykey")) {
				FP.world = new Menu;
				return;
			}
			
			if (Input.pressed("1playermode") || Input.pressed("2playermode")) {
				FP.world = new Menu;
				return;
			}
			
			super.update(); // note: this doesn't do anything to players
			
			camera.x = (FP.random - 0.5)*shake;
			camera.y = (FP.random - 0.5)*shake;
			
			if (paused || ! FP.focused) {
				if (doIntro && Input.pressed(Key.ANY)) {
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
				p1.decide();
				p2.decide();
				
				p1.doMovement();
				p2.doMovement();
			
				p1.touching = p2.touching = (p1.collideWith(p2, p1.x, p1.y) != null);
			
				p1.doActions();
				p2.doActions();
			
				//p1.checkPosition();
				//p2.checkPosition();
			
				if (p1.x <= p1.width*0.5) {
					livesP1--;
				
					doGameover(-1);
				}
			
				if (p2.x >= FP.width - p2.width*0.5) {
					livesP2--;
				
					doGameover(1);
				}
			
				if (p1.collideWith(p2, p1.x, p1.y)) {
					p1.x -= 0.5;
					p2.x += 0.5;
				}
			}
			
			if (gameOver) {
				p1.action = null;
				p2.action = null;
				
				if (! p1.dead) p1.doMovement();
				if (! p2.dead) p2.doMovement();
			
				while (p1.collideWith(p2, p1.x, p1.y)) {
					if (! p1.dead) p1.x -= 1;
					if (! p2.dead) p2.x += 1;
				}
			}
			
			if (Settings.movingSides) {
				if (! p1.dead) left.y = Math.ceil(p1.y - p1.floorY - 64);
				if (! p2.dead) right.y = Math.ceil(p2.y - p2.floorY - 64);
			}
		}
		
		private function doGameover (side:int):void
		{
			Audio.play("death");
			
			p1.attacking = false;
			p1.blocking = false;
			p1.jumpAttacking = false;
			p2.attacking = false;
			p2.blocking = false;
			p2.jumpAttacking = false;
			
			paused = true;
			gameOver = true;
			
			var victor:Player = (side < 0) ? p2 : p1;
			var loser:Player = (side < 0) ? p1 : p2;
			
			if (! Settings.movingSides) {
				loser.y = loser.floorY;
			}
			
			loser.x = (side < 0) ? loser.width*0.5 : FP.width - loser.width*0.5;
			
			loser.dead = true;
			
			var x:Number = (side < 0) ? 0 : FP.width-32;
			
			var cover:Image = Image.createRect(32, FP.height, FP.screen.color);
			var e:Entity = addGraphic(cover, -20, x, 0);
			cover.alpha = 0;
			
			shake = 6;
			
			FP.tween(this, {shake: 0}, 15);
			
			var f:Function;
			
			if (livesP1 > 0 && livesP2 > 0) {
				f = function ():void {
					var newBlocks:Stamp = (side < 0) ? left : right;
					newBlocks.x = x + side*32;
					newBlocks.y = -64;
			
					FP.tween(newBlocks, {x: x}, 60, {complete:function ():void {
						FP.world = new Level;
					}});
			
					FP.rect.x = (side < 0) ? 0 : loser.width - 32;
					FP.rect.y = 0;
					FP.rect.width = 32;
					FP.rect.height = loser.height;
					loser.image.source.fillRect(FP.rect, 0x0);
					loser.image.updateBuffer();
			
					remove(e);
					
					FP.tween(victor, {x: victor.spawn, y: victor.floorY}, 60, {tweener: FP.tweener});
			
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
				
					FP.tween(victorName, {size:60, x:FP.width*0.5, y:120}, 30);
					
					//Input.mouseCursor = "auto";
				
					FP.alarm(30, function ():void {
						var wins:Text = new Text("WINS!", FP.width*0.5, 210, {size:50});
					
						wins.centerOO();
						wins.alpha = 0;
					
						addGraphic(wins, -10);
					
						FP.tween(wins, {alpha:1}, 30);
						
						var replay:Button = Menu.makeButton("Rematch?", function ():void {
							FP.world = new Level(true);
						});
						
						var menu:Button = Menu.makeButton("Menu", function ():void {
							FP.world = new Menu;
						});
						
						replay.y = 330;
						menu.y = 270;
						
						Image(replay.graphic).alpha = 0;
						Image(menu.graphic).alpha = 0;
						
						if (Settings.arcade) {
							var pressButton:Text = new Text("Press any button", 0, 0, {size: 40});
							
							pressButton.centerOO();
							pressButton.alpha = 0;
							
							addGraphic(pressButton, 0, FP.width*0.5, FP.height*0.5);
							
							goOff();
							
							function goOn():void {
								pressButton.alpha = 1;
								FP.alarm(30, goOff);
							}
							
							function goOff():void {
								pressButton.alpha = 0;
								FP.alarm(30, goOn);
							}
							
							buttonPressQuit = true;
						} else {
							add(replay);
							add(menu);
					
							FP.tween(replay.graphic, {alpha:1}, 30);
							FP.tween(menu.graphic, {alpha:1}, 30);
						
							showCursor = true;
						}
					});
				
					FP.tween(loser.image, {alpha: 0}, 60);
				}
			}
			
			FP.alarm(15, function ():void {
				FP.tween(cover, {alpha: 1}, 30, {complete:f});
			});
		}
		
		public override function render (): void
		{
			super.render();
		}
		
		public override function begin ():void
		{
			Input.mouseCursor = "hide";
			Audio.startMusic();
		}
		
		public override function end ():void
		{
			Input.mouseCursor = "auto";
		}
	}
}

