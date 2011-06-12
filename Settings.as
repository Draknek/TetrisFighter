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
		public static var arcadeControls:Boolean = false;
		
		public static function init ():void
		{
			if (Main.host) {
				classP2 = classAI;
			} else {
				classP2 = HumanPlayer;
			}
			
			Input.define("attack1", Key.D);
			Input.define("jump1", Key.S);
			Input.define("block1", Key.A);
		
			Input.define("attack2", Key.J);
			Input.define("jump2", Key.K);
			Input.define("block2", Key.L);
			
			if (arcade) {
				if (arcadeControls) {
					Input.define("attack1", Key.RIGHT);
					Input.define("jump1", Key.UP);
					Input.define("block1", Key.LEFT);
			
					Input.define("attack2", Key.J);
					Input.define("jump2", Key.I);
					Input.define("block2", Key.L);
				}
				
				Input.define("leftP1", Key.LEFT);
				Input.define("rightP1", Key.RIGHT);
				Input.define("upP1", Key.UP);
				Input.define("downP1", Key.DOWN);
				Input.define("actionP1", Key.Z, Key.X, Key.C);
				
				Input.define("leftP2", Key.J);
				Input.define("rightP2", Key.L);
				Input.define("upP2", Key.I);
				Input.define("downP2", Key.K);
				Input.define("actionP2", Key.B, Key.N, Key.M);
				
				Input.define("1playermode", Key.DIGIT_1);
				Input.define("2playermode", Key.DIGIT_2);
				
				Input.define("anykey", Key.DIGIT_1, Key.DIGIT_2, Key.Z, Key.X, Key.C, Key.B, Key.N, Key.M);
			}
		}
	}
}

