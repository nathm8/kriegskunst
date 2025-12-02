package gamelogic;

import utilities.MessageManager;
import utilities.MessageManager.KeyUpMessage;
import hxd.Key;
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

	var destination = new Vector2D();
	var targetFacing = 0.0;
	var rotating = true;

	public function new(r:Int, c:Int) {
		rows = r;
		columns = c;
		for (p in determineRectangularPositions(new Vector2D(0,0), 0)) {
			var u = new Unit(p);
			units.push(u);
		}
		MessageManager.addListener(this);
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
		if (rotating)
			targetFacing += 0.5*dt;
		var ps = determineRectangularPositions(destination, targetFacing);
		for (i in 0...units.length) {
			if (i > ps.length) break;
			units[i].destination = ps[i];
		}

		for (u in units)
			u.update(dt);
	}

	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, KeyUpMessage)) {
			var params = cast(msg, KeyUpMessage);
			if (params.keycode == Key.SPACE)
				rotating = !rotating;
		}
		return false;
	}

	// public function setMarchingOrder(destination: Vector2D, facing: Float) {
	// 	if (state == Standing) {
	// 		var ps = determineRectangularPositions(destination, facing);
	// 		for (i in 0...units.length) {
	// 			units[i].marchTo(ps[i], facing);
	// 		}
	// 	} else {

	// 	}
	// }
}