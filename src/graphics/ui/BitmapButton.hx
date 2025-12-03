package graphics.ui;

import h2d.col.Point;
import h2d.col.Polygon;
import h2d.col.Polygons;
import hxd.Event;
import h2d.col.PolygonCollider;
import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;

class BitmapButton extends Bitmap {

    public function new(enabled:Tile, disabled:Tile, hover:Tile, active:Tile, loading:Tile, p:Object, onClick:() -> Void, polys: Polygons) {
        super(enabled, p);
        var i = new h2d.Interactive(0, 0, this, new PolygonCollider(polys, true));

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
        var poly = [
            new Point(-13, 13),
            new Point(0, -13),
            new Point(13, 13)
            // new Point(-26, 0),
            // new Point(26, -13),
            // new Point(13, 13)
        ];
        if (y_flip) poly.reverse();
        var polys = new Polygons();
        polys.push(new Polygon(poly));

        var enabled = hxd.Res.img.ui.TriangleButton.Enabled.toTile();
        var disabled = hxd.Res.img.ui.TriangleButton.Disabled.toTile();
        var hover = hxd.Res.img.ui.TriangleButton.Hover.toTile();
        var active = hxd.Res.img.ui.TriangleButton.Active.toTile();
        var loading = hxd.Res.img.ui.TriangleButton.Loading.toTile();
        if (y_flip) {
            enabled.flipY();
            disabled.flipY();
            hover.flipY();
            active.flipY();
            loading.flipY();
        }

        super(enabled,
              disabled,
              hover,
              active,
              loading,
              p, onClick, polys);
    }
}