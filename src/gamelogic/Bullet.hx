package gamelogic;

import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2BodyDef;
import utilities.MessageManager;
import gamelogic.physics.CircularPhysicalGameObject;
import utilities.Vector2D;

final BULLETRADIUS = 0.05;

class Bullet extends CircularPhysicalGameObject implements Updateable {
    
    public var lifetime: Float;

    public function new(p: Vector2D, facing: Float, i=1000.0, l=1.0) {
        var body_definition = new B2BodyDef();
        body_definition.type = B2BodyType.DYNAMIC_BODY;
        body_definition.position = p;
        body_definition.linearDamping = 0.0;
        body_definition.fixedRotation = true;
        // body_definition.bullet = true;
        body_definition.linearVelocity = new Vector2D(0, -i).rotate(facing);

        super(p, BULLETRADIUS, this, body_definition);
        lifetime = l;

        MessageManager.send(new NewBullet(this));
    }

    public function update(dt:Float) {
        lifetime -= dt;
        if (lifetime <= 0) {
            removePhysics();
            return true;
        }
        return false;
    }
}