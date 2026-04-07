package graphics;

import utilities.RNGManager;
import slide.easing.SmoothStep;
import h2d.SpriteBatch;
import h2d.Tile;
import h2d.col.Circle;
import h2d.Interactive;
import h2d.Object;
import utilities.Vector2D;
import utilities.MessageManager;
import gamelogic.physics.PhysicalWorld.PHYSICSCALE;
import gamelogic.Unit;
import gamelogic.Updateable;

// increase hit-circle of unit by this much
final INTERACTIVERADIUSMOD = 1.5;

class UnitGraphics extends Object implements Updateable implements MessageListener {

    var unit: Unit;
    public var interactive: Interactive;
    var toCleanup = false;

    static var initialised = false;

    var sprite: BasicElement;
    static var spriteTile: Tile = null;
    static var spriteBatch: SpriteBatch = null;
    
    var musket: BasicElement;
    static var musketTile: Tile = null;
    static var musketBatch: SpriteBatch = null;

    private function init() {
        initialised = true;
        spriteTile = hxd.Res.img.Unit.toTile();
        spriteTile.setCenterRatio(0.5, 0.5);
        spriteBatch = new SpriteBatch(spriteTile, parent);
        
        musketTile = hxd.Res.img.Musket.toTile();
        musketTile.setCenterRatio(0.5, 0.8);
        musketBatch = new SpriteBatch(musketTile, parent);
        musketBatch.hasRotationScale = true;
    }

    public function new(u: Unit, p: Object) {
        super(p);
        if (!initialised)
            init();
        unit = u;
        unit.graphics = this;

        sprite = new BasicElement(spriteTile);
        sprite.r = 0;
        sprite.g = 0;
        sprite.b = 0.66;
        spriteBatch.add(sprite);

        musket = new BasicElement(musketTile);
        musket.scaleX = 0.75;
        musket.scaleY = 0.75;
        musket.r = 0.6;
        musket.g = 0.6;
        musket.b = 0.6;
        musketBatch.add(musket);

        interactive = new Interactive(0, 0, this, new Circle(0, 0, INTERACTIVERADIUSMOD*unit.params.radius*PHYSICSCALE));
        interactive.onClick = (_) -> {MessageManager.send(new UnitClicked(this.unit));}

        MessageManager.addListener(this);
    }

    public function update(dt:Float) {
        if (unit.body == null)
            return toCleanup;
        var p: Vector2D = unit.body.getPosition();
        x = p.x; y = p.y;
        sprite.x = p.x; sprite.y = p.y;
        musket.x = p.x; musket.y = p.y;
        musket.rotation = unit.facing;
        if (musket.rotation < 0)
            musket.scaleX = -0.75;
        else
            musket.scaleX = 0.75;

        return toCleanup;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, Restart))
            initialised = false;
        if (Std.isOfType(msg, RemoveUnit)) {
            var params = cast(msg, RemoveUnit);
            if (params.unit == unit) {
                Main.tweenManager.animateTo(sprite, {alpha: 0}, 1, SmoothStep.easeIn).start();
                Main.tweenManager.animateTo(musket, {alpha: 0}, 1, SmoothStep.easeIn, () -> {cleanup();}).start();
            }
        }
        return false;
    }

    public function fire() {
        // our position
        var p: Vector2D = unit.body.getPosition();
        // position of the end of our musket, bit clunky, we'll need to generalise this for weapons later
        var q = new Vector2D(0, -20).rotate(unit.facing) + p;
        var dirc = new Vector2D(0, -1).rotate(unit.facing);
        // make a cone in front of the musket barrel, spawn in some smoke particles, with further away ones being
        // slightly larger
        var r = new Vector2D(0, -70).rotate(unit.facing+0.3) + p;
        var s = new Vector2D(0, -70).rotate(unit.facing-0.3) + p;

        for (_ in 0...50 + RNGManager.random(25)) {
            var r1 = RNGManager.srand(1, true);
            var r2 = RNGManager.srand(1, true);
            var pos = r1 * q + (1 - r1)*(r2*r + (1-r2)*s);
            var s = new SmokeGraphics(pos, dirc, r1, parent);
            MessageManager.send(new NewSmoke(s));
        }
    }

    function cleanup() {
        sprite.remove();
        musket.remove();
        interactive.remove();
        remove();
        toCleanup = true;
    }

}