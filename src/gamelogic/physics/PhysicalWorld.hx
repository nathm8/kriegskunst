package gamelogic.physics;

import h2d.Scene;
import utilities.Vector2D;
import utilities.MessageManager;
import graphics.HeapsDebugDraw;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;

var PHYSICSCALE = 30;
var PHYSICSCALEINVERT = 1/PHYSICSCALE;

class PhysicalWorld {
    public static var gameWorld = new B2World(new B2Vec2(0, 0), true);
    static var debugDraw: HeapsDebugDraw;
    // used for mouse joints. Not really sure why we need it tbh
    public static var dummyCircle: CircularPhysicalGameObject;

    public static function reset() {
        gameWorld = new B2World(new B2Vec2(0, 0), true);
        gameWorld.setContactListener(new ContactListener());
        gameWorld.setContactFilter(new ContactFilter());
        dummyCircle = new CircularPhysicalGameObject(new Vector2D(), 1, 0);
    }

    public static function setScene(scene: Scene) {
        debugDraw = new HeapsDebugDraw(scene);
        gameWorld.setDebugDraw(debugDraw);
    }

    public static function update(dt: Float) {
        // trace("PWU: start");
        gameWorld.step(dt, 1, 1);
        // trace("PWU: clear");
        gameWorld.clearForces();
        // trace("PWU: send");
        debugDraw.clear();
        gameWorld.drawDebugData();
        MessageManager.sendMessage(new PhysicsStepDoneMessage());
    }
}