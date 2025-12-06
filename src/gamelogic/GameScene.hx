package gamelogic;

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
        // camera.layerVisible = (l) -> l != 2;

        MessageManager.addListener(this);

        var f = new Formation(6, 100);
        updateables.push(f);
    }
    
    public function update(dt:Float) {
        // trace("GSU: start");
        PhysicalWorld.update(dt);
        // trace("GSU: world");
        cameraControl();
        for (u in updateables)
            u.update(dt);
        // trace("GSU: updates");
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MouseWheel)) {
            var params = cast(msg, MouseWheel);
            if (params.event.wheelDelta > 0)
                cameraScale *= 0.9;
            else
                cameraScale *= 1.1;
            cameraScale = Math.min(Math.max(cameraMinScale, cameraScale), cameraMaxScale);
            camera.setScale(cameraScale, cameraScale);
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
                return false;
            }
            cameraMovingLeft = params.event.relX < edgeScrollDistance;
            cameraMovingRight = params.event.relX > Window.getInstance().width - edgeScrollDistance;
            cameraMovingUp = params.event.relY < edgeScrollDistance;
            cameraMovingDown = params.event.relY > Window.getInstance().height - edgeScrollDistance;
        } if (Std.isOfType(msg, MouseClick)) {
            var params = cast(msg, MouseClick);
            if (params.event.button == 2)
                middleMouseMoving = true;
        } if (Std.isOfType(msg, MouseRelease)) {
            var params = cast(msg, MouseRelease);
            if (params.event.button == 2)
                middleMouseMoving = false;
        }
        return false;
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
