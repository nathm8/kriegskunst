package gamelogic;

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
            // camera.anchorX = params.event.relX / Window.getInstance().width;
            // camera.anchorY = params.event.relY / Window.getInstance().width;
            cameraScale = Math.min(Math.max(cameraMinScale, cameraScale), cameraMaxScale);
            camera.setScale(cameraScale, cameraScale);
            // camera.anchorX = 0.5;
            // camera.anchorY = 0.5;
        } if (Std.isOfType(msg, MouseMove)) {
            var params = cast(msg, MouseMove);
            if (middleMouseMoving) {
                camera.x -= params.event.relX - prevX;
                camera.y -= params.event.relY - prevY;
            }
            prevX = params.event.relX;
            prevY = params.event.relY;
            if (params.event.relX < 0 || params.event.relY < 0 || params.event.relX > Window.getInstance().width || params.event.relY > Window.getInstance().height) {
                cameraMovingLeft = false;
                cameraMovingRight = false;
                cameraMovingUp = false;
                cameraMovingDown = false;
            } else {
                cameraMovingLeft = params.event.relX < edgeScrollDistance;
                cameraMovingRight = params.event.relX > Window.getInstance().width - edgeScrollDistance;
                cameraMovingUp = params.event.relY < edgeScrollDistance;
                cameraMovingDown = params.event.relY > Window.getInstance().height - edgeScrollDistance;
            }
        } if (Std.isOfType(msg, MouseClick)) {
            var params = cast(msg, MouseClick);
            var p = new Point(params.event.relX, params.event.relY);
            if (params.event.button == 2)
                middleMouseMoving = true;
        } if (Std.isOfType(msg, MouseRelease)) {
            var params = cast(msg, MouseRelease);
            if (params.event.button == 2)
                middleMouseMoving = false;
        }
        // graphics
        if (Std.isOfType(msg, NewUnit)) {
            var params = cast(msg, NewUnit);
            newUnit(params.unit);
        }
        return false;
    }

    function newUnit(u: Unit) {
        updateables.push(new UnitGraphics(u, this));
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
