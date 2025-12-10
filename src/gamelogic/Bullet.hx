package gamelogic;

import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2BodyDef;
import graphics.BulletGraphics;
import utilities.MessageManager;
import gamelogic.physics.CircularPhysicalGameObject;
import utilities.Vector2D;

final BULLETRADIUS = 0.1;

class Bullet extends CircularPhysicalGameObject {
    public var graphics: BulletGraphics;

    public function new(p: Vector2D) {
        var body_definition = new B2BodyDef();
        body_definition.type = B2BodyType.KINEMATIC_BODY;
        body_definition.position = p;
        body_definition.linearDamping = 0.0;
        body_definition.fixedRotation = true;

        super(p, BULLETRADIUS, this);

        MessageManager.send(new NewBullet(this));
    }

}