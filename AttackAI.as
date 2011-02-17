package
{
	import net.flashpunk.utils.*;
	
	public class AttackAI extends Player
	{
		public function AttackAI (_dir:int, _shape:String, _rotation:int = 0)
		{
			super(_dir, _shape, _rotation);
		}
		
		public override function decide ():void
		{
			action = "attack";
		}
	}
}
