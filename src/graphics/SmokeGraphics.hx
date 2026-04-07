package graphics;

import utilities.RNGManager;
import utilities.Vector2D;
import utilities.MessageManager;
import h2d.SpriteBatch;
import h2d.Tile;
import h2d.SpriteBatch.BasicElement;
import h2d.Object;
import gamelogic.physics.PhysicalWorld.PHYSICSCALE;
import gamelogic.Bullet;
import gamelogic.Updateable;

class SmokeGraphics extends Object implements Updateable implements MessageListener {
    
    var lifetime = 0.0;
    var totalLifetime: Float;
    var distanceMod: Float;
    var initialBurst: Float;
    var initialVelocity: Float;

    var sprite: BasicElement;
    static var spriteTile: Tile = null;
    static var spriteBatch: SpriteBatch = null;
    static var windDirection: Vector2D;
    static var direction: Vector2D;

    private function init() {
        // spriteTile = hxd.Res.img.Bullet.toTile();
        spriteTile = hxd.Res.img.Smoke.toTile();
        spriteTile.setCenterRatio(0.5, 0.5);
        spriteBatch = new SpriteBatch(spriteTile, parent);
        spriteBatch.hasRotationScale = true;
        windDirection = new Vector2D(1,0).rotate(RNGManager.srand(Math.PI));
        // windDirection = new Vector2D(0,0);
    }

    public function new(pos: Vector2D, dirc: Vector2D, dist: Float, p: Object) {
        super(p);

        if (spriteTile == null)
            init();

        direction = dirc;
        distanceMod = dist;
        initialBurst = 0.05 + RNGManager.srand(0.1, true);
        initialVelocity = 0.75 + RNGManager.srand(0.25, true);
        sprite = new BasicElement(spriteTile);
        sprite.x = pos.x;
        sprite.y = pos.y;
        var c = 1 - RNGManager.srand(0.25, true);
        sprite.r = c;
        sprite.g = c;
        sprite.b = c;
        spriteBatch.smooth = true;
        spriteBatch.add(sprite);

        totalLifetime = RNGManager.normal(15, 5);
        lifetime = totalLifetime;

        MessageManager.addListener(this);
    }

    public function update(dt:Float) {
        if (lifetime > 0) {
            lifetime -= dt;
            // lifetime -= dt * distanceMod;
            var s = 1 - lifetime/totalLifetime;
            // todo, gusts
            var wind_mod = 0.8 + RNGManager.srand(0.2, true);
            sprite.x += wind_mod*10*dt*windDirection.x;
            sprite.y += wind_mod*10*dt*windDirection.y;
            
            // initial velocity from gun
            if (totalLifetime - lifetime < initialBurst) {
                var d = (totalLifetime - lifetime) / initialBurst;
                d = -d*d + 1;
                sprite.x += initialVelocity*300*d*dt*direction.x;
                sprite.y += initialVelocity*300*d*dt*direction.y;
            }
            sprite.scale = Math.pow(s, 3) + 0.1;
            sprite.a = lifetime/totalLifetime;
        } else {
            sprite.remove();
            remove();
        }
        return lifetime <= 0;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, Restart))
            spriteTile = null;
        return false;
    }
}