package
{
	import net.flashpunk.utils.*;
	
	public class HumanPlayer extends Player
	{
		public var playerID:int;
		
		public function HumanPlayer (_dir:int, _shape:String, _rotation:int = 0)
		{
			super(_dir, _shape, _rotation);
			
			if (dir > 0) {
				playerID = 1;
			} else {
				playerID = 2;
			}
		}
		
		public override function decide ():void
		{
			var a:Boolean = Input.check("attack" + playerID);
			var b:Boolean = Input.check("block" + playerID);
			var c:Boolean = Input.check("jump" + playerID);
			
			if (int(a) + int(b) + int(c) > 1) {
				action = null;
			} else if (a) {
				action = "attack";
			} else if (b) {
				action = "block";
			} else if (c) {
				action = "jump";
			} else {
				action = null;
			}
		}
	}
}
