package gamelogic;

import utilities.Constants.prettyPrintVector;
import utilities.Constants.floatToStringPrecision;
import utilities.MessageManager;
import gamelogic.physics.CircularPhysicalGameObject;
import gamelogic.physics.PhysicalWorld;
import box2D.dynamics.joints.B2MouseJoint;
import box2D.dynamics.joints.B2MouseJointDef;
import utilities.Vector2D;

class Unit extends CircularPhysicalGameObject implements MessageListener implements Updateable {
    public var destination: Vector2D;
    public var id: Int;
    var mouseJoint: B2MouseJoint;
    var maxSpeed = 1.5;
    
    static var maxID = 0;

    public function new(p: Vector2D) {
        super(p, 0.2, this);
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

        MessageManager.addListener(this);
    }

    public function hashCode() : Int {
        return id;
    }

    public function update(dt:Float) {
        mouseJoint.setTarget(destination);
        // trace(prettyPrintVector(body.getPosition()), prettyPrintVector(destination));
        // impose speed limit
        var vel: Vector2D = body.getLinearVelocity();
        if (vel.magnitude > maxSpeed)
            body.setLinearVelocity(maxSpeed*vel.normalize());
    }



	public function receiveMessage(msg:Message):Bool {
        return false;
	}

    public function marchTo(arg:Vector2D, facing:Float) {
        throw new haxe.exceptions.NotImplementedException();
    }
}