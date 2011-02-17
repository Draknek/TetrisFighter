package
{
	import net.flashpunk.*;
	import net.flashpunk.utils.*;
	
	public class RandomAI extends Player
	{
		public var timer:int = 0;
		
		public function RandomAI (_dir:int, _shape:String, _rotation:int = 0)
		{
			super(_dir, _shape, _rotation);
		}
		
		public override function decide ():void
		{
			if (timer <= 0) {
				action = FP.choose("attack", "block", "jump");
				
				if (action == "jump") {
					timer = 60;
				} else {
					timer = FP.rand(30)+20;
				}
			}
			
			timer--;
		}
	}
}
