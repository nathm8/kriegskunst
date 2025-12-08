package gamelogic;

import graphics.FormationGraphics;
import h2d.Camera;
import h2d.col.Point;
import graphics.UnitGraphics;
import hxd.Window;
import h2d.Scene;
import h2d.Text;
import gamelogic.Updateable;
import gamelogic.physics.PhysicalWorld;
import utilities.MessageManager;

class GameScene extends Scene implements MessageListener {
    var updateables = new Array<Updateable>();
    var fpsText: Text;
    var cameraScale = 1.0;
    var cameraMovingLeft = false;
    var cameraMovingRight = false;
    var cameraMovingDown = false;
    var cameraMovingUp = false;
    var edgeScrollDistance = 50;
    var middleMouseMoving = false;
    var prevX = 0.0;
    var prevY = 0.0;

    var cameraMinScale = 0.1;
    var cameraMaxScale = 10.0;

    public function new() {
        super();

        defaultSmooth = true;
        camera.anchorX = 0.5;
        camera.anchorY = 0.5;

        MessageManager.addListener(this);

        // var f = new Formation(6, 100);
        var f = new Formation(10, 10);
        updateables.push(f);
    }
    
    public function update(dt:Float) {
        PhysicalWorld.update(dt);
        cameraControl();
        for (u in updateables)
            u.update(dt);
    }

    public function receive(msg:Message):Bool {
        // camera controls
        if (Std.isOfType(msg, MouseWheel)) {
            var params = cast(msg, MouseWheel);
            if (params.event.wheelDelta > 0)
                cameraScale *= 0.9;
            else
                cameraScale *= 1.1;
            cameraScale = Math.min(Math.max(cameraMinScale, cameraScale), cameraMaxScale);
            camera.setScale(cameraScale, cameraScale);
        }
        if (Std.isOfType(msg, MouseMove)) {
            var params = cast(msg, MouseMove);

            // middle mouse movement
            if (middleMouseMoving) {
                camera.x -= (params.event.relX - prevX)/camera.scaleX;
                camera.y -= (params.event.relY - prevY)/camera.scaleY;
            }
            else {
                // change anchor for zooming
                var prevAbsX = camera.absX;
                var prevAbsY = camera.absY;
                camera.anchorX = params.event.relX / Window.getInstance().width;
                camera.anchorY = params.event.relY / Window.getInstance().height;
                camera.sync(ctx, true);
                var x_diff = prevAbsX - camera.absX;
                var y_diff = prevAbsY - camera.absY;
                camera.x -= x_diff/camera.scaleX;
                camera.y -= y_diff/camera.scaleY;
                camera.sync(ctx, true);
            }
            prevX = params.event.relX;
            prevY = params.event.relY;
            
            // edge scroll
            if (params.event.relX < 0 || params.event.relY < 0 || params.event.relX > Window.getInstance().width || params.event.relY > Window.getInstance().height) {
                cameraMovingLeft = false;
                cameraMovingRight = false;
                cameraMovingUp = false;
                cameraMovingDown = false;
            }
            else {
                cameraMovingLeft = params.event.relX < edgeScrollDistance;
                cameraMovingRight = params.event.relX > Window.getInstance().width - edgeScrollDistance;
                cameraMovingUp = params.event.relY < edgeScrollDistance;
                cameraMovingDown = params.event.relY > Window.getInstance().height - edgeScrollDistance;
            }
        }
        if (Std.isOfType(msg, MouseClick)) {
            var params = cast(msg, MouseClick);
            var p = new Point(params.event.relX, params.event.relY);
            if (params.event.button == 2)
                middleMouseMoving = true;
        }
        if (Std.isOfType(msg, MouseRelease)) {
            var params = cast(msg, MouseRelease);
            if (params.event.button == 2)
                middleMouseMoving = false;
        }
        // graphics
        if (Std.isOfType(msg, NewUnit)) {
            var params = cast(msg, NewUnit);
            newUnit(params.unit);
        }
        if (Std.isOfType(msg, NewFormation)) {
            var params = cast(msg, NewFormation);
            newFormation(params.formation);
        }
        return false;
    }

    function newUnit(u: Unit) {
        updateables.push(new UnitGraphics(u, this));
    }

    function newFormation(f: Formation) {
        new FormationGraphics(f, this);
    }
    
    function cameraControl() {
        if (cameraMovingUp)
            camera.y -= 10/cameraScale;
        if (cameraMovingDown)
            camera.y += 10/cameraScale;
        if (cameraMovingRight)
            camera.x += 10/cameraScale;
        if (cameraMovingLeft)
            camera.x -= 10/cameraScale;
    }

}
