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

    public var state = Standing;
    public var units = new Array<Unit>();
    public var positions = 0;
    public var rows = 1;
    public var columns = 1;
    // in metres
    public var rowSpacing = 20;
    public var columnSpacing = 15;

    static var maxID = 0;
    public var id: Int;

    public var destination = new Vector2D();
    public var targetFacing = 0.0;
    var rotating = false;

    public function new(r:Int, c:Int) {
        id = maxID++;
        rows = r;
        columns = c;
        for (p in determineRectangularPositions(new Vector2D(0,0), 0)) {
            var u = new Unit(p);
            units.push(u);
        }
        MessageManager.addListener(this);
        MessageManager.send(new NewFormation(this));
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
        positions = out.length;
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

        // lazy bad hacky
        MessageManager.send(new FormationUpdate(this));
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, KeyUp)) {
            var params = cast(msg, KeyUp);
            if (params.keycode == Key.SPACE)
                rotating = !rotating;
        } if (Std.isOfType(msg, MouseRelease)) {
            // var params = cast(msg, MouseRelease);
            // if (params.event.button == 0) {
            //     destination = params.worldPosition;
            //     destination *= -1;
            // }
        }
        return false;
    }

    // public function setMarchingOrder(destination: Vector2D, facing: Float) {
    //     if (state == Standing) {
    //         var ps = determineRectangularPositions(destination, facing);
    //         for (i in 0...units.length) {
    //             units[i].marchTo(ps[i], facing);
    //         }
    //     } else {

    //     }
    // }
}