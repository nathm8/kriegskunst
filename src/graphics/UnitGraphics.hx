package graphics;

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
final MUSKETSCALE = 0.25;

class UnitGraphics extends Object implements Updateable {

    var unit: Unit;
    public var interactive: Interactive;
    var sprite: BasicElement;
    static var spriteTile: Tile = null;
    static var spriteBatch: SpriteBatch = null;
    
    var musket: BasicElement;
    static var musketTile: Tile = null;
    static var musketBatch: SpriteBatch = null;

    private function init() {
        spriteTile = hxd.Res.img.Unit.toTile();
        spriteTile.setCenterRatio(0.5, 0.5);
        spriteBatch = new SpriteBatch(spriteTile, parent);
        
        musketTile = hxd.Res.img.Musket.toTile();
        musketTile.setCenterRatio(0.5, 0.75);
        musketBatch = new SpriteBatch(musketTile, parent);
        musketBatch.hasRotationScale = true;
    }

    public function new(u: Unit, p: Object) {
        super(p);
        if (spriteTile == null)
            init();
        unit = u;
        unit.graphics = this;

        sprite = new BasicElement(spriteTile);
        sprite.r = 0;
        sprite.g = 0;
        sprite.b = 0.66;
        spriteBatch.add(sprite);

        musket = new BasicElement(musketTile);
        musket.scaleX = 0.6;
        musket.scaleY = 0.75;
        musketBatch.add(musket);

        interactive = new Interactive(0, 0, this, new Circle(0, 0, INTERACTIVERADIUSMOD*UNITRADIUS*PHYSICSCALE));
        interactive.onClick = (_) -> {MessageManager.send(new UnitClicked(this.unit));}
    }

    public function update(dt:Float) {
        var p: Vector2D = unit.body.getPosition();
        x = p.x; y = p.y;
        sprite.x = p.x; sprite.y = p.y;
        musket.x = p.x; musket.y = p.y;
        musket.rotation = unit.facing;
        if (musket.rotation < 0)
            musket.scaleX = -1;
        else
            musket.scaleX = 1;

        return false;
    }
}