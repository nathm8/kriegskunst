package gamelogic;

import utilities.Vector2D;
import format.abc.Data.ABCData;
import h2d.Camera;
import hxd.Key;
import h2d.Scene;
import h2d.Text;
import h2d.col.Point;
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
		fpsText = new h2d.Text(hxd.res.DefaultFont.get());
		fpsText.visible = true;
		fpsText.x = 1280*0.9;
		fpsText.y = 720*0.9;
		add(fpsText, 2);

		defaultSmooth = true;
		camera.anchorX = 0.5;
		camera.anchorY = 0.5;
		camera.layerVisible = (l) -> l != 2;

		var ui_camera = new Camera();
		ui_camera.layerVisible = (l) -> l == 2;
		addCamera(ui_camera);

		MessageManager.addListener(this);

		var u = new Unit(new Vector2D());
		updateables.push(u);
	}
	
	public function update(dt:Float) {
		// trace("GSU: start");
		PhysicalWorld.update(dt);
		// trace("GSU: world");
		cameraControl();
		for (u in updateables)
			u.update(dt);
		// trace("GSU: updates");
		fpsText.text = Std.string(Math.round(Timer.fps()));
	}

	public function receiveMessage(msg:Message):Bool {
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
