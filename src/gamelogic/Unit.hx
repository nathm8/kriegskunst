package gamelogic;

import utilities.Utilities.normaliseRadian;
import hxd.fs.FileEntry;
import haxe.Json;
import utilities.Utilities.slerp;
import graphics.UnitGraphics;
import utilities.RNGManager;
import utilities.MessageManager;
import gamelogic.physics.CircularPhysicalGameObject;
import gamelogic.physics.PhysicalWorld;
import box2D.dynamics.joints.B2MouseJoint;
import box2D.dynamics.joints.B2MouseJointDef;
import utilities.Vector2D;

typedef UnitJson = {
    var maxSpeed: Float;
    // how much top speed can fluctuate
    var speedVariance: Float;
    // multiplier on random impulses when moving, used to get unstuck from other units
    var jitterMaxMagnitude: Float;
    var movementForce: Float;
    // how much unit's destination can vary from orders
    var destinationVariance: Float;
    // how much averageSpeedNoise is weighted towards it's previous value
    var averageSpeedNoiseRatio: Float;
    // box2d params
    var linearDamping: Float;
    var friction: Float;
    var restitution: Float;
    var density: Float;
    var radius: Float;
}

class RotationTween {

    var target: Unit;
    var start: Float;
    var end: Float;
    var timeElapsed: Float;
    var timeTotal: Float;
    public var active = false;

    public function new(t: Unit, e: Float, tt: Float) {
        target = t;
        start = t.facing;
        end = e;
        timeTotal = tt;
        timeElapsed = 0;
        active = true;
    }

    public function update(dt: Float) {
        if (!active) return;
        timeElapsed += dt;
        var r = timeElapsed/timeTotal;
        target.facing = slerp(start, end, r);
        active = timeElapsed < timeTotal;
    }
}

class Unit extends CircularPhysicalGameObject implements MessageListener implements Updateable {

    ////////////////////
    // Physics
    ////////////////////
    public var destination(default, set): Vector2D;
    var mouseJoint: B2MouseJoint;
    
    ////////////////////
    // hot-loadable parameters
    ////////////////////
    var json: FileEntry;
    public var params: UnitJson;

    ////////////////////
    // Simulation
    ////////////////////
    var averageSpeedNoise = 0.0;
    var jitterClock = 0.0;
    var jitterClockMax = 1.0;
    // in radians
    public var facing = 0.0;
    public var targetFacing(default, set) = 0.0;

    // PitA to do this manually but slide doesn't seem to support it easily
    public var facingTween: RotationTween;

    ////////////////////
    // Combat Stats
    ////////////////////
    public var dead = false;
    // public var healthpoints = 1.0;
    // var damage

    ////////////////////
    // UI Control State
    ////////////////////
    public var selectable(default, set) = true;
    public var graphics: UnitGraphics;

    function fromJson(j: FileEntry) {
        json = j;
        params = Json.parse(json.getText());
    }

    function initialisePhysics() {
        body.setLinearDamping(params.linearDamping);
        var f = body.getFixtureList();
        f.setFriction(params.friction);
        f.setRestitution(params.restitution);
        f.setDensity(params.density);
        f.getShape().m_radius = params.radius;
        body.resetMassData();
        body.setAwake(true);
    }

    public function toJson(): String {
        var f = body.getFixtureList();
        var input: UnitJson = {
            maxSpeed: params.maxSpeed,
            speedVariance: params.speedVariance,
            jitterMaxMagnitude: params.jitterMaxMagnitude,
            movementForce: params.movementForce,
            destinationVariance: params.destinationVariance,
            averageSpeedNoiseRatio: params.averageSpeedNoiseRatio,
            linearDamping: body.getLinearDamping(),
            friction: f.getFriction(),
            restitution: f.getRestitution(),
            density: f.getDensity(),
            radius: f.getShape().m_radius
        }
        return Json.stringify(input, null, "  ");
    }
  
    public function new(p: Vector2D, j: FileEntry=null) {
        if (j == null)
            j = hxd.Res.data.DefaultUnit.entry;
        fromJson(j);
        super(p, params.radius, this);
        initialisePhysics();

        // init physical movement
        var mouse_joint_definition = new B2MouseJointDef();
        mouse_joint_definition.bodyA = PhysicalWorld.gameWorld.m_groundBody;
        mouse_joint_definition.bodyB = body;
        mouse_joint_definition.collideConnected = false;
        mouse_joint_definition.target = p;
        
        mouseJoint = cast(PhysicalWorld.gameWorld.createJoint(mouse_joint_definition), B2MouseJoint);

        destination = p;
        jitterClock = RNGManager.srand();
        jitterClockMax += RNGManager.srand(0.5);

        MessageManager.send(new NewUnit(this));
        MessageManager.addListener(this);
    }

    public function update(dt:Float) {
        if (body == null)
            return dead;
        if (body.isAwake()) {
            // impose speed limit
            var speed_noise = RNGManager.srand(params.speedVariance);
            averageSpeedNoise = params.averageSpeedNoiseRatio*averageSpeedNoise + (1-params.averageSpeedNoiseRatio)*speed_noise;
            var vel: Vector2D = body.getLinearVelocity();
            var speed = params.maxSpeed + averageSpeedNoise;
            var mag = vel.magnitude;
            if (mag > params.maxSpeed)
                body.setLinearVelocity(speed*vel/mag);
            mouseJoint.setMaxForce(params.movementForce*speed);

            // apply some jitter if we're not at our destination yet
            // helps get unstuck from other units, and looks kinda nice
            jitterClock += dt;
            if (jitterClock > jitterClockMax) {
                jitterClock = 0;
                var p: Vector2D = body.getPosition();
                if (p.distanceTo(destination) > 0.1) {
                    // jitter orthogonally to our destination, with some random variation in magnitude and angle
                    // var o = (p - destination).normalize().rotate(Math.PI/2);
                    // o = RNGManager.random(1) == 0 ? o : -o;
                    // var v = RNGManager.srand() * jitterMaxMagnitude * o.rotate(RNGManager.srand(Math.PI/4));

                    // jitter in a random direction
                    var v = RNGManager.srand() * new Vector2D(params.jitterMaxMagnitude, 0).rotate(RNGManager.srand(Math.PI));
                    body.applyImpulse(v, body.getPosition());
                }
            }
        }
        
        // facing
        facingTween?.update(dt);

        return dead;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, UpdateUnit)) {
            var params = cast(msg, UpdateUnit);
            if (params.json == json) {
                fromJson(json);
                initialisePhysics();
            }
        }
        if (Std.isOfType(msg, RemoveUnit)) {
            var params = cast(msg, RemoveUnit);
            if (params.unit == this) {
                MessageManager.removeListener(this);
                removePhysics();
                dead = true;
            }
        }
        return false;
    }
    
    public function fire() {
        graphics.fire();
    }

    function set_selectable(value) {
        selectable = value;
        graphics.interactive.visible = value;
        return value;
    }

    function set_destination(value:Vector2D):Vector2D {
        destination = value + params.destinationVariance*(new Vector2D(1, 0)).rotate(RNGManager.randomAngle());
        mouseJoint.setTarget(destination);
        return destination;
    }

    function set_targetFacing(value) {
        var time = 2*Math.abs(normaliseRadian(facing - value, true) / (Math.PI));
        facingTween = new RotationTween(this, value, time);
        targetFacing = value;
        return value;
    }
}