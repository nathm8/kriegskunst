package gamelogic;

import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2BodyDef;
import graphics.BulletGraphics;
import utilities.MessageManager;
import gamelogic.physics.CircularPhysicalGameObject;
import utilities.Vector2D;

final BULLETRADIUS = 0.1;

class Bullet extends CircularPhysicalGameObject implements Updateable {
    
    public var graphics: BulletGraphics;
    public var lifetime: Float;

    public function new(p: Vector2D, facing: Float, i=100.0, l=1.0) {
        var body_definition = new B2BodyDef();
        body_definition.type = B2BodyType.KINEMATIC_BODY;
        body_definition.position = p;
        body_definition.linearDamping = 0.0;
        body_definition.fixedRotation = true;

        super(p, BULLETRADIUS, this);

        lifetime = l;
        body.applyImpulse(new Vector2D(i, 0).rotate(facing), p);

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