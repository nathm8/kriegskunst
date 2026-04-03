package graphics;

import h2d.SpriteBatch;
import h2d.Tile;
import utilities.MessageManager;
import utilities.MessageManager.MouseMove;
import utilities.Vector2D;
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
    var timeToChooseFace = 0.15;
    var timestamp = 0.0;

    static var spriteTile: Tile = null;
    static var spriteBatch: SpriteBatch = null;

    private function init() {
        spriteTile = hxd.Res.img.Unit.toTile();
        spriteTile.setCenterRatio(0.5, 0.5);
    }

    public function new(f: Formation, ?p: Object) {
        super(p);
        formation = f;

        if (spriteTile == null)
            init();

        MessageManager.addListener(this);
    }

    function initialiseGraphics() {
        spriteBatch?.remove();
        spriteBatch = new SpriteBatch(spriteTile, parent);
        for (p in formation.determineRectangularPositions(new Vector2D(), 0)) {
            var sprite = new BasicElement(spriteTile);
            sprite.r = 0.258;
            sprite.g = 0.258;
            sprite.b = 0.66;
            sprite.a = 0.5;
            sprite.x = p.x;
            sprite.y = p.y;
            spriteBatch.add(sprite);
        }
        spriteBatch.x = formation.destination.x;
        spriteBatch.y = formation.destination.y;
        spriteBatch.rotation = formation.targetFacing;
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
                spriteBatch.x = params.scenePosition.x;
                spriteBatch.y = params.scenePosition.y;
            }
            if (state == ChoosingFacing) {
                if (haxe.Timer.stamp() - timestamp >= timeToChooseFace)
                    spriteBatch.rotation = (params.scenePosition - new Vector2D(spriteBatch.x, spriteBatch.y)).angle() + Math.PI/2;
            }
        }
        if (Std.isOfType(msg, MouseRelease)) {
            var params = cast(msg, MouseRelease);
            if (params.event.button == 0) {
                if (state == Selected) {
                    formation.destination = new Vector2D(spriteBatch.x, spriteBatch.y);
                    formation.sendMarchingOrders();
                    spriteBatch.visible = false;
                    state = None;
                    for (u in formation.units)
                        u.selectable = true;
                    MessageManager.send(new FormationUpdate(formation));
                }
                if (state == ChoosingFacing) {
                    formation.destination = new Vector2D(spriteBatch.x, spriteBatch.y);
                    formation.targetFacing = spriteBatch.rotation;
                    formation.sendMarchingOrders();
                    spriteBatch.visible = false;
                    state = None;
                    for (u in formation.units)
                        u.selectable = true;
                    MessageManager.send(new FormationUpdate(formation));
                }
            }
            if (params.event.button == 1) {
                if (state == Selected) {
                    spriteBatch.visible = false;
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
                    timestamp = haxe.Timer.stamp();
                }
            }
        }
        return false;
    }
}