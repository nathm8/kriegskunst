package graphics;

import gamelogic.physics.PhysicalWorld.PHYSICSCALE;
import gamelogic.Bullet;
import h2d.Graphics;
import gamelogic.Updateable;
import h2d.Object;

class BulletGraphics extends Object implements Updateable {
    
    var bullet: Bullet;

    public function new(b, Bullet, p: Object) {
        super(p);
        bullet = b;

        var g = new Graphics(this);
        g.lineStyle(1, 0x999999);
        g.beginFill(0x999999);
        g.drawCircle(0, 0, BULLETRADIUS*PHYSICSCALE);
        g.endFill();
    }

    public function update(dt:Float) {
        x = bullet.body.getPosition().x * PHYSICSCALE;
        y = bullet.body.getPosition().y * PHYSICSCALE;
    }
}