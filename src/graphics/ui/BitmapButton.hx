package graphics.ui;

import hxd.Event;
import h2d.col.PolygonCollider;
import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;

class BitmapButton extends Bitmap {

	public function new(enabled:Tile, disabled:Tile, hover:Tile, active:Tile, loading:Tile, p:Object, onClick:() -> Void) {
        super(enabled, p);

        // I think using width\height doesn't centre the interactive bounds correctly, may need to use our own polygon
        // var w = t.width;
        // var polys = {};
        // new h2d.Interactive(0, 0, this, new PolygonCollider(polys, true)).onClick = function(event:Event) { f(); };

        // button states
        var i = new h2d.Interactive(enabled.width, enabled.height, this);
        i.onClick = (event:Event) -> {
            onClick(); 
            tile = active;
            Main.tweenManager.delay(0.25, () -> {tile = loading;});
            Main.tweenManager.delay(0.5, () -> {tile = i.isOver() ? hover : enabled;});
        };
        i.onOver = (e: Event) -> {
            tile = hover;
        };
        i.onOut = (e: Event) -> {
            tile = enabled;
        };

    }
}

class TriangleButton extends BitmapButton {
    public function new(p:Object, onClick:() -> Void, y_flip=false) {
        super(hxd.Res.img.ui.TriangleButton.Enabled.toTile().center(),
              hxd.Res.img.ui.TriangleButton.Disabled.toTile().center(),
              hxd.Res.img.ui.TriangleButton.Hover.toTile().center(),
              hxd.Res.img.ui.TriangleButton.Active.toTile().center(),
              hxd.Res.img.ui.TriangleButton.Loading.toTile().center(),
              p, onClick);
        scaleY = y_flip ? -1 : 1;
    }
}