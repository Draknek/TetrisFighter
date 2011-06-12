package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.text.*;
	import flash.system.*;
	
	public class Menu extends World
	{
		[Embed(source="block-small.png")] public static const SmallBlockGfx: Class;
		[Embed(source="random.png")] public static const RandomGfx: Class;
		[Embed(source="images/arrows.png")] public static const ArrowGfx: Class;
		[Embed(source="images/rotate.png")] public static const RotateGfx: Class;
		
		[Embed(source = 'fonts/MODENINE.TTF', embedAsCFF="false", fontFamily = 'modenine')]
		public static const ModeNineFont:Class;
		
		public var padding1:int = 8;
		public var paddingA:int = 0;
		public var paddingB:int = 10;
		public var size1:int = 64+padding1;
		public var size2:int = size1*3+paddingA*2+paddingB*2;
		
		public var padding2:int = (FP.width - 64 - size2*2)/3;
		
		public var x1:int = 32+padding2;
		public var x2:int = FP.width - 32 - padding2 - size2;
		public var yBlock:int = 100;
		public var yText:int = 96;
		
		public var fightButton:Button;
		public var fightText:Text;
		
		public var credits:Sprite = new Sprite;
		
		public var controls1:Button;
		public var controls2:Button;
		
		public var selectedP1:Entity;
		public var selectedP2:Entity;
		
		public var buttonsP1:Array = [];
		public var buttonsP2:Array = [];
		
		public function Menu ()
		{
			var css1:String = 'a:hover { text-decoration: underline; } \
					a { text-decoration: none; color: #FFFF00; }';
			var css2:String = 'a:hover { text-decoration: underline; } \
					a { text-decoration: none; color: #FF00FF; }';
			
			var scale:int = Settings.arcade ? 2 : 1;
			
			var alan:TextField = makeHTMLText(
				'Established by <a href="http://www.draknek.org/" target="_blank">Alan Hazelden</a>',
				Settings.arcade ? 20 : 15, 0xFFFFFF, css1
			);
			
			var paul:TextField = makeHTMLText(
				'Musically enlivened by <a href="http://runtime-audio.co.uk/" target="_blank">Paul Forey</a>',
				Settings.arcade ? 20 : 15, 0xFFFFFF, css2
			);
			
			credits.addChild(alan);
			credits.addChild(paul);
			
			alan.x = (FP.width - alan.width)*0.5;
			paul.x = (FP.width - paul.width)*0.5;
			
			alan.y = -2;
			paul.y = 15*scale;
			
			credits.x = FP.screen.x;
			credits.y = 60*scale;
			
			if (Settings.arcade) {
				yBlock = 240;
			}
			
			addGraphic(Level.makeFloor());
			
			addGraphic(Level.makeWall(false, -1));
			addGraphic(Level.makeWall(false, 1));
			
			var title:Text = new Text("TETRIS FIGHT CLUB", 0, 0, {size: 40*scale});
			
			title.x = (FP.width - title.width)*0.5;
			title.y = 14;
			
			addGraphic(title);
			
			addGraphic(new Stamp(Main.makeBlock(size2, size2)), 0, x1, yBlock);
			addGraphic(new Stamp(Main.makeBlock(size2, size2)), 0, x2, yBlock);
			
			var p1:Text = new Text("P1", 0, 0, {size:40, color:0x0});
			var p2:Text = new Text("P2", 0, 0, {size:40, color:0x0});
			p1.centerOO();
			p2.centerOO();
			addGraphic(p1, -1, x1+size2*0.5, yBlock+size2*0.5-5);
			addGraphic(p2, -1, x2+size2*0.5, yBlock+size2*0.5-5);
			
			var humanNormal:Text = new Text("Human", size1*0.5, size1*0.5 + p1.height*0.5	, {size:20, color:0x0});
			var humanHover:Text = new Text("Human", size1*0.5, size1*0.5 + p1.height*0.5, {size:20, color:0xFF0000});
			
			var computerNormal:Text = new Text("AI", size1*0.5, size1*0.5 + p1.height*0.5, {size:20, color:0x0});
			var computerHover:Text = new Text("AI", size1*0.5, size1*0.5 + p1.height*0.5, {size:20, color:0xFF0000});
			
			humanNormal.centerOO();
			humanHover.centerOO();
			computerNormal.centerOO();
			computerHover.centerOO();
			
			controls1 = new Button(x1+getDelta(1), yBlock+getDelta(1),
				(Settings.classP1 == HumanPlayer) ? humanNormal : computerNormal,
				(Settings.classP1 == HumanPlayer) ? humanHover : computerHover,
				function():void{
				if (controls1.normalGraphic == humanNormal) {
					controls1.normalGraphic = computerNormal;
					controls1.hoverGraphic = computerHover;
					
					Settings.classP1 = Settings.classAI;
					
					if (! Settings.menuShapeP1) {
						Settings.menuShapeP1 = "random";
					}
				} else {
					controls1.normalGraphic = humanNormal;
					controls1.hoverGraphic = humanHover;
					
					Settings.classP1 = HumanPlayer;
				}
				Audio.play("block");
			});
			controls1.width = size1;
			controls1.height = size1;
			
			add(controls1);
			
			controls2 = new Button(x2+getDelta(1), yBlock+getDelta(1),
				(Settings.classP2 == HumanPlayer) ? humanNormal : computerNormal,
				(Settings.classP2 == HumanPlayer) ? humanHover : computerHover,
				function():void{
				if (controls2.normalGraphic == humanNormal) {
					controls2.normalGraphic = computerNormal;
					controls2.hoverGraphic = computerHover;
					
					Settings.classP2 = Settings.classAI;
					
					if (! Settings.menuShapeP2) {
						Settings.menuShapeP2 = "random";
					}
				} else {
					controls2.normalGraphic = humanNormal;
					controls2.hoverGraphic = humanHover;
					
					Settings.classP2 = HumanPlayer;
				}
				Audio.play("block");
			});
			controls2.width = size1;
			controls2.height = size1;
			
			add(controls2);
			
			makeShape("J", 0, 0);
			makeShape("T", 1, 0);
			makeShape("L", 2, 0);
			makeShape("random", 0, 1);
			makeShape("O", 2, 1);
			makeShape("Z", 0, 2);
			makeShape("I", 1, 2);
			makeShape("S", 2, 2);
			
			selectedP1 = new BlockButton(x1 + getDelta(1, true), yBlock + getDelta(1, true), size1, null, "P1", controls1.callback);
			selectedP2 = new BlockButton(x2 + getDelta(1, true), yBlock + getDelta(1, true), size1, null, "P2", controls2.callback);
			
			add(selectedP1);
			add(selectedP2);
			
			buttonsP1.splice(4, 0, selectedP1);
			buttonsP2.splice(4, 0, selectedP2);
			
			var tmp:* = buttonsP2[3];
			buttonsP2[3] = buttonsP2[5];
			buttonsP2[5] = tmp;
			
			fightButton = makeButton("FIGHT", function():void{
				Settings.shapeP1 = Settings.menuShapeP1;
				Settings.shapeP2 = Settings.menuShapeP2;
				Settings.rotationP1 = Settings.menuRotationP1;
				Settings.rotationP2 = Settings.menuRotationP2;
				FP.world = new Level(true);
				Audio.play("hit");
			});
			
			fightText = new Text("Press\nTwo Player Select\nto fight", FP.width*0.5, 0, {size: 20, align:"center"});
			
			fightText.centerOO();
			
			fightButton.y = (yBlock + size2 + FP.height - 64*scale - fightButton.height)*0.5;
			
			fightText.y = (yBlock + size2 + FP.height - 128)*0.5;
			
			fightText.visible = fightButton.visible = false;
			
			if (Settings.arcade) {
				addGraphic(fightText);
			} else {
				add(fightButton);
			}
			
			var offsetX:int = (FP.width - 640) * 0.5;
			
			var lifeG1:Entity = addGraphic(new Stamp(Player.LifeGfx), 0, offsetX + 64, 480 - 128);
			var lifeG2:Entity = addGraphic(new Stamp(Player.LifeGfx), 0, offsetX + 640-96, 480 - 128);
			
			var lives1:Text = new Text("x" + (Settings.livesP1 < 10 ? "0":"") + Settings.livesP1, offsetX + 96, 480-128+5, {size:20, color:0xFFFFFF});
			
			var lives2:Text = new Text((Settings.livesP2 < 10 ? "0":"") + Settings.livesP2+"x", offsetX + 640-100-96-2, 480-128+5, {align:"right", width: 100, size:20, color:0xFFFFFF});
			
			addGraphic(lives1);
			addGraphic(lives2);
			
			var up1:Spritemap = new Spritemap(ArrowGfx, 17, 18);
			var up2:Spritemap = new Spritemap(ArrowGfx, 17, 18);
			var down1:Spritemap = new Spritemap(ArrowGfx, 17, 18);
			var down2:Spritemap = new Spritemap(ArrowGfx, 17, 18);
			
			down1.frame = 1;
			down2.frame = 1;
			
			up2.color = 0xFF0000;
			down2.color = 0xFF0000;
			
			var upB1:Button = new Button(offsetX + 96+40, 480-128-2, up1, up2, function ():void {
				Settings.livesP1 += 1;
				Settings.livesP1 = FP.clamp(Settings.livesP1, 0, 20);
				lives1.text = "x" + (Settings.livesP1 < 10 ? "0":"") + Settings.livesP1;
			});
			
			var downB1:Button = new Button(offsetX + 96+40, 480-128-2+18, down1, down2, function ():void {
				Settings.livesP1 -= 1;
				Settings.livesP1 = FP.clamp(Settings.livesP1, 0, 20);
				lives1.text = "x" + (Settings.livesP1 < 10 ? "0":"") + Settings.livesP1;
			});
			
			var upB2:Button = new Button(offsetX + 640-96-40-17, 480-128-2, up1, up2, function ():void {
				Settings.livesP2 += 1;
				Settings.livesP2 = FP.clamp(Settings.livesP2, 0, 20);
				lives2.text = (Settings.livesP2 < 10 ? "0":"") + Settings.livesP2+"x";
			});
			
			var downB2:Button = new Button(offsetX + 640-96-40-17, 480-128-2+18, down1, down2, function ():void {
				Settings.livesP2 -= 1;
				Settings.livesP2 = FP.clamp(Settings.livesP2, 0, 20);
				lives2.text = (Settings.livesP2 < 10 ? "0":"") + Settings.livesP2 + "x";
			});
			
			add(upB1);
			add(upB2);
			add(downB1);
			add(downB2);
			
			var offset:Number = yBlock + size2 + (FP.height - 32 - 64*scale - yBlock - size2)*0.5 - lifeG1.y;
			
			lifeG1.y += offset;
			lifeG2.y += offset;
			
			lives1.y += offset;
			lives2.y += offset;
			
			upB1.y += offset;
			upB2.y += offset;
			downB1.y += offset;
			downB2.y += offset;
		}
		
		private function makeShape(shape:String, i:int, j:int):void
		{
			var dx:int = getDelta(i, true);
			var dy:int = getDelta(j, true);
			
			var b:*;
			
			b = add(new BlockButton(x1 + dx, yBlock + dy, size1, shape, "P1"));
			
			buttonsP1.push(b);
			
			if (shape == "O") dx = getDelta(0, true);
			if (shape == "random") dx = getDelta(2, true);
			
			b = add(new BlockButton(x2 + dx, yBlock + dy, size1, shape, "P2"));
			
			buttonsP2.push(b);
		}
		
		public static function makeButton (text:String, callback:Function):Button
		{
			var fight:Text = new Text(text, 0, 0, {size: 30, color: 0x0});
			
			var fightBG:BitmapData = FP.tint(Main.makeBlock(200, fight.height+12), 0xFF0000);
			
			FP.point.x = (fightBG.width - fight.width)*0.5;
			FP.point.y = 6;
			fight.render(fightBG, FP.point, FP.zero);
			
			var fightBG2:BitmapData = FP.tint(Main.makeBlock(200, fight.height+12), 0xFF0000);
			
			fight.color = 0xFFFFFF;
			
			FP.point.x = (fightBG.width - fight.width)*0.5;
			FP.point.y = 6;
			fight.render(fightBG2, FP.point, FP.zero);
			
			var fightButton:Button = new Button(0, 0, fightBG, fightBG2, callback);
			
			fightButton.x = (FP.width - fightButton.width)*0.5;
			
			return fightButton;
		}
		
		private function getDelta (i:int, center:Boolean = false):int
		{
			return paddingB + (paddingA + size1)*i + int(center)*size1*0.5;
		}
		
		public override function update (): void
		{
			Input.mouseCursor = "auto";
			
			super.update();
			
			if (Settings.arcade) {
				if (Input.check("1playermode") && Input.check("2playermode")) {
					fscommand("quit");
					return;
				}
				
				for each (var p:String in ["P1", "P2"]) {
					var array:Array = this["buttons"+p];
					var selected:* = this["selected"+p];
					var index:int = array.indexOf(selected);
					
					if (index >= 9) {
						// TODO: health
					} else {
						if (Input.pressed("left"+p) && (index % 3 != 0)) {
							index -= 1;
						} else if (Input.pressed("right"+p) && (index % 3 != 2)) {
							index += 1;
						} else if (Input.pressed("up"+p) && (index >= 3)) {
							index -= 3;
						} else if (Input.pressed("down"+p) && (index < 6)) {
							index += 3;
						}
					}
					
					this["selected"+p] = array[index];
				}
			}
			
			if (Settings.menuShapeP1 && Settings.menuShapeP2) {
				if (Settings.arcade) {
					if (Settings.classP1 == HumanPlayer) {
						var playerCount:String = "TWO";
						if (Settings.classP2 != HumanPlayer) {
							playerCount = "ONE";
						}
						
						fightText.text = "Press\n" + playerCount + " PLAYER SELECT\nto fight";
						fightText.visible = ((BlockButton(selectedP1).timer % 120) < 60);
					}
				} else {
					fightButton.visible = true;
				}
			}
			
			if (Input.pressed("1playermode")) {
				if (Settings.classP1 == HumanPlayer && Settings.classP2 != HumanPlayer && Settings.menuShapeP1 && Settings.menuShapeP2) {
					fightButton.callback();
					return;
				}
				
				if (Settings.classP1 != HumanPlayer) {
					controls1.callback();
				}
				if (Settings.classP2 == HumanPlayer) {
					controls2.callback();
				}
			}
			
			if (Input.pressed("2playermode")) {
				if (Settings.classP1 == HumanPlayer && Settings.classP2 == HumanPlayer && Settings.menuShapeP1 && Settings.menuShapeP2) {
					fightButton.callback();
					return;
				}
				
				if (Settings.classP1 != HumanPlayer) {
					controls1.callback();
				}
				if (Settings.classP2 != HumanPlayer) {
					controls2.callback();
				}
			}
		}
		
		public override function render (): void
		{
			super.render();
		}
		
		public override function begin ():void
		{
			Audio.stopMusic();
			
			FP.engine.addChild(credits);
		}
		
		public override function end ():void
		{
			FP.engine.removeChild(credits);
		}
		
		public static function makeHTMLText (html:String, size:Number, color:uint, css:String): TextField
		{
			var ss:StyleSheet = new StyleSheet();
			ss.parseCSS(css);
			
			var textField:TextField = new TextField;
			
			textField.selectable = false;
			textField.mouseEnabled = true;
			
			textField.embedFonts = true;
			
			textField.autoSize = "center";
			
			textField.textColor = color;
			
			textField.defaultTextFormat = new TextFormat("modenine", size);
			
			textField.htmlText = html;
			
			textField.styleSheet = ss;
			
			return textField;
		}
	}
}

