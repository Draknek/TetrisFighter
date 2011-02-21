package
{
	import net.flashpunk.*;
	import net.flashpunk.utils.*;
	
	public class OppositeAI extends Player
	{
		public var timer:int = 0;
		
		public function OppositeAI (_dir:int, _shape:String, _rotation:int = 0)
		{
			super(_dir, _shape, _rotation);
		}
		
		public override function decide ():void
		{
			if (timer <= 0) {
				var dx:Number = dir * (enemy.x - x) - 64;
				
				if (dx > 80) {
					var p:Number = 0.5 * Math.min((dx - 48) / 48, 1.0);
					
					action = (FP.random < p) ? "jump" : "attack";
					if (action == "jump") timer = 60;
					else timer = FP.rand(20) + 10;
					return;
				}
				
				if (enemy.attacking) {
					if (y < floorY && !action) action = FP.choose("block", null);
					else action = "block";
					timer = FP.rand(15) + 15;
					return;
				}
				
				if (enemy.blocking) {
					action = FP.choose(null, null, "attack");
					timer = FP.rand(5) + 5;
					return;
				}
				
				action = "attack";
				timer = FP.rand(60) + 20;
			}
			
			timer--;
		}
	}
}
