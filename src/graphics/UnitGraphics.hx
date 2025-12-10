package graphics;

import h2d.Bitmap;
import h2d.col.Circle;
import h2d.Interactive;
import utilities.MessageManager;
import h2d.Graphics;
import gamelogic.physics.PhysicalWorld.PHYSICSCALE;
import gamelogic.Unit;
import h2d.Object;
import gamelogic.Updateable;

// increase hit-circle of unit by this much
final INTERACTIVERADIUSMOD = 1.5;
final MUSKETSCALE = 0.25;

class UnitGraphics extends Object implements Updateable {

    var unit: Unit;
    public var interactive: Interactive;
    var musket: Bitmap;

    public function new(u: Unit, p: Object) {
        super(p);
        unit = u;
        unit.graphics = this;
        var g = new Graphics(this);
        g.lineStyle(1, 0x0000FF);
        g.beginFill(0x0000AA);
        g.drawCircle(0, 0, UNITRADIUS*PHYSICSCALE);
        g.endFill();

        var tile = hxd.Res.img.Musket.toTile();
        tile.setCenterRatio(0.5, 0.8);
        musket = new Bitmap(tile, this);
        musket.scale(MUSKETSCALE);

        interactive = new Interactive(0, 0, this, new Circle(0, 0, INTERACTIVERADIUSMOD*UNITRADIUS*PHYSICSCALE));
        interactive.onClick = (_) ->  {MessageManager.send(new UnitClicked(this.unit));}
    }

    public function update(dt:Float) {
        x = unit.body.getPosition().x * PHYSICSCALE;
        y = unit.body.getPosition().y * PHYSICSCALE;
        musket.rotation = unit.facing;
        if (musket.rotation < 0)
            musket.scaleX = -MUSKETSCALE;
        else
            musket.scaleX = MUSKETSCALE;
    }
}