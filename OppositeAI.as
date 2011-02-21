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
				
				if (dx > 128) {
					action = FP.choose("jump", "attack");
					if (action == "jump") timer = 60;
					else timer = FP.rand(20) + 30;
					return;
				}
				
				if (dx > 64) {
					action = "attack";
					timer = FP.rand(30) + 10;
					return;
				}
				
				if (enemy.attacking) {
					action = FP.choose("block", "attack");
					timer = FP.rand(15) + 15;
					return;
				}
				
				if (enemy.blocking) {
					action = FP.choose(null, "attack");
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
