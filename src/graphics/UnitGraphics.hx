package graphics;

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

    static var initialised = false;
    static var circle: Circle;

    public function new(u: Unit, p: Object) {
        super(p);
        unit = u;
        unit.graphics = this;
        var g = new Graphics(this);
        g.lineStyle(1, 0x0000FF);
        g.beginFill(0x0000AA);
        g.drawCircle(0, 0, UNITRADIUS*PHYSICSCALE);
        g.endFill();

        if (!initialised) {
            initialised = true;
            circle = new Circle(0, 0, INTERACTIVERADIUSMOD*UNITRADIUS*PHYSICSCALE);
        }
        interactive = new Interactive(0, 0, this, circle);
        interactive.onClick = (_) ->  {MessageManager.send(new UnitClicked(this.unit));}
    }

    public function update(dt:Float) {
        x = unit.body.getPosition().x * PHYSICSCALE;
        y = unit.body.getPosition().y * PHYSICSCALE;
    }
}