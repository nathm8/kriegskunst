package gamelogic;

import utilities.MessageManager;
import utilities.Vector2D;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;

// facings are radians, 0 = right facing, increasing clockwise
class Formation implements MessageListener implements Updateable {

    public var units = new Array<Unit>();
    public var columns = 1;
    public var rows = 1;
    // in metres
    public var columnSpacing = 20;
    public var rowSpacing = 15;

    static var maxID = 0;
    public var id: Int;

    public var destination = new Vector2D(0,0);
    public var targetFacing = 0.0;
    public var listeningForDestination = false;

    public function new(r:Int, c:Int, d:Vector2D) {
        destination = d;
        id = maxID++;
        columns = r;
        rows = c;
        for (p in determineRectangularPositions(destination, 0)) {
            var u = new Unit(p);
            units.push(u);
        }
        MessageManager.addListener(this);
        MessageManager.send(new NewFormation(this));
    }

    function getRectangularCentre(): Vector2D {
        return new Vector2D((columns-1)*columnSpacing, (rows-1)*rowSpacing)*0.5;
    }

    public function determineRectangularPositions(position: Vector2D, facing: Float) : Array<Vector2D> {
        var out = new Array<Vector2D>();
        var centre = getRectangularCentre();
        for (r in 0...columns) {
            for (c in 0...rows) {
                var p = new Vector2D(r*columnSpacing, c*rowSpacing).rotateAboutPoint(facing, centre) + position - centre;
                out.push(p);
            }
        }
        return out;
    }

    public function update(dt:Float) {
        return false;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MouseRelease)) {
            if (!listeningForDestination) return false;
            var params = cast(msg, MouseRelease);
            if (params.event.button == 0) {
                listeningForDestination = false;
                destination = params.scenePosition;
                sendMarchingOrders();
                MessageManager.send(new FormationUpdate(this));
            }
        }
        if (Std.isOfType(msg, KeyUp)) {
            var params = cast(msg, KeyUp);
            if (params.keycode == hxd.Key.SPACE)
                for (i in 0...rows*columns)
                    units[i].fire();
        }
        return false;
    }

    public function setUnitFacings(f: Float) {
        for (i in 0...rows*columns)
            units[i].targetFacing = f;
    }

    public function sendMarchingOrders() {
        var ps = determineRectangularPositions(destination, targetFacing);
        if (ps.length > units.length) {
            for (i in 0...ps.length - units.length) {
                var u = new Unit(new Vector2D());
                u.destination = ps[i];
                units.push(u);
            }
        } else if (units.length > ps.length) {
            for (i in ps.length...units.length)
                MessageManager.send(new RemoveUnit(units[i]));
            units.resize(ps.length);
        }
        for (i in 0...units.length) {
            units[i].destination = ps[i];
            units[i].targetFacing = targetFacing;
        }
    }
}