package graphics.ui;

import h2d.Interactive;
import h2d.Object;
import hxd.Event;
import graphics.ui.FormationUI;
import h2d.Scene;
import h2d.Text;
import hxd.Timer;
import utilities.MessageManager;

class UIScene extends Scene implements MessageListener {
    var fpsText: Text;

    public function new() {
        super();
        fpsText = new h2d.Text(hxd.res.DefaultFont.get(), this);
        fpsText.visible = true;
        fpsText.x = 1280*0.9;
        fpsText.y = 720*0.9;

        defaultSmooth = true;

        MessageManager.addListener(this);

    }

    /**
        Returns the topmost visible Interactive at the specified coordinates.
        Ignoring camera transforms
    **/
    // override public function getInteractive( x : Float, y : Float ) : Interactive {
    //     var pt = shapePoint;
    //     for( i in interactive ) {
    //         if( i.posChanged ) i.syncPos();

    //         var dx = x - i.absX;
    //         var dy = y - i.absY;
    //         var rx = (dx * i.matD - dy * i.matC) * i.invDet;
    //         var ry = (dy * i.matA - dx * i.matB) * i.invDet;

    //         if (i.shape != null) {
    //             pt.set(rx + i.shapeX, ry + i.shapeY);
    //             if ( !i.shape.contains(pt) ) continue;
    //         } else {
    //             if( ry < 0 || rx < 0 || rx >= i.width || ry >= i.height )
    //                 continue;
    //         }

    //         // check visibility
    //         var visible = true;
    //         var p : Object = i;
    //         while( p != null ) {
    //             if( !p.visible ) {
    //                 visible = false;
    //                 break;
    //             }
    //             p = p.parent;
    //         }
    //         if( !visible ) continue;

    //         return i;
    //     }
    //     return null;
    // }

    public function update(dt:Float) {
        fpsText.text = Std.string(Math.round(Timer.fps()));
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, NewFormation)) {
            var params = cast(msg, NewFormation);
            var ui = new FormationUI(params.formation, this);
            ui.x = 100;
            ui.y = 100;
        }
        return false;
    }

}
