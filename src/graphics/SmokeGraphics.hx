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
    
    var lifetime: Float;
    var lifetimeElapsed = 0.0;

    var sprite: BasicElement;
    static var spriteTile: Tile = null;
    static var spriteBatch: SpriteBatch = null;
    static var windDirection: Vector2D;

    private function init() {
        spriteTile = hxd.Res.img.Smoke.toTile();
        spriteTile.setCenterRatio(0.5, 0.5);
        spriteBatch = new SpriteBatch(spriteTile, parent);
        spriteBatch.hasRotationScale = true;
        windDirection = new Vector2D(1,0).rotate(RNGManager.srand(Math.PI));
    }

    public function new(b: Bullet, p: Object) {
        super(p);

        if (spriteTile == null)
            init();

        sprite = new BasicElement(spriteTile);
        spriteBatch.add(sprite);

        MessageManager.addListener(this);
    }

    public function update(dt:Float) {
        if (lifetime > 0) {
            sprite.x = (0.5+RNGManager.srand(0.5))*windDirection.x;
            sprite.y = (0.5+RNGManager.srand(0.5))*windDirection.y;
        } else {
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