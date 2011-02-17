package
{
	import net.flashpunk.utils.*;
	
	public class HumanPlayer extends Player
	{
		public var attackKey:uint;
		public var blockKey:uint;
		public var jumpKey:uint;
		
		public function HumanPlayer (_dir:int, _shape:String, _rotation:int = 0)
		{
			super(_dir, _shape, _rotation);
			
			if (dir > 0) {
				attackKey = Key.D;
				jumpKey = Key.S;
				blockKey = Key.A;
			} else {
				attackKey = Key.J;
				jumpKey = Key.K;
				blockKey = Key.L;
			}
		}
		
		public override function decide ():void
		{
			var a:Boolean = Input.check(attackKey);
			var b:Boolean = Input.check(blockKey);
			var c:Boolean = Input.check(jumpKey);
			
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
