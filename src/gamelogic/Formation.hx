package gamelogic;

import utilities.Vector2D;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;

enum FormationState {
	Standing;
	Moving;
}


// facings are radians, 0 = right facing, increasing clockwise
class Formation implements MessageListener implements Updateable {

	var state = Standing;
	var units = new Array<Unit>();
	var rows = 1;
	var columns = 1;
	// in metres
	var rowSpacing = 20.0;
	var columnSpacing = 15.0;

	public function new(r:Int, c:Int) {
		rows = r;
		columns = c;
		for (p in determineRectangularPositions(new Vector2D(0,0), 0)) {
			var u = new Unit(p);
			units.push(u);
		}
	}

	function getRectangularCentre(): Vector2D {
		return new Vector2D((rows-1)*rowSpacing, (columns-1)*columnSpacing)*0.5;
	}

	function determineRectangularPositions(position: Vector2D, facing: Float) : Array<Vector2D> {
		var out = new Array<Vector2D>();
		var centre = getRectangularCentre();
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

	public function setMarchingOrder(destination: Vector2D, facing: Float) {
		if (state == Standing) {
			var ps = determineRectangularPositions(destination, facing);
			for (i in 0...units.length) {
				units[i].marchTo(ps[i], facing);
			}
		} else {

		}
	}
}