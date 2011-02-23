package
{
	import net.flashpunk.*;
	import net.flashpunk.utils.*;
	
	public class SimpleAI extends Player
	{
		public var timer:int = 0;
		
		public function SimpleAI (_dir:int, _shape:String, _rotation:int = 0)
		{
			super(_dir, _shape, _rotation);
		}
		
		public override function decide ():void
		{
			if (timer <= 0) {
				var dx:Number = dir * (enemy.x - x) - 64;
				var lx:Number = (dir > 0) ? x : 640 - x;
				
				if (lx < 160 && dx < 96) {
					if (enemy.blocking) action = "jump";
					else if (enemy.attacking) action = "block";
					else if (enemy.jumpAttacking) action = "attack";
					else action = FP.choose("jump", "attack", "attack", "attack");
				}
				else action = FP.choose("jump", "attack", "attack", "attack", "block");
				
				if (lx < 64) action = FP.choose("jump", "attack", "attack");
				
				timer = FP.rand(20) + 10;
			}
			
			if (y < floorY) {
				action = null;
				timer = 0
			}
			
			timer--;
		}
	}
}
