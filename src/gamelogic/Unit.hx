package gamelogic;

import utilities.Constants.floatToStringPrecision;
import utilities.MessageManager;
import gamelogic.physics.CircularPhysicalGameObject;
import gamelogic.physics.PhysicalWorld;
import box2D.dynamics.joints.B2MouseJoint;
import box2D.dynamics.joints.B2MouseJointDef;
import utilities.Vector2D;

class Unit extends CircularPhysicalGameObject implements MessageListener implements Updateable {
    public var position: Vector2D;
    public var destination: Vector2D;
    public var id: Int;
    public var owner: Int;
    var mouseJoint: B2MouseJoint;
    public var theta = 0.0;
    
    static var maxID = 0;

    public function new(p: Vector2D) {
        super(p, 1, this);
        position = p;
        destination = position;
        id = maxID++;

        // init physical movement
        var mouse_joint_definition = new B2MouseJointDef();
        mouse_joint_definition.bodyA = PhysicalWorld.dummyCircle.body;
        mouse_joint_definition.bodyB = body;
        mouse_joint_definition.collideConnected = false;
        mouse_joint_definition.target = position;
        mouse_joint_definition.maxForce = 10000;
        mouse_joint_definition.dampingRatio = 10;
        mouse_joint_definition.frequencyHz = 10;
        
        mouseJoint = cast(PhysicalWorld.gameWorld.createJoint(mouse_joint_definition), B2MouseJoint);
        body.setUserData(this);

        MessageManager.addListener(this);

        // tween test
        Main.tweenManager.animateFromTo(this, {theta: 0}, {theta: Math.PI*2}, 2).repeat().start();
    }

    public function hashCode() : Int {
        return id;
    }

    public function update(dt:Float) {
        destination = new Vector2D(100, 0).rotate(theta);
        mouseJoint.setTarget(destination);
        var d = PHYSICSCALEINVERT*destination;
        var p = body.getPosition();
        // trace(floatToStringPrecision(theta/(Math.PI*2), 2));
        // trace(floatToStringPrecision(d.x, 2), floatToStringPrecision(p.x, 2), floatToStringPrecision(p.x - d.x, 2));
        // trace(floatToStringPrecision(d.y, 2), floatToStringPrecision(p.y, 2), floatToStringPrecision(p.y - d.y, 2));
    }

	public function receiveMessage(msg:Message):Bool {
        return false;
	}
}