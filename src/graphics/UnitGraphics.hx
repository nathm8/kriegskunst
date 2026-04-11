package graphics;

import slide.Tween;
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
final hatYOffset = -12.0;

class UnitGraphics extends Object implements Updateable implements MessageListener {

    var unit: Unit;
    public var interactive: Interactive;
    var toCleanup = false;

    static var initialised = false;

    var sprite: BatchElement;
    public var bounceTween: Tween;
    var spriteOffset = new Vector2D(); // for animation
    static var spriteTile: Tile = null;
    static var spriteBatch: SpriteBatch = null;
    
    var musket: BatchElement;
    var musketOffset = new Vector2D(); // for animation
    static var musketTile: Tile = null;
    static var musketBatch: SpriteBatch = null;

    var hat: BatchElement;
    var hatOffset = new Vector2D(); // for animation
    static var hatTile: Tile = null;
    static var hatBatch: SpriteBatch = null;

    private function init() {
        initialised = true;
        spriteTile = hxd.Res.img.Unit.toTile();
        spriteTile.setCenterRatio(0.5, 0.5);
        spriteBatch = new SpriteBatch(spriteTile, parent);
        
        hatTile = hxd.Res.img.Hat1.toTile();
        hatTile.setCenterRatio(0.5, 0.5);
        hatBatch = new SpriteBatch(hatTile, parent);
        hatBatch.hasRotationScale = true;

        musketTile = hxd.Res.img.Musket.toTile();
        musketTile.setCenterRatio(0.5, 0.8);
        musketBatch = new SpriteBatch(musketTile, parent);
        musketBatch.hasRotationScale = true;
    }

    public function new(u: Unit, p: Object) {
        super();
        p.addChildAt(this, 0);
        if (!initialised)
            init();
        unit = u;
        unit.graphics = this;

        sprite = new BatchElement(spriteTile);
        sprite.r = 0;
        sprite.g = 0;
        sprite.b = 0.66;
        spriteBatch.add(sprite);

        bounceTween = Main.tweenManager.animateTo(spriteOffset, { y: 1 }, 1, (t) -> {return 0.5*Math.sin(2*Math.PI*t - Math.PI/2) + 0.5;}).repeat();
        bounceTween.start();

        musket = new BatchElement(musketTile);
        musket.scaleX = 0.75;
        musket.scaleY = 0.75;
        musket.r = 0.6;
        musket.g = 0.6;
        musket.b = 0.6;
        musketBatch.add(musket);

        hat = new BatchElement(hatTile);
        hatBatch.add(hat);

        interactive = new Interactive(0, 0, this, new Circle(0, 0, INTERACTIVERADIUSMOD*unit.params.radius*PHYSICSCALE));
        interactive.onClick = (_) -> {MessageManager.send(new UnitClicked(this.unit));}

        MessageManager.addListener(this);
    }

    public function update(dt:Float) {
        if (unit.body == null)
            return toCleanup;
        var p: Vector2D = unit.body.getPosition();
        var prev_x = x;
        var prev_y = y;
        x = p.x; y = p.y;
        sprite.x = p.x + spriteOffset.x;
        sprite.y = p.y + spriteOffset.y;
        hat.x = p.x + hatOffset.x;
        hat.y = p.y + hatOffset.y + hatYOffset;
        musket.x = p.x + musketOffset.x;
        musket.y = p.y + musketOffset.y;
        musket.rotation = unit.facing;
        if (unit.facing < 0) {
            hat.scaleX = 1;
            musket.scaleX = -0.75;
        } else {
            hat.scaleX = -1;
            musket.scaleX = 0.75;
        }

        if (unit.isMoving)
            bounceTween.resume();
        else
            bounceTween.pause();

        return toCleanup;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, Restart))
            initialised = false;
        if (Std.isOfType(msg, RemoveUnit)) {
            var params = cast(msg, RemoveUnit);
            if (params.unit == unit) {
                Main.tweenManager.animateTo(sprite, {alpha: 0}, 1, SmoothStep.easeIn).start();
                Main.tweenManager.animateTo(hat, {alpha: 0}, 1, SmoothStep.easeIn).start();
                Main.tweenManager.animateTo(musket, {alpha: 0}, 1, SmoothStep.easeIn, () -> {cleanup();}).start();
            }
        }
        return false;
    }

    public function fire() {
        var pos = unit.getMusketMuzzle();
        SmokeGraphics.newSmokeParticle(pos, unit.facing);
        // recoil
        musketOffset = new Vector2D(RNGManager.srand(0.5), 2+RNGManager.srand(0.5)).rotate(unit.facing);
        Main.tweenManager.animateTo(musketOffset, {x: 0, y: 0}, 1, SmoothStep.easeIn).start();
    }

    function cleanup() {
        sprite.remove();
        musket.remove();
        hat.remove();
        interactive.remove();
        remove();
        toCleanup = true;
    }

}