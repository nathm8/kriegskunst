package gamelogic.physics;

import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.collision.shapes.B2CircleShape;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2BodyType;
import utilities.Vector2D;

class CircularPhysicalGameObject {

    public var body: B2Body;

    public function new(position: Vector2D, radius: Float, userdata: Dynamic) {
        var body_definition = new B2BodyDef();
        body_definition.type = B2BodyType.DYNAMIC_BODY;
        body_definition.position = position;
        body_definition.linearDamping = 0.5;
        body_definition.angularDamping = 0.5;
        var circle = new B2CircleShape();
        circle.setRadius(radius);
        var fixture_definition = new B2FixtureDef();
        fixture_definition.shape = circle;
        fixture_definition.friction = 0.5;
        fixture_definition.restitution = 0.5;
        fixture_definition.density = 0.5;

        body = PhysicalWorld.gameWorld.createBody(body_definition);
        var fix = body.createFixture(fixture_definition);
        fix.setUserData(userdata);
        body.setActive(true);
    }

    public function removePhysics() {
        body.getWorld()?.destroyBody(body);
    }
}

class DummyCircle {
    
    public var body: B2Body;

    public function new(position: Vector2D) {
        var body_definition = new B2BodyDef();
        body_definition.fixedRotation = true;
        body_definition.type = B2BodyType.STATIC_BODY;
        body_definition.position = position;
        var circle = new B2CircleShape();
        circle.setRadius(1);
        var fixture_definition = new B2FixtureDef();
        fixture_definition.shape = circle;
        // no collision with anything
        fixture_definition.filter.categoryBits = 0;
        fixture_definition.filter.maskBits = 0;

        body = PhysicalWorld.gameWorld.createBody(body_definition);
        body.setUserData("DO NOT DRAW");
        body.createFixture(fixture_definition);
    }
}