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
		public var touching:Boolean = false;
		
		// use these to differentiate blocks?
		//public var speed:Number = 4;
		//public var power:Number = 4;
		
		public var dir:int; // 1 = moving right, -1 = moving left
		
		public var spawn:Number = 0;
		
		public var attackSpeed:Number = 6;
		public var walkSpeed:Number = 0;
		public var retreatSpeed:Number = 2;
		
		public var attackKey:uint;
		public var blockKey:uint;
		
		public var stunTimer:int;
		
		public var enemy:Player;
		
		public function Player (_dir:int)
		{
			dir = _dir;
			
			if (dir > 0) {
				attackKey = Key.Z;
				blockKey = Key.A;
			} else {
				attackKey = Key.M;
				blockKey = Key.K;
			}
			
			y = 400;
			x = spawn = 320 - dir*250 - 25;
			
			graphic = Image.createRect(50, 50, 0xFF0000);
			
			setHitbox(50, 50);
			
			type = "player";
		}
		
		public function doMovement (): void
		{
			blocking = Input.check(blockKey);
			attacking = Input.check(attackKey);
			
			if (stunTimer > 0) {
				stunTimer--;
				return;
			}
			
			var oldX:Number = x;
			
			if (blocking) {
				x -= dir*retreatSpeed;
			} else if (attacking) {
				x += dir*attackSpeed;
			} else {
				x += dir*walkSpeed;
			}
			
			if (x < 0) x = 0;
			if (x > FP.width - width) x = FP.width - width;
		}
		
		public function doActions (): void
		{
			if (attacking && touching) {
				if (enemy.attacking) {
					x -= 50*dir;
					
					stunTimer = 10;
				} else if (enemy.blocking) {
					x -= 20*dir;
				
					stunTimer = 20;
				}
			}
		}
	}
}

