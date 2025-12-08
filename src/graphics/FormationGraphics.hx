package graphics;

import utilities.MessageManager.MouseMove;
import utilities.Vector2D;
import gamelogic.Unit.UNITRADIUS;
import gamelogic.physics.PhysicalWorld.PHYSICSCALE;
import h2d.Graphics;
import utilities.MessageManager.UnitClicked;
import gamelogic.Formation;
import h2d.Object;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;

enum FormationUIState {
    None;
    Selected;
    ChoosingFacing;
}

class FormationGraphics extends Object implements MessageListener {

    var formation: Formation;
    var state = None;

    var graphics: Graphics;

    public function new(f: Formation, ?p: Object) {
        super(p);
        formation = f;
    }

    function initialiseGraphics() {
        graphics?.remove();
        graphics = new Graphics(this);
        graphics.lineStyle(1, 0x6666FF, 0.5);
        graphics.beginFill(0x6666AA, 0.5);
        for (p in formation.determineRectangularPositions(new Vector2D(), 0))
            graphics.drawCircle(p.x, p.y, UNITRADIUS*PHYSICSCALE);
        graphics.rotation = formation.targetFacing;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, UnitClicked)) {
            if (state != None) return false;
            var unit = cast(msg, UnitClicked).unit;
            if (formation.units.contains(unit)) {
                state = Selected;
                initialiseGraphics();
                trace("formation selected");
            }
        } if (Std.isOfType(msg, MouseMove)) {
            var params = cast(msg, MouseMove);
            if (state == Selected) {
                graphics.x = params.scenePosition.x;
                graphics.y = params.scenePosition.y;
            } if (state == ChoosingFacing) {
                graphics.rotation = (new Vector2D(graphics.x, graphics.y) - params.scenePosition).angle();
            }
        }
        return false;
    }
}