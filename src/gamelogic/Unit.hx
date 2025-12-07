package gamelogic;

import utilities.RNGManager;
import utilities.MessageManager;
import gamelogic.physics.CircularPhysicalGameObject;
import gamelogic.physics.PhysicalWorld;
import box2D.dynamics.joints.B2MouseJoint;
import box2D.dynamics.joints.B2MouseJointDef;
import utilities.Vector2D;

final UNITRADIUS = 0.2;

class Unit extends CircularPhysicalGameObject implements MessageListener implements Updateable {
    public var destination: Vector2D;
    public var id: Int;
    var mouseJoint: B2MouseJoint;
    var maxSpeed = 1.5;

    // how much random variation is applied destination to noise up movement
    var jitterMagnitude = 1;
    var prevNoises = new Array<Vector2D>();
    // how much top speed can fluctuate
    var speedJitterMagnitude = 1;
    var prevSpeedNoises = new Array<Float>();
    
    static var maxID = 0;

    public function new(p: Vector2D) {
        super(p, UNITRADIUS, this);
        destination = p;
        id = maxID++;

        // init physical movement
        var mouse_joint_definition = new B2MouseJointDef();
        mouse_joint_definition.bodyA = PhysicalWorld.dummyCircle.body;
        mouse_joint_definition.bodyB = body;
        mouse_joint_definition.collideConnected = false;
        mouse_joint_definition.target = p;
        mouse_joint_definition.maxForce = 10;
        
        mouseJoint = cast(PhysicalWorld.gameWorld.createJoint(mouse_joint_definition), B2MouseJoint);
        body.setUserData(this);

        MessageManager.send(new NewUnit(this));
        MessageManager.addListener(this);
    }

    public function hashCode() : Int {
        return id;
    }

    public function update(dt:Float) {
        // set destination with some noise
        var noise = new Vector2D(jitterMagnitude, 0).rotate(RNGManager.randomAngle());
        prevNoises.push(noise);
        var average_noise = new Vector2D();
        for (n in prevNoises)
            average_noise += n;
        average_noise /= prevNoises.length;
        if (prevNoises.length > 10)
            prevNoises.shift();
        mouseJoint.setTarget(destination + average_noise);

        // apply jitter
        // might be good for showing morale, etc.
        // body.applyForce(new Vector2D(jitterMagnitude, 0).rotate(RNGManager.rand.randomAngle()), body.getPosition());

        // impose speed limit
        var speed_noise = RNGManager.rand.srand(speedJitterMagnitude);
        prevSpeedNoises.push(speed_noise);
        var average_speed_noise = 0.0;
        for (n in prevSpeedNoises)
            average_speed_noise += n;
        average_speed_noise /= prevSpeedNoises.length;
        if (prevSpeedNoises.length > 10)
            prevSpeedNoises.shift();
        var vel: Vector2D = body.getLinearVelocity();
        var speed = maxSpeed + average_speed_noise;
        if (vel.magnitude > maxSpeed) {
            body.setLinearVelocity(speed*vel.normalize());
        }

        mouseJoint.setMaxForce(10*speed);
    }



    public function receive(msg:Message):Bool {
        return false;
    }

    public function marchTo(arg:Vector2D, facing:Float) {
        throw new haxe.exceptions.NotImplementedException();
    }
}