package gamelogic.physics;

import gamelogic.physics.CircularPhysicalGameObject.DummyCircle;
import h2d.Scene;
import utilities.Vector2D;
import graphics.HeapsDebugDraw;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;

var PHYSICSCALE = 30;
var PHYSICSCALEINVERT = 1/PHYSICSCALE;

class PhysicalWorld {
    public static var gameWorld = new B2World(new B2Vec2(0, 0), true);
    static var debugDraw: HeapsDebugDraw;
    // used for mouse joints. Not really sure why we need it tbh
    public static var dummyCircle: DummyCircle;

    public static function reset() {
        gameWorld = new B2World(new B2Vec2(0, 0), true);
        gameWorld.setContactListener(new ContactListener());
        gameWorld.setContactFilter(new ContactFilter());
        dummyCircle = new DummyCircle(new Vector2D());
    }

    public static function setScene(scene: Scene) {
        debugDraw = new HeapsDebugDraw(scene);
        gameWorld.setDebugDraw(debugDraw);
    }

    public static function update(dt: Float) {
        gameWorld.step(dt, 1, 1);
        gameWorld.clearForces();
        // gameWorld.drawDebugData();
    }
}