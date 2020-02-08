package mm.games
{
	import flash.utils.ByteArray;
	import flash.geom.Point;
	
	public class TilePathfinder extends Object
	{
		private var tileMap: Array;
		private var tileSize: Object;
		
		public function TilePathfinder(tileMap: Array)
		{
			this.tileMap = clone(tileMap);
		}
		
		static public function clone(source:Object):*
		{ 
			var myBA:ByteArray = new ByteArray(); 
			myBA.writeObject(source); 
			myBA.position = 0; 
			return(myBA.readObject()); 
		}
		
		public function setTileSize(w:uint, h:uint):void {
			this.tileSize = {width: w, height: h};
		}
		
		public function getPositionToTile(posX: Number, posY: Number):Point {
			var pt:Point;
			if (this.tileSize) {
				pt = new Point(Math.floor(posX / this.tileSize.width), Math.floor(posY / this.tileSize.height));
			}
			return pt;
		}
		
		public function getPositionToPixels(posX:int, posY:int, center:Boolean = true):Point {
			var pt:Point;
			if (this.tileSize) {
				var offset:Number = (center) ? .5 : 0;
				pt = new Point(posX * this.tileSize.width + this.tileSize.width * offset, posY * this.tileSize.height + this.tileSize.height * offset);
			}
			return pt;
		}
		
		
		public function moveFromTo(startX:int, startY:int, targetX:int, targetY:int):Array
		{
			var path:Array = [];
			if (startX >= 0 && startX < this.tileMap[0].length && startY >= 0 && startY < this.tileMap.length) {
				if (targetX >= 0 && targetX < this.tileMap[0].length && targetY >= 0 && targetY < this.tileMap.length) {
					if (this.tileMap[targetY][targetX]) { // tileType == 1
						path = this.findPath(startX, startY, targetX, targetY);
					} else { // not walkable tile
						trace("not walkable tile");
					}
				} else { // target out of bounds
					trace("target out of bounds");
				}
			} else { // source out of bounds
				trace("source out of bounds");
			}
			return path;
		}
		
		private function findPath(startX: int, startY:int, targetX:int, targetY:int):Array
		{
			var pathFinal:Array = [];
			var pathName:String = "node_" + startY + "_" + startX;
			var n_obj:Object = {x: startX, y: startY, parentX: null, parentY: null, visited: true}
			var pathTemp:Object = {name: pathName, uncheckedNeighbours: [n_obj]};
			pathTemp[pathName] = n_obj;
			while (pathTemp.uncheckedNeighbours.length) {
				var N:Object = pathTemp.uncheckedNeighbours.shift();
				if (N.x == targetX && N.y == targetY) { // path found
					pathFinal = this.makePath(pathTemp, N);
					break;
				} else {
					N.visited = true;
					this.addNode(pathTemp, N, N.x + 1, N.y);
					this.addNode(pathTemp, N, N.x - 1, N.y);
					this.addNode(pathTemp, N, N.x, N.y + 1);
					this.addNode(pathTemp, N, N.x, N.y - 1);
				}
			}
			pathTemp = null;
			return pathFinal;
		}
		
		private function addNode(pathTemp: Object, obj:Object, posX:int, posY:int):void
		{
			if (posX >= 0 && posX < this.tileMap[0].length && posY >= 0 && posY < this.tileMap.length) {
				var pathName:String = "node_" + posY + "_" + posX;
				pathTemp.name = pathName;
				if (this.tileMap[posY][posX]) {
					var addObj:Boolean = false;
					var e_obj:Object = pathTemp[pathName];
					if (e_obj) {
						if (!e_obj.visited) addObj = true;
					} else {
						addObj = true;
					}
					if (addObj) {
						var n_obj:Object = {x: posX, y: posY, parentX: obj.x, parentY: obj.y, visited: false};
						pathTemp[pathName] = n_obj;
						pathTemp.uncheckedNeighbours.push(n_obj);
					}
				}
			}
		}
		
		private function makePath(pathTemp:Object, obj:Object):Array
		{
			var gamePath:Array = [];
			while (obj.parentX != null) {
				gamePath.push({posX: obj.x, posY: obj.y});
				obj = pathTemp["node_" + obj.parentY + "_" + obj.parentX];
			}
			return gamePath;
		}
		
		public function destroy():void {
			this.tileMap = null;
		}
		
	}

}