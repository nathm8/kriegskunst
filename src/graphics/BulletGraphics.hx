package graphics;

import h2d.SpriteBatch;
import h2d.Tile;
import h2d.SpriteBatch.BasicElement;
import h2d.Object;
import gamelogic.physics.PhysicalWorld.PHYSICSCALE;
import gamelogic.Bullet;
import gamelogic.Updateable;

class BulletGraphics extends Object implements Updateable {
    
    var bullet: Bullet;

    var sprite: BasicElement;
    static var spriteTile: Tile = null;
    static var spriteBatch: SpriteBatch = null;

    private function init() {
        spriteTile = hxd.Res.img.Bullet.toTile();
        spriteTile.setCenterRatio(0.5, 0.5);
        spriteBatch = new SpriteBatch(spriteTile, parent);
    }

    public function new(b: Bullet, p: Object) {
        super(p);
        bullet = b;

        if (spriteTile == null)
            init();

        sprite = new BasicElement(spriteTile);
        spriteBatch.add(sprite);
    }

    public function update(dt:Float) {
        if (bullet.lifetime > 0) {
            sprite.x = bullet.body.getPosition().x * PHYSICSCALE;
            sprite.y = bullet.body.getPosition().y * PHYSICSCALE;
        } else {
            bullet = null;
            sprite.a = 0.1;
            remove();
        }
        return bullet == null;
    }
}