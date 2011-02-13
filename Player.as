package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Player extends Entity
	{
		public var blocking:Boolean = false;
		public var attacking:Boolean = false;
		public var jumpAttacking:Boolean = false;
		public var touching:Boolean = false;
		
		// use these to differentiate blocks?
		//public var speed:Number = 4;
		//public var power:Number = 4;
		
		public var dir:int; // 1 = moving right, -1 = moving left
		
		public var spawn:Number = 0;
		
		public var attackSpeed:Number = 4;
		public var walkSpeed:Number = 0;
		public var retreatSpeed:Number = 1;
		
		public var attackKey:uint;
		public var blockKey:uint;
		
		public var jumpTimer:int;
		public var maxJumpTimer:int = 45;
		
		public var enemy:Player;
		
		public var color:uint;
		
		public var vx:Number = 0;
		public var vy:Number = 0;
		
		public var floorY:Number = 480 - 128;
		public var gravity:Number = 0.1;
		
		public var image:Image;
		
		[Embed(source="block.png")]
		public static const BlockGfx: Class;
		
		public var playedSound:Boolean = false;
		
		public function Player (_dir:int)
		{
			dir = _dir;
			
			if (dir > 0) {
				attackKey = Key.Z;
				blockKey = Key.A;
				
				color = 0xFFFF00;
			} else {
				attackKey = Key.M;
				blockKey = Key.K;
				
				color = 0xFF00FF;
			}
			
			image = new Image(BlockGfx);
			image.color = color;
			
			setHitbox(64, 64, 32, 0);
			
			type = "player";
			
			y = floorY;
			x = spawn = 320 - dir*(640 - width*8);
			
			layer = -10;
		}
		
		public function doMovement (): void
		{
			playedSound = false;
			
			blocking = Input.check(blockKey);
			attacking = false;
			jumpAttacking = false;
			
			if (y < floorY || vy < 0) {
				jumpTimer = 0;
				
				vy += gravity;
				
				x += vx * dir;
				y += vy;
				
				if (vx > 0) {
					attacking = true;
					jumpAttacking = true;
				}
				
				if (y >= floorY) {
					y = floorY;
				} else {
					return;
				}
			}
			
			attacking = Input.check(attackKey);
			
			if (! blocking || !attacking) {
				jumpTimer = 0;
			
				y += (floorY - y)*0.1;
			}
			
			if (blocking && attacking) {
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
			} else if (blocking) {
				x -= dir*retreatSpeed;
			} else if (attacking) {
				x += dir*attackSpeed;
			} else {
				x += dir*walkSpeed;
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
				} else if (enemy.attacking) {
					vx = -attackSpeed*0.5;
					vy = -1.5;
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
			FP.point.x = x - 32;
			FP.point.y = y;
			image.render(FP.buffer, FP.point, FP.camera);
			FP.point.x = x - 32;
			FP.point.y = y + 32;
			image.render(FP.buffer, FP.point, FP.camera);
			FP.point.x = x;
			FP.point.y = y + 32;
			image.render(FP.buffer, FP.point, FP.camera);
		}
	}
}

