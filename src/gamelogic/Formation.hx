package gamelogic;

import haxe.display.Protocol.Timer;
import utilities.Assert.assert;
import utilities.RNGManager;
import utilities.MessageManager;
import utilities.Vector2D;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;

// facings are radians, 0 = right facing, increasing clockwise
class Formation implements MessageListener implements Updateable {

    public var units = new Array<Unit>();
    public var columns = 1;
    public var rows = 1;
    // in gamescene-space
    public var columnSpacing = 22;
    public var rowSpacing = 17;

    var unitToPosition: Array<{p: Int, q: Int}>;

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
        unitToPosition = [for (i in 0...units.length) {p:i, q:i}];
        MessageManager.addListener(this);
        MessageManager.send(new NewFormation(this));
    }

    function getRectangularCentre(): Vector2D {
        return new Vector2D((columns-1)*columnSpacing, (rows-1)*rowSpacing)*0.5;
    }

    // TODO: what to do with final row when units < positions? align leftmost, or spread evenly? center?
    public function determineRectangularPositions(position: Vector2D, facing: Float) : Array<Vector2D> {
        var out = new Array<Vector2D>();
        var centre = getRectangularCentre();
        for (c in 0...rows) {
            for (r in 0...columns) {
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
        var qs = determineRectangularPositions(destination, targetFacing);
        // heuristic, should do this with events
        var unit_count_changed = qs.length != units.length;
        if (qs.length > units.length) {
            for (i in 0...qs.length - units.length) {
                var u = new Unit(new Vector2D());
                u.destination = qs[i];
                units.push(u);
            }
        }
        while (units.length > qs.length) {
            var i = RNGManager.random(units.length);
            MessageManager.send(new RemoveUnit(units[i]));
            units.splice(i, 1);
        }

            
        if (unit_count_changed) {
            // General case: annealing
            var ps = new Array<Vector2D>();
            for (i in 0...units.length)
                ps.push(units[i].body.getPosition());
            
            unitToPosition = getMinimisedMapping(ps, qs);
        }
        for (pq in unitToPosition) {
            units[pq.p].destination = qs[pq.q];
            units[pq.p].targetFacing = targetFacing;
        }
        
    }
}

// use simulated annealing to get an approximation of a minimal mapping
// https://en.wikipedia.org/wiki/Simulated_annealing
final annealing_iterations = 50000; // maybe do time based instead

function totalMappingDistance(ps: Array<Vector2D>, qs: Array<Vector2D>, map: Array<{p: Int, q: Int}>) : Int {
    var out = 0.0;
    for (i in 0...ps.length) {
        // use length to skip sqrt in magnitude calcs
        // var l = (ps[map[i].p] - qs[map[i].q]).length;
        // trace('$i $l\n${ps[map[i].p]}\n${qs[map[i].q]}\n');
        out += (ps[map[i].p] - qs[map[i].q]).length;
    }
        return Math.round(out);
}

// old and new energies can be any positive value, so we cannot normalise them
// temp is in [0, 1)
// var hit = 0;
// var miss = 0;
// var rng = 0;
final energy_threshold = 100;
function accept(old_energy: Float, new_energy: Float, temp: Float): Bool {
    if (new_energy < old_energy) {
        // hit++;
        return true;
    } if (new_energy > old_energy + energy_threshold) {
        // miss++;
        return false;
    }
    // rng++;
    // r in [0, 1]
    var r = old_energy/new_energy;
    // as temp decreases this trends towards evaluating to false
    // new energy much greater than low energy will trend to false
    return Math.exp(-r)*temp > RNGManager.srand();
}

// return a new map, swapping a random p-q
function randomNeighbour(ps: Array<Vector2D>, qs: Array<Vector2D>, map: Array<{p: Int, q: Int}>): Array<{p: Int, q: Int}> {
    var i = RNGManager.random(ps.length);
    var j = RNGManager.random(qs.length);
    var out = map.copy();
    out[i] = {p: map[i].p, q: map[j].q};
    out[j] = {p: map[j].p, q: map[i].q};
    return out;
}

// simulated annealing to find a mapping from ps to qs minimising the total distance between each p-q
function getMinimisedMapping(ps: Array<Vector2D>, qs: Array<Vector2D>): Array<{p: Int, q: Int}> {
    assert(ps.length == qs.length);
    // hit = 0;
    // miss = 0;
    // rng = 0;

    // initialise with grid state
    var best = [for (i in 0...ps.length) {p: i, q: i}];
    var best_energy = totalMappingDistance(ps, qs, best);
    // trace('initial best energy:\n $best_energy');
    // anneal
    var early_exit = 0;
    for (i in 0...annealing_iterations) {
        if (hxd.Timer.elapsedTime > 0.025 && i > 0)
            break;
        var temp = 1 - i/annealing_iterations;
        var neighbour = randomNeighbour(ps, qs, best);
        var new_energy = totalMappingDistance(ps, qs, neighbour);
        if (accept( best_energy, new_energy, temp )) {
            best = neighbour;
            best_energy = new_energy;
            early_exit = 0;
        } else {
            // if we don't get a better energy in 100 tries, early exit
            early_exit++;
            if (early_exit == 1000)
                break;
        }
    }
    // trace('final best energy:\n $best_energy');
    // trace('hit: $hit miss: $miss rng: $rng');
    return best;
}