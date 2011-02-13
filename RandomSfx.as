package
{
	import net.flashpunk.*;
	
	public class RandomSfx
	{
		public var sounds:Array = [];
		
		public function RandomSfx(list:Array) 
		{
			for each (var s:* in list) {
				sounds.push(new Sfx(s));
			}
		}
		
		public function play():void
		{
			FP.choose(sounds).play();
		}
	}
}
