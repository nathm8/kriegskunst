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

        musket = new Bitmap(hxd.Res.img.Musket.toTile().center(), this);
        musket.scale(0.25);
        musket.rotation = -Math.PI/2;
        musket.x = 5;
        musket.y = -5;

        interactive = new Interactive(0, 0, this, new Circle(0, 0, INTERACTIVERADIUSMOD*UNITRADIUS*PHYSICSCALE));
        interactive.onClick = (_) ->  {MessageManager.send(new UnitClicked(this.unit));}
    }

    public function update(dt:Float) {
        x = unit.body.getPosition().x * PHYSICSCALE;
        y = unit.body.getPosition().y * PHYSICSCALE;
    }
}