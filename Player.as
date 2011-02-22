package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
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
		
		public var floorY:Number = 480 - 64;
		public var gravity:Number = 0.1;
		
		public var image:Image;
		
		[Embed(source="block.png")]
		public static const BlockGfx: Class;
		
		public var lifeImage:Image = new Image(LifeGfx);
		
		[Embed(source="life.png")]
		public static const LifeGfx: Class;
		
		public var playedSound:Boolean = false;
		
		public var shape:String;
		
		public function Player (_dir:int, _shape:String, rotation:int = 0)
		{
			dir = _dir;
			shape = _shape;
			
			if (dir > 0) {
				color = 0xFFFF00;
			} else {
				color = 0xFF00FF;
			}
			
			image = new Image(Main.makeShape(shape, BlockGfx));
			image.color = color;
			image.originX = 32;
			image.originY = 64;
			
			setHitbox(64, 64, 32, 64);
			
			type = "player";
			
			y = floorY;
			x = spawn = 320 - dir*(640 - width*8);
			
			layer = -10;
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
				if (! enemy.playedSound) {
					Audio.play("hit");
					playedSound = true;
				}
				
				if (jumpAttacking) {
					if (Settings.chargeJump) {
						if (enemy.jumpAttacking) {
							vx = -attackSpeed*0.25;
							vy = -1.0;
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
						} else if (enemy.blocking) {
							enemy.vx = -attackSpeed * 0.75;
							enemy.vy = -2.5;
						
							vx *= 0.5;
						} else if (!enemy.attacking) {
							enemy.vx = -attackSpeed * 1.25;
							enemy.vy = -2.5;
						}
					}
				} else if (enemy.attacking) {
					if (!Settings.chargeJump && enemy.jumpAttacking) {
						enemy.vx = -attackSpeed * 1.1;
						enemy.vy = -2.5;
					} else {
						vx = -attackSpeed*0.5;
						vy = -1.5;
					}
				} else if (enemy.blocking) {
					vx = -attackSpeed*0.5;
					vy = -2.0;
				} else {
					enemy.vx = -attackSpeed * 1.5;
					enemy.vy = -1.5;
				}
			}
		}
		
		public override function render ():void
		{
			var t:Number = jumpTimer / maxJumpTimer;
		
			image.color = FP.colorLerp(color, 0xFF0000, t);
			
			FP.point.x = x;
			FP.point.y = y;
			image.render(FP.buffer, FP.point, FP.camera);
			
			if (jumpAttacking || attacking) {
				Draw.rectPlus(x - 32, y - 64, 64, 64, 0xFF0000, image.alpha, false, 1.0);
			} else if (blocking) {
				Draw.rectPlus(x - 32, y - 64, 64, 64, 0xFFFFFF, image.alpha, false, 1.0);
			}
			
			lifeImage.centerOO();
			
			var lives:int = (Level(world).p1 == this) ? Level.livesP1 : Level.livesP2;
			
			for (var i:int = 0; i < lives; i++) {
				FP.point.x = 320 - (320 - 32 - 16)*dir;
				FP.point.y = 16 + i*32;
				lifeImage.render(FP.buffer, FP.point, FP.camera);
			}
			
		}
		
		public function makeHole (b:BitmapData):void
		{
			FP.rect.x = 0;
			FP.rect.y = 480 - 128 + 64;
			FP.rect.width = b.width;
			FP.rect.height = 64;
			b.fillRect(FP.rect, FP.screen.color);
		}
	}
}

