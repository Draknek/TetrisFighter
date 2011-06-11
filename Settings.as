package
{
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	
	public class Settings
	{
		public static var livesP1:int = 5;
		public static var livesP2:int = 5;
		
		public static var classAI:Class = DefensiveAI;
		
		public static var classP1:Class = HumanPlayer;
		public static var classP2:Class = HumanPlayer;
		
		public static var shapeP1:String = "random";
		public static var shapeP2:String = "random";
		
		public static var menuShapeP1:String = null;
		public static var menuShapeP2:String = null;
		
		public static var rotationP1:int = 0;
		public static var rotationP2:int = 0;
		
		public static var menuRotationP1:int = 0;
		public static var menuRotationP2:int = 0;
		
		public static var movingSides:Boolean = true;
		
		public static var chargeJump:Boolean = false;
		
		public static var arcade:Boolean = true;
		
		public static function init ():void
		{
			if (Main.host) {
				classP2 = classAI;
			} else {
				classP2 = HumanPlayer;
			}
			
			if (arcade) {
				Input.define("attack1", Key.RIGHT);
				Input.define("jump1", Key.UP);
				Input.define("block1", Key.LEFT);
			
				Input.define("attack2", Key.J);
				Input.define("jump2", Key.I);
				Input.define("block2", Key.L);
				
				Input.define("left1", Key.LEFT);
				Input.define("right1", Key.RIGHT);
				Input.define("up1", Key.UP);
				Input.define("down1", Key.DOWN);
				Input.define("action1", Key.Z, Key.X, Key.C);
				
				Input.define("left2", Key.J);
				Input.define("right2", Key.L);
				Input.define("up2", Key.I);
				Input.define("down2", Key.K);
				Input.define("action2", Key.B, Key.N, Key.M);
				
				Input.define("1playermode", Key.DIGIT_1);
				Input.define("2playermode", Key.DIGIT_2);
			} else {
				Input.define("attack1", Key.D);
				Input.define("jump1", Key.S);
				Input.define("block1", Key.A);
			
				Input.define("attack2", Key.J);
				Input.define("jump2", Key.K);
				Input.define("block2", Key.L);
			}
		}
	}
}

