package graphics;

import utilities.Noisemap;
import utilities.RNGManager;
import utilities.Vector2D;
import utilities.MessageManager;
import gamelogic.Updateable;
import h2d.SpriteBatch;
import h2d.Tile;
import h2d.Object;

// gimp procedure to get smoke noise
// four different solid noise maps, with gaussian opacity falloffs from centre
// arrange in 2x2 grid, have particle pick one at random, rotate at random
//
// Solid Noise
// Size 6
// Detail 15
//
// Gaussian blur mask
//
// -30 contrast

class SmokeParticle extends BatchElement {

    var lifetime: Float = 0.0;
    var totalLifetime: Float;
    var initialBurst: Float;
    var initialVelocity: Float;
    var direction: Vector2D;
    var distance: Float;
    var smoke_range = 30.0;
    var initialScale: Float;
    var finalScale: Float;
    var grey: Float;
    var windMod: Float;
    var muzzleFlashTime = 1.0;

    public function new(pos: Vector2D, dirc: Vector2D, bur: Float, vel: Float, dist: Float, t: Tile) {
        super(t);

        direction = dirc;
        initialBurst = bur;
        initialVelocity = vel;
        distance = dist;
        x = pos.x + distance*smoke_range*dirc.x;
        y = pos.y + distance*smoke_range*dirc.y;
        rotation = RNGManager.randomAngle();
        
        // have nearby smoke particles fade quickly, starting small and without expanding too much
        initialScale = 0.05 + 0.25*distance;
        // let further away particles linger and drift while expanding
        dist = dist > 0.6 ? 3*dist : dist;
        finalScale = initialScale + dist*(0.5 + RNGManager.srand(0.5, true));
        totalLifetime = dist*RNGManager.normal(15, 5);

        windMod = RNGManager.normal(1, 0.3);
        if (windMod <= 0.1) windMod = 0.1;
        if (windMod >= 3) windMod = 3;

        // grey = 0.9 - RNGManager.srand(0.35, true);
        grey = 1;
        r =     (1-distance) + grey*distance;
        g = 0.5*(1-distance) + grey*distance;
        b =                    grey*distance;
    }

    // note this is using Heaps' update loop, not our GameScene one.
    // It uses the opposite of the Updateable Bool return convention, true = keep alive
    override function update(dt:Float): Bool {
        lifetime += dt;
        
        // todo, gusts
        var wind = SmokeGraphics.windDirection(new Vector2D(x, y));
        x += windMod*dt*wind.x;
        y += windMod*dt*wind.y;
        
        // initial fade to grey
        if (lifetime < muzzleFlashTime) {
            var d = lifetime/muzzleFlashTime;
            r = (1 - d)*r + d*grey;
            g = (1 - d)*g + d*grey;
            b = (1 - d)*b + d*grey;
        }
        // initial velocity from gun
        if (lifetime < initialBurst) {
            var d = lifetime / initialBurst;
            d = -d*d + 1;
            x += initialVelocity*10*d*dt*direction.x;
            y += initialVelocity*10*d*dt*direction.y;
        }

        // scale size exponentially
        var s = lifetime/totalLifetime;
        var scale_ratio = 1 - Math.pow(2, -10*s);
        scale = initialScale*(1-scale_ratio) + finalScale*scale_ratio;
        // scale opacity linearly
        a = 1 - s;
        if (lifetime >= totalLifetime)
            SmokeGraphics.num--;
        return lifetime < totalLifetime;
    }
}


class SmokeGraphics extends Object implements Updateable implements MessageListener {

    static var spriteTile: Tile = null;
    static var tileAreas: Array<Tile> = null;
    static var spriteBatch: SpriteBatch = null;
    public static var num = 0;
    static var totalTime = 0.0;
    static var windDirc = 0.0;

    private function init() {
        spriteTile = hxd.Res.img.FourSmoke.toTile();
        spriteTile.setCenterRatio(0.5, 0.5);
        tileAreas = spriteTile.gridFlatten(64, -32, -32);
        spriteBatch = new SpriteBatch(spriteTile, parent);
        spriteBatch.smooth = true;
        spriteBatch.hasRotationScale = true;
        spriteBatch.hasUpdate = true;
        
        // TODO some more coherent noise function for wind
        windDirc = RNGManager.randomAngle();
    }

    static public function windDirection(p: Vector2D): Vector2D {
        return new Vector2D(Math.sin(totalTime) + 5, 0).rotate(windDirc);
    }

    public function new(p: Object) {
        super(p);

        if (spriteTile == null)
            init();

        MessageManager.addListener(this);
    }

    static public function newSmokeParticle(pos: Vector2D, facing: Float) {
        var bur = RNGManager.srand(0.5, true);
        var total = 5+RNGManager.random(10);
        num += total;
        for (i in 0...total) {
            var vel = 3 + RNGManager.srand(1);
            var dirc = new Vector2D(0, -1).rotate(facing + RNGManager.srand(0.2));
            var dist = i/total;
            var t = tileAreas[RNGManager.random(tileAreas.length)];
            var particle = new SmokeParticle(pos, dirc, bur, vel, dist, t);
            // TODO: need to do some checks and culling\stealing here to prevent buffer overflow
            spriteBatch.add(particle);
        }
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, Restart))
            spriteTile = null;
        return false;
    }

    public function update(dt:Float):Bool {
        totalTime += dt;
        return false;
    }
}