package gamelogic;

import gamelogic.physics.PhysicalWorld.PHYSICSCALEINVERT;
import utilities.MessageManager;
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

	static var maxID = 0;
	public var id: Int;

	var destination = new Vector2D();
	var targetFacing = 0.0;
	var rotating = true;

	public function new(r:Int, c:Int) {
		id = maxID++;
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
			if (i == ps.length) break;
			units[i].destination = ps[i];
		}

		for (u in units)
			u.update(dt);
	}

	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, KeyUp)) {
			var params = cast(msg, KeyUp);
			if (params.keycode == Key.SPACE)
				rotating = !rotating;
			// if (params.keycode == Key.R)
			// 	rows++;
			// if (params.keycode == Key.F)
			// 	if (rows > 1)
			// 		rows--;
			// if (params.keycode == Key.T)
			// 	columns++;
			// if (params.keycode == Key.G)
			// 	if (columns > 1)
			// 		columns--;
			// if (params.keycode == Key.Y)
			// 	rowSpacing++;
			// if (params.keycode == Key.H)
			// 	if (rowSpacing > 1)
			// 		rowSpacing--;
			// if (params.keycode == Key.U)
			// 	columnSpacing++;
			// if (params.keycode == Key.J)
			// 	if (columnSpacing > 1)
			// 		columnSpacing--;
		} if (Std.isOfType(msg, MouseRelease)) {
			var params = cast(msg, MouseRelease);
			if (params.event.button == 0) {
				destination = params.worldPosition;
				destination *= -1;
			}
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