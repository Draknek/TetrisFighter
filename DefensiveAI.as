package
{
	import net.flashpunk.*;
	import net.flashpunk.utils.*;
	
	public class DefensiveAI extends Player
	{
		public var timer:int = 0;
		
		public function DefensiveAI (_dir:int, _shape:String, _rotation:int = 0)
		{
			super(_dir, _shape, _rotation);
			
			timer = 15 + FP.rand(15);
			action = null;
		}
		
		public override function decide ():void
		{
			if (timer <= 0) {
				var dx:Number = dir * (enemy.x - x) - width*0.5 - enemy.width*0.5;
				var lx:Number = (dir > 0) ? x : 640 - x;
				
				if (dx < 64 && enemy.attacking && ! enemy.jumpAttacking) action = "block";
				else if (dx > 32 && dx < 128  && ! enemy.attacking && FP.random < 0.3) action = "jump";
				else action = "attack";
				
				timer = FP.rand(15) + 10;
			}
			
			if (y < floorY) {
				action = null;
				timer = 0
			}
			
			timer--;
		}
	}
}
