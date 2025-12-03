package gamelogic;

import graphics.ui.FormationUI;
import h2d.Camera;
import hxd.Key;
import h2d.Scene;
import h2d.Text;
import hxd.Timer;
import gamelogic.Updateable;
import gamelogic.physics.PhysicalWorld;
import utilities.MessageManager;

class GameScene extends Scene implements MessageListener {
    var updateables = new Array<Updateable>();
    var fpsText: Text;
    var cameraScale = 1.0;

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
        return false;
    }

    function cameraControl() {
        if (Key.isDown(Key.A))
            camera.move(-10*1/cameraScale,0);
        if (Key.isDown(Key.D))
            camera.move(10*1/cameraScale,0);
        if (Key.isDown(Key.W))
            camera.move(0,-10*1/cameraScale);
        if (Key.isDown(Key.S))
            camera.move(0,10*1/cameraScale);
        if (Key.isDown(Key.E))
            cameraScale *= 1.1;
        if (Key.isDown(Key.Q))
            cameraScale *= 0.9;
        camera.setScale(cameraScale, cameraScale);
    }

}
