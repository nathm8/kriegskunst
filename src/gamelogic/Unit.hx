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
    var maxSpeed = 1.0;

    // how much random variation is applied destination to noise up movement
    var jitterMagnitude = 5.0;
    var prevNoises = new Array<Vector2D>();
    // how much top speed can fluctuate
    var speedJitterMagnitude = 1.0;
    var prevSpeedNoises = new Array<Float>();
    
    // in radians
    public var facing = 0.0;
    public var targetFacing = 0.0;

    ////////////////////
    // Combat Stats
    ////////////////////
    public var healthpoints = 1.0;
    // var damage

    ////////////////////
    // UI Control State
    ////////////////////
    public var selectable(default, set) = true;
    public var graphics: UnitGraphics;

    public function new(p: Vector2D) {
        super(p, UNITRADIUS, this);

        // init physical movement
        var mouse_joint_definition = new B2MouseJointDef();
        mouse_joint_definition.bodyA = PhysicalWorld.gameWorld.m_groundBody;
        mouse_joint_definition.bodyB = body;
        mouse_joint_definition.collideConnected = false;
        mouse_joint_definition.target = p;
        mouse_joint_definition.maxForce = 10;
        
        mouseJoint = cast(PhysicalWorld.gameWorld.createJoint(mouse_joint_definition), B2MouseJoint);

        destination = p;

        MessageManager.send(new NewUnit(this));
        MessageManager.addListener(this);
    }

    public function update(dt:Float) {
        if (body == null)
            return false;
        if (body.isAwake()) {
            // impose speed limit
            var speed_noise = RNGManager.srand(speedJitterMagnitude);
            prevSpeedNoises.push(speed_noise);
            var average_speed_noise = 0.0;
            for (n in prevSpeedNoises)
                average_speed_noise += n;
            average_speed_noise /= prevSpeedNoises.length;
            if (prevSpeedNoises.length > 10)
                prevSpeedNoises.shift();
            var vel: Vector2D = body.getLinearVelocity();
            var speed = maxSpeed + average_speed_noise;
            var mag = vel.magnitude;
            if (mag > maxSpeed)
                body.setLinearVelocity(speed*vel/mag);
            mouseJoint.setMaxForce(10*speed);

            // apply some jitter if we're not at our destination yet
            // helps get unstuck from other units, and looks kinda nice
            // TODO: do this periodically instead of every frame
            var p: Vector2D = body.getPosition();
            if (p.distanceTo(destination) > 0.1) {
                var v = RNGManager.srand() * new Vector2D(jitterMagnitude, 0).rotate(2*RNGManager.srand());
                body.applyImpulse(v, body.getPosition());
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