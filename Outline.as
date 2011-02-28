package {

	import flash.display.BitmapData;
	import flash.geom.Point;

	public class Outline {

		private static const SPOTS:Array = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]];

		private var bitmapData:BitmapData;

		private var pixelTable:Array;

		private var rows:uint;
		private var cols:uint;

		public var points:Array;

		public function Outline(bmd:BitmapData):void {
			points = [];

			bitmapData = bmd;

			initialize();
		}

		private function hasTransparentNeighbor(rowIndex:uint,cellIndex:uint):Boolean {

			var spot:Array;
			var rowNum:int;
			var cellNum:int;
			var row:Array;
			
			if (rowIndex == 0 || cellIndex == 0 || rowIndex == bitmapData.height - 1 || cellIndex == bitmapData.width - 1) return true;

			for (var i:int = 0; i < 8; i++) {
				spot = SPOTS[i];
				rowNum = rowIndex + spot[0];
				if (rowNum > -1) {
					if (rowNum < rows) {
						cellNum = cellIndex + spot[1];
						if (cellNum > -1) {
							row = pixelTable[rowNum];
							if (cellNum < cols) {
								if (!row[cellNum]) {
									return true;
								}
							}
						}
					}
				}
			}
			return false;
		}

		private function populate():void {
			for (var i:int=0; i < rows; i++) {
				for (var j:int=0; j < cols; j++) {
					if (pixelTable[i][j]) {
						if (hasTransparentNeighbor(i,j)) {
							points.push(new Point(j, i));
						}
					}
				}
			}
		}

		private function initialize():void {

			rows = bitmapData.height;
			cols = bitmapData.width;

			pixelTable = new Array(rows);

			var row:Array;
			
			for (var i:int=0; i < rows; i++) {
				row = [];
				for (var j:int=0; j < cols; j++) {
					row[j] = (bitmapData.getPixel32(j, i) >> 24) & 0xFF;
				}
				pixelTable[i] = row;
			}

			populate();
		}

	}

}
