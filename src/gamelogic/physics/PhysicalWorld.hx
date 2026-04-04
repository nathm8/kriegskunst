package gamelogic.physics;

import h2d.Scene;
import utilities.Vector2D;
import graphics.HeapsDebugDraw;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;

var PHYSICSCALE = 30;
var PHYSICSCALEINVERT = 1/PHYSICSCALE;

class PhysicalWorld {
    public static var gameWorld: B2World;
    static var debugDraw: HeapsDebugDraw;

    public static function reset() {
        gameWorld = new B2World(new B2Vec2(0, 0), true);
        gameWorld.setContactListener(new ContactListener());
        gameWorld.setContactFilter(new ContactFilter());
    }

    public static function setScene(scene: Scene) {
        debugDraw = new HeapsDebugDraw(scene);
        // gameWorld.setDebugDraw(debugDraw);
    }

    public static function update(dt: Float) {
        gameWorld.step(dt, 1, 1);
        gameWorld.clearForces();
        gameWorld.drawDebugData();
    }
}