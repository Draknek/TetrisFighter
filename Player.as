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
		public var health:Number = maxHealth;
		public var maxHealth:Number = 100;
		
		public var enemy:Player;
		
		public var color:uint;
		
		public var vx:Number = 0;
		public var vy:Number = 0;
		
		public var floorY:Number = 480 - 128;
		public var gravity:Number = 0.1;
		
		[Embed(source="block.png")]
		public static const BlockGfx: Class;
		
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
			
			for (var i:int = 0; i < 4; i++) {
				var img:Image = new Image(BlockGfx);
				img.x = (i < 2) ? 0 : img.width;
				img.y = (i % 2) ? 0 : img.height;
				img.color = color;
				addGraphic(img);
			}
			
			//graphic = Image.createRect(50, 50, 0xFF0000);
			
			setHitbox(64, 64);
			
			type = "player";
			
			y = floorY;
			x = spawn = 320 - dir*(320 - width) - width;
			
			layer = -10;
		}
		
		public function doMovement (): void
		{
			blocking = Input.check(blockKey);
			attacking = false;
			
			if (y < floorY || vy < 0) {
				vy += gravity;
				
				x += vx * dir;
				y += vy;
				
				if (y >= floorY) {
					y = floorY;
				} else {
					return;
				}
			}
			
			if (stunTimer > 0) {
				stunTimer--;
				
				return;
			}
			
			attacking = Input.check(attackKey);
			
			var oldX:Number = x;
			
			if (blocking) {
				x -= dir*retreatSpeed;
			} else if (attacking) {
				x += dir*attackSpeed;
			} else {
				x += dir*walkSpeed;
			}
			
			if (x < width) x = width;
			if (x > FP.width - width*2) x = FP.width - width*2;
		}
		
		public function doActions (): void
		{
			if (attacking && touching) {
				if (enemy.attacking) {
					//x -= 80*dir;
					//stunTimer = 60;
					
					vx = -attackSpeed*0.5;
					vy = -1.5;
				} else if (enemy.blocking) {
					//x -= 40*dir;
					//stunTimer = 40;
					
					vx = -attackSpeed*0.5;
					vy = -1.5;
				} else {
					//enemy.x += 1*dir;
					//enemy.stunTimer = 40;
					enemy.health -= 10;
					
					
					enemy.vx = -attackSpeed - 1;
					enemy.vy = -1.5;
				}
			}
		}
		
		public function checkPosition ():void
		{
			if (x < 0) x = 0;
			if (x > FP.width - width) x = FP.width - width;
		}
		
		/*public override function render ():void
		{
			var t:Number = stunTimer / 20.0;
			
			var c:uint = FP.colorLerp(color, 0xFF0000, t);
			
			image.color = c;
			
			return;
			
			Draw.rect(x+5, y-15, width-10, 10, 0xFFFFFF);
			Draw.rect(x+7, y-13, width-14, 6, 0x000000);
			
			t = health/maxHealth;
			
			c = FP.colorLerp(0xFF0000, 0x00FF00, t);
			
			Draw.rect(x+7, y-13, (width-14)*t, 6, c);
		}*/
	}
}

