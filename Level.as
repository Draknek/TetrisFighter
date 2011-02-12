package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Level extends World
	{
		//[Embed(source="images/bg.png")] public static const BgGfx: Class;
		
		public var p1:Player;
		public var p2:Player;
		
		public function Level ()
		{
			add(p1 = new Player(1));
			add(p2 = new Player(-1));
			
			p1.enemy = p2;
			p2.enemy = p1;
			
			addGraphic(new Text("Attack: A\nBlock: Z", 10, 350));
			addGraphic(new Text("Attack: M\nBlock: K", 0, 350, {width:630, align:"right"}));
		}
		
		public override function update (): void
		{
			// super.update(); // calling everything manually for the time being
			
			p1.doMovement();
			p2.doMovement();
			
			p1.touching = p2.touching = (p1.collideWith(p2, p1.x, p1.y) != null);
			
			p1.doActions();
			p2.doActions();
			
			while (p1.collideWith(p2, p1.x, p1.y)) {
				p1.x -= 0.5;
				p2.x += 0.5;
			}
		}
		
		public override function render (): void
		{
			super.render();
		}
	}
}

