package gamelogic;

import utilities.Utilities.slerp;
import graphics.UnitGraphics;
import utilities.RNGManager;
import utilities.MessageManager;
import gamelogic.physics.CircularPhysicalGameObject;
import gamelogic.physics.PhysicalWorld;
import box2D.dynamics.joints.B2MouseJoint;
import box2D.dynamics.joints.B2MouseJointDef;
import utilities.Vector2D;

final UNITRADIUS = 0.2;

class Unit extends CircularPhysicalGameObject implements MessageListener implements Updateable {

    ////////////////////
    // Physics
    ////////////////////
    public var destination(default, set): Vector2D;
    var mouseJoint: B2MouseJoint;
    
    // multiplier on random impulses when moving, used to get unstuck from other units
    var jitterMaxMagnitude = 1.0;
    var maxSpeed = 1.0;
    // how much top speed can fluctuate
    var speedVariance = 1.0;
    var movementForce = 10.0;

    ////////////////////
    // Simulation
    ////////////////////
    var averageSpeedNoise = 0.0;
    var jitterClock = 0.0;
    var jitterClockMax = 1.0;
    // in radians
    public var facing = 0.0;
    public var targetFacing = 0.0;

    ////////////////////
    // Combat Stats
    ////////////////////
    // public var healthpoints = 1.0;
    // var damage

    ////////////////////
    // UI Control State
    ////////////////////
    public var selectable(default, set) = true;
    public var graphics: UnitGraphics;

    // stats to serialise
    // just concerned with "unit stats" here, nothing tracking battlefield state
    // s.serialize(maxSpeed);
    // s.serialize(jitterMaxMagnitude);
    // s.serialize(speedVariance);
    // s.serialize(movementForce);
  
    public function new(p: Vector2D) {
        super(p, UNITRADIUS, this);

        // init physical movement
        var mouse_joint_definition = new B2MouseJointDef();
        mouse_joint_definition.bodyA = PhysicalWorld.gameWorld.m_groundBody;
        mouse_joint_definition.bodyB = body;
        mouse_joint_definition.collideConnected = false;
        mouse_joint_definition.target = p;
        mouse_joint_definition.maxForce = movementForce;
        
        mouseJoint = cast(PhysicalWorld.gameWorld.createJoint(mouse_joint_definition), B2MouseJoint);

        destination = p;
        jitterClock = RNGManager.srand();
        jitterClockMax += RNGManager.srand(0.5);

        MessageManager.send(new NewUnit(this));
        MessageManager.addListener(this);
    }

    public function update(dt:Float) {
        if (body == null)
            return false;
        if (body.isAwake()) {
            // impose speed limit
            var speed_noise = RNGManager.srand(speedVariance);
            averageSpeedNoise = 0.9*averageSpeedNoise + 0.1*speed_noise;
            var vel: Vector2D = body.getLinearVelocity();
            var speed = maxSpeed + averageSpeedNoise;
            var mag = vel.magnitude;
            if (mag > maxSpeed)
                body.setLinearVelocity(speed*vel/mag);
            mouseJoint.setMaxForce(10*speed);

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
                    var v = RNGManager.srand() * new Vector2D(jitterMaxMagnitude, 0).rotate(RNGManager.srand(Math.PI));
                    body.applyImpulse(v, body.getPosition());
                }
            }
        }
        
        // facing
        // TODO impose more strict timeline
        facing = slerp(facing, targetFacing, 0.95);

        return false;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, RemoveUnit)) {
            var params = cast(msg, RemoveUnit);
            if (params.unit == this) {
                MessageManager.removeListener(this);
                removePhysics();
            }
        }
        return false;
    }
    
    public function fire() {
        body.setAwake(true);
        // our position
        var p = body.getPosition();
        // position of the end of our musket, bit clunky, we'll need to generalise this for weapons later
        var q = new Vector2D(0, -2*UNITRADIUS*PHYSICSCALE).rotate(facing).toBox2DVec();
        p.add(q);
        new Bullet(p, facing);
    }

    function set_selectable(value) {
        selectable = value;
        graphics.interactive.visible = value;
        return value;
    }

    function set_destination(value:Vector2D):Vector2D {
        destination = value + (new Vector2D(1, 0)).rotate(RNGManager.randomAngle());
        mouseJoint.setTarget(destination);
        return destination;
    }
}