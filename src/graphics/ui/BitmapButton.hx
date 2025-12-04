package graphics.ui;

import h2d.col.PixelsCollider;
import h2d.Graphics;
import h2d.col.Point;
import h2d.col.Polygon;
import h2d.col.Polygons;
import hxd.Event;
import h2d.col.PolygonCollider;
import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;

class BitmapButton extends Bitmap {

    static var initialised = false;
    static var pixelsCollider: PixelsCollider;

    public function new(enabled:Tile, disabled:Tile, hover:Tile, active:Tile, loading:Tile, p:Object, onClick:() -> Void) {
    // public function new(enabled:Tile, disabled:Tile, hover:Tile, active:Tile, loading:Tile, p:Object, onClick:() -> Void, polys: Polygons) {
        super(enabled, p);
        if (!initialised) {
            initialised = true;
            pixelsCollider = new PixelsCollider(enabled.getTexture().capturePixels());
        }
        var i = new h2d.Interactive(enabled.width, enabled.height, this, pixelsCollider);
        // var i = new h2d.Interactive(0, 0, this, new PolygonCollider(polys, true));

        // button states
        i.onClick = (event:Event) -> {
            onClick(); 
            tile = active;
            Main.tweenManager.delay(0.1, () -> {tile = loading;}).start();
            Main.tweenManager.delay(0.2, () -> {tile = i.isOver() ? hover : enabled;}).start();
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
        var enabled = hxd.Res.img.ui.TriangleButton.Enabled.toTile();
        var disabled = hxd.Res.img.ui.TriangleButton.Disabled.toTile();
        var hover = hxd.Res.img.ui.TriangleButton.Hover.toTile();
        var active = hxd.Res.img.ui.TriangleButton.Active.toTile();
        var loading = hxd.Res.img.ui.TriangleButton.Loading.toTile();
        super(enabled,
              disabled,
              hover,
              active,
              loading,
              p, onClick);

        if (y_flip)
            scaleY = -1;
    }
}