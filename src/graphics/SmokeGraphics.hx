package graphics;

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
    var initialScale = 0.05;
    var smoke_range = 30.0;
    var finalScale: Float;
    var grey: Float;

    public function new(pos: Vector2D, dirc: Vector2D, bur: Float, vel: Float, dist: Float, t: Tile) {
        super(t);

        direction = dirc;
        totalLifetime = RNGManager.normal(15, 5);
        initialBurst = bur;
        initialVelocity = vel;
        distance = dist;
        x = pos.x + distance*smoke_range*dirc.x;
        y = pos.y + distance*smoke_range*dirc.y;
        rotation = RNGManager.randomAngle();

        initialScale += 0.25*dist;
        finalScale = 1 + RNGManager.srand(0.5, true);

        // grey = 0.9 - RNGManager.srand(0.35, true);
        grey = 1;
        r =     (1-distance) + grey*distance;
        g = 0.5*(1-distance) + grey*distance;
        b =                    grey*distance;
    }


    final muzzle_flash_time = 1.0;
    // note this is using Heaps' update loop, not our GameScene one.
    // It uses the opposite of the Updateable Bool return convention, true = keep alive
    override function update(dt:Float): Bool {
        lifetime += dt;
        var s = lifetime/totalLifetime;
        // todo, gusts
        // var wind_mod = 0.5 + RNGManager.srand(1);
        // x += wind_mod*10*dt*SmokeGraphics.windDirection.x;
        // wind_mod = 0.5 + RNGManager.srand(1);
        // y += wind_mod*10*dt*SmokeGraphics.windDirection.y;
        
        // initial fade to grey
        if (lifetime < muzzle_flash_time) {
            var d = lifetime/muzzle_flash_time;
            r = (1 - d)*r + d*grey;
            g = (1 - d)*g + d*grey;
            b = (1 - d)*b + d*grey;
        }
        // initial velocity from gun
        // if (lifetime < initialBurst) {
        //     var d = lifetime / initialBurst;
            // d = -d*d + 1;
            // x += initialVelocity*100*d*dt*direction.x;
            // y += initialVelocity*100*d*dt*direction.y;
        // }
        var scale_ratio = Math.pow(s, 2.7);
        scale = initialScale*(1-scale_ratio) + finalScale*scale_ratio;
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
    public static var windDirection: Vector2D;
    public static var num = 0;

    private function init() {
        spriteTile = hxd.Res.img.FourSmoke.toTile();
        spriteTile.setCenterRatio(0.5, 0.5);
        tileAreas = spriteTile.gridFlatten(64, -32, -32);
        spriteBatch = new SpriteBatch(spriteTile, parent);
        spriteBatch.smooth = true;
        spriteBatch.hasRotationScale = true;
        spriteBatch.hasUpdate = true;
        windDirection = new Vector2D(1,0).rotate(RNGManager.srand(Math.PI));
        // TODO have wind speed\direction change via some coherent noise function
    }

    public function new(p: Object) {
        super(p);

        if (spriteTile == null)
            init();

        MessageManager.addListener(this);
    }

    static public function newSmokeParticle(pos: Vector2D, facing: Float) {
        var bur = RNGManager.srand(0.1, true);
        var total = 5+RNGManager.random(10);
        // total = 1;
        num += total;
        for (i in 0...total) {
            var vel = 3 + RNGManager.srand(1);
            var dirc = new Vector2D(0, -1).rotate(facing + RNGManager.srand(0.2));
            var dist = i/total;
            var t = tileAreas[RNGManager.random(tileAreas.length)];
            var particle = new SmokeParticle(pos, dirc, bur, vel, dist, t);
            // need to do some checks and culling\stealing here to prevent buffer overflow
            spriteBatch.add(particle);
        }

        // gettysburg 3:52:54
        // have a very brief moment of orange before going to white

        // have nearby smoke particles fade quickly, without expanding too much
        // let further away particles linger and drift while expanding
        // alternatively
        // have all particles start at musket spout, with velocity such to move
        // forward into the drifty "cloud". This makes more sense than discriminating
        // between particles

        // consider a single\few particles for the flashpan. Kinda expensive and probs
        // won't look that good

        // consider different particle textures (in an atlas)
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, Restart))
            spriteTile = null;
        return false;
    }

    public function update(dt:Float):Bool {
        return false;
    }
}