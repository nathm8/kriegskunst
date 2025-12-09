package graphics;

import utilities.MessageManager;
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

        MessageManager.addListener(this);
    }

    function initialiseGraphics() {
        graphics?.remove();
        graphics = new Graphics(this);
        graphics.lineStyle(1, 0x6666FF, 0.5);
        graphics.beginFill(0x6666AA, 0.5);
        for (p in formation.determineRectangularPositions(new Vector2D(), 0))
            graphics.drawCircle(p.x, p.y, UNITRADIUS*PHYSICSCALE);
        graphics.x = formation.destination.x;
        graphics.y = formation.destination.y;
        graphics.rotation = formation.targetFacing;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, UnitClicked)) {
            if (state != None) return false;
            var unit = cast(msg, UnitClicked).unit;
            if (formation.units.contains(unit)) {
                state = Selected;
                for (u in formation.units)
                    u.selectable = false;
                initialiseGraphics();
            }
        }
        if (Std.isOfType(msg, MouseMove)) {
            var params = cast(msg, MouseMove);
            if (state == Selected) {
                graphics.x = params.scenePosition.x;
                graphics.y = params.scenePosition.y;
            }
            if (state == ChoosingFacing) {
                graphics.rotation = (params.scenePosition - new Vector2D(graphics.x, graphics.y)).angle() + Math.PI/2;
            }
        }
        if (Std.isOfType(msg, MouseRelease)) {
            var params = cast(msg, MouseRelease);
            if (params.event.button == 0) {
                if (state == Selected) {
                    formation.destination = new Vector2D(graphics.x, graphics.y);
                    graphics.visible = false;
                    state = None;
                    for (u in formation.units)
                        u.selectable = true;
                    MessageManager.send(new FormationUpdate(formation));
                }
                if (state == ChoosingFacing) {
                    formation.destination = new Vector2D(graphics.x, graphics.y);
                    formation.targetFacing = graphics.rotation;
                    graphics.visible = false;
                    state = None;
                    for (u in formation.units)
                        u.selectable = true;
                    MessageManager.send(new FormationUpdate(formation));
                }
            }
            if (params.event.button == 1) {
                if (state == Selected) {
                    graphics.visible = false;
                    state = None;
                    for (u in formation.units)
                        u.selectable = true;
                }
            }
        }
        if (Std.isOfType(msg, MousePush)) {
            var params = cast(msg, MousePush);
            if (params.event.button == 0) {
                if (state == Selected) {
                    state = ChoosingFacing;
                }
            }
        }
        return false;
    }
}