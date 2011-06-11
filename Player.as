package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	public class Player extends Entity
	{
		public var blocking:Boolean = false;
		public var attacking:Boolean = false;
		public var charging:Boolean = false;
		public var jumpAttacking:Boolean = false;
		public var touching:Boolean = false;
		public var action:String;
		
		public var dead:Boolean = false;
		
		// use these to differentiate blocks?
		//public var speed:Number = 4;
		//public var power:Number = 4;
		
		public var dir:int; // 1 = moving right, -1 = moving left
		
		public var spawn:Number = 0;
		
		public var attackSpeed:Number = 4;
		public var walkSpeed:Number = 0;
		public var retreatSpeed:Number = 1;
		
		public var jumpTimer:int;
		public var maxJumpTimer:int = 45;
		
		public var enemy:Player;
		
		public var color:uint;
		
		public var vx:Number = 0;
		public var vy:Number = 0;
		
		public var floorY:Number = FP.height - (Settings.arcade ? 128 : 64);
		public var gravity:Number = 0.1;
		
		public var image:Image;
		
		[Embed(source="block.png")]
		public static const BlockGfx: Class;
		
		public var lifeImage:Image = new Image(LifeGfx);
		
		[Embed(source="life.png")]
		public static const LifeGfx: Class;
		
		public var playedSound:Boolean = false;
		
		public var shape:String;
		public var outline:Image;
		
		public function Player (_dir:int, _shape:String, rotation:int = 0)
		{
			dir = _dir;
			shape = _shape;
			
			if (shape == "random") shape = FP.choose(Main.SHAPES);
			
			if (dir > 0) {
				color = 0xFFFF00;
			} else {
				color = 0xFF00FF;
			}
			
			var shapeBitmap:BitmapData = Main.makeShape(shape, rotation, BlockGfx)
			
			image = new Image(shapeBitmap);
			image.color = color;
			image.originX = image.width*0.5;
			image.originY = image.height;
			
			var outlinePoints:Array = new Outline(shapeBitmap).points;
			var outlineBitmap:BitmapData = new BitmapData(image.width, image.height, true, 0x0);
			FP.rect.width = 3;
			FP.rect.height = 3;
			for each (var p:Point in outlinePoints) {
				FP.rect.x = p.x - 1;
				FP.rect.y = p.y - 1;
				outlineBitmap.fillRect(FP.rect, 0xFFFFFFFF);
				//outlineBitmap.setPixel32(p.x, p.y, 0xFFFFFFFF);
			}
			
			outlineBitmap.threshold(shapeBitmap, shapeBitmap.rect, FP.zero, "==", 0x0, 0x0);
			
			outline = new Image(outlineBitmap);
			outline.originX = image.width*0.5;
			outline.originY = image.height;
			
			//setHitbox(64, 64, 32, 64);
			
			mask = new Pixelmask(shapeBitmap);//Main.makeShape(shape, {width: 32, height: 32});
			
			Hitbox(mask).x = -width*0.5;
			Hitbox(mask).y = -height;
			
			type = "player";
			
			y = floorY;
			x = spawn = FP.width*0.5 - dir*(640 - 64*8);
			
			layer = -11;
		}
		
		public function decide ():void {}
		
		public function doMovement (): void
		{
			playedSound = false;
			
			blocking = (action == "block");
			attacking = false;
			jumpAttacking = false;
			charging = false;
			
			if (y < floorY || vy < 0) {
				jumpTimer = 0;
				
				vy += gravity;
				
				x += vx * dir;
				y += vy;
				
				if (vx > 0) {
					attacking = true;
					jumpAttacking = true;
					blocking = false;
				}
				
				if (y >= floorY) {
					y = floorY;
				} else {
					return;
				}
			}
			
			attacking = (action == "attack");
			charging = (action == "jump");
			
			if (int(charging) + int(attacking) + int(blocking) > 1) {
				charging = false;
				attacking = false;
				blocking = false;
			}
			
			if (Settings.chargeJump) {
				if (! charging) {
					jumpTimer = 0;
			
					y += (floorY - y)*0.1;
				}
			
				if (charging) {
					jumpTimer++;
				
					if (jumpTimer > maxJumpTimer) {
						vy = -3.0;
						vx = attackSpeed*1.0;
						jumpAttacking = true;
						jumpTimer = 0;
					}
				
					if (jumpTimer % 15 == 0) {
						x -= 1*dir;
						y += 1;
					}
				
					blocking = false;
					attacking = false;
				}
			} else {
				if (charging) {
					vy = -2.0;
					vx = attackSpeed*1.0;
					jumpAttacking = true;
					charging = false;
				}
			}
			
			if (blocking) {
				x -= dir*retreatSpeed;
			} else if (attacking) {
				x += dir*attackSpeed;
			}
			
			//if (x < width) x += 1;
			//if (x > FP.width - width*2) x -= 1;
		}
		
		public function doActions (): void
		{
			if (attacking && touching) {
				var sound:String = "hit";
				
				if (jumpAttacking) {
					if (Settings.chargeJump) {
						if (enemy.jumpAttacking) {
							vx = -attackSpeed*0.25;
							vy = -1.0;
							sound = "block";
						} else if (enemy.blocking) {
							enemy.vx = -attackSpeed * 0.75;
							enemy.vy = -2.5;
						
							vx *= 0.5;
						} else {
							enemy.vx = -attackSpeed * 1.25;
							enemy.vy = -2.5;
						}
					} else {
						if (enemy.jumpAttacking) {
							vx = -attackSpeed*0.5;
							vy -= 2.0;
							sound = "block";
						} else if (enemy.blocking) {
							enemy.vx = -attackSpeed * 0.75;
							enemy.vy = -2.5;
						
							vx *= 0.25;
						} else if (!enemy.attacking) {
							enemy.vx = -attackSpeed * 1.25;
							enemy.vy = -2.5;
							
							vx *= 0.75;
						}
					}
				} else if (enemy.attacking) {
					if (!Settings.chargeJump && enemy.jumpAttacking) {
						enemy.vx = -attackSpeed * 0.75;
						enemy.vy = -2.5;
						
						vy = -1.0;
						vx = -1.0;
					} else {
						vx = -attackSpeed*0.5;
						vy = -1.5;
						sound = "block";
					}
				} else if (enemy.blocking) {
					vx = -attackSpeed*0.5;
					vy = -2.0;
					sound = "block";
				} else {
					enemy.vx = -attackSpeed * 1.5;
					enemy.vy = -1.5;
				}
				
				if (! enemy.playedSound) {
					
					Audio.play(sound);
					playedSound = true;
				}
			}
		}
		
		public override function render ():void
		{
			lifeImage.centerOO();
			
			var lives:int = (Level(world).p1 == this) ? Level.livesP1 : Level.livesP2;
			
			for (var i:int = 0; i < lives; i++) {
				FP.point.x = FP.width*0.5 - (FP.width*0.5 - 32 - 16 - int(i/10)*32)*dir;
				FP.point.y = 16 + (i%10)*32;
				lifeImage.render(FP.buffer, FP.point, FP.camera);
			}
			
			var t:Number = jumpTimer / maxJumpTimer;
		
			image.color = FP.colorLerp(color, 0xFF0000, t);
			
			FP.point.x = x;
			FP.point.y = y;
			image.render(FP.buffer, FP.point, FP.camera);
			
			if (jumpAttacking || attacking) {
				outline.color = 0xFF0000;
				outline.render(FP.buffer, FP.point, FP.camera);
			} else if (blocking) {
				outline.color = 0xFFFFFF;
				outline.render(FP.buffer, FP.point, FP.camera);
			}
			
		}
		
		public function makeHole (b:BitmapData):void
		{
			var alpha:BitmapData = image.source;
			
			var cover:BitmapData = new BitmapData(alpha.width, alpha.height, false, FP.screen.color);
			
			FP.point.x = (dir > 0) ? 0 : 32 - alpha.width;
			FP.point.y = FP.height - alpha.height;
			
			if (Settings.arcade) FP.point.y -= 64;
			
			b.copyPixels(cover, cover.rect, FP.point, alpha, FP.zero, true);
		}
	}
}

