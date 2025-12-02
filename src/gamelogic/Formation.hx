package gamelogic;

import utilities.Vector2D;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;

class Formation implements MessageListener implements Updateable {

	var position= new Vector2D(); // measured from centre
	// var facing = 0.0; // 0 = facing right
	var facing = Math.PI/4; // 0 = facing right
	var rows = 1;
	var columns = 1;
	var rowSpacing = 80.0;
	var columnSpacing = 60.0;
	var units = new Array<Unit>();

	public function new(r:Int, c:Int) {
		rows = r;
		columns = c;
		for (p in determineRectangularPositions()) {
			var u = new Unit(p);
			units.push(u);
		}
	}

	function determineRectangularPositions() : Array<Vector2D> {
		var out = new Array<Vector2D>();
		var centre = new Vector2D((rows-1)*rowSpacing, (columns-1)*columnSpacing)*0.5;
		trace(centre);
		for (r in 0...rows) {
			for (c in 0...columns) {
				var p = new Vector2D(r*rowSpacing, c*columnSpacing).rotateAboutPoint(facing, centre) - position - centre;
				out.push(p);
			}
		}
		return out;
	}

    public function update(dt:Float) {
		for (u in units)
			u.update(dt);
	}

	public function receiveMessage(msg:Message):Bool {
		return false;
	}
}