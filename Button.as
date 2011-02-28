package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Button extends Entity
	{
		public var normalGraphic:Graphic;
		public var hoverGraphic:Graphic;
		
		public var noCamera:Boolean = false;
		public var callback:Function;
		
		public var normalLayer:int = -20;
		public var hoverLayer:int = -21;
		
		public function Button (_x:int, _y:int, _gfx1:*, _gfx2:*, _callback:Function)
		{
			x = _x;
			y = _y;
			
			layer = normalLayer;
			
			if (! (_gfx1 is Graphic)) _gfx1 = new Image(_gfx1);
			if (! (_gfx2 is Graphic)) _gfx2 = new Image(_gfx2);
			
			normalGraphic = _gfx1;
			hoverGraphic = _gfx2;
			
			graphic = normalGraphic;
			
			setHitbox(_gfx1.width, _gfx1.height);
			
			type = "button";
			
			callback = _callback;
		}
		
		public override function update (): void
		{
			if (!world) return;
			
			var _x:Number = x;
			var _y:Number = y;
			
			if (noCamera) {
				_x += FP.camera.x;
				_y += FP.camera.y;
			}
			
			var over:Boolean = collidePoint(_x, _y, world.mouseX, world.mouseY);
			
			if (over) {
				Input.mouseCursor = "button";
				layer = hoverLayer;
			} else {
				layer = normalLayer;
			}
			
			graphic = (over) ? hoverGraphic : normalGraphic;
			
			if (over && Input.mousePressed && callback != null) {
				callback();
			}
		}
		
		public override function render (): void
		{
			graphic.scrollX = noCamera ? 0 : 1;
			graphic.scrollY = noCamera ? 0 : 1;
			
			super.render();
		}
		
	}
}

