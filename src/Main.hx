package;

import slide.TweenManager;
import utilities.SoundManager;
import gamelogic.GameScene;
import gamelogic.physics.PhysicalWorld;
import h2d.col.Point;
import graphics.ui.MainMenu;
import utilities.MessageManager;
import utilities.RNGManager;

class Main extends hxd.App implements MessageListener {

	var gameScene: GameScene;
	public static var tweenManager: TweenManager;

	static function main() {
		new Main();
	}

	override private function init() {
		// boilerplate
		RNGManager.initialise();
		hxd.Res.initEmbed();
		// background
		h3d.Engine.getCurrent().backgroundColor = 0x000000;
		// controls
		hxd.Window.getInstance().addEventTarget(onEvent);	
		// gamelogic
		SoundManager.initialise();
		// mainMenu();
		newGame();
	}
	
	override function update(dt:Float) {
		gameScene?.update(dt);
		tweenManager?.update(dt);
		
	}

	function mainMenu() {
		setScene2D(new MainMenu(newGame));
	}
	
	function newGame() {
		tweenManager?.stopAll();
		tweenManager = new TweenManager();
		RNGManager.reset();
		MessageManager.reset();
		PhysicalWorld.reset();
		SoundManager.reset();
		gameScene = new GameScene();
		setScene2D(gameScene);
		PhysicalWorld.setScene(gameScene);
		MessageManager.addListener(this);
	}

	function onEvent(event:hxd.Event) {
		switch (event.kind) {
			case EPush:
				var p = new Point(event.relX, event.relY);
				s2d.camera.sceneToCamera(p);
				MessageManager.sendMessage(new MouseClick(event, p));
			case ERelease:
				var p = new Point(event.relX, event.relY);
				s2d.camera.sceneToCamera(p);
				MessageManager.sendMessage(new MouseRelease(event, p));
			case EMove:
				var p = new Point(event.relX, event.relY);
				s2d.camera.sceneToCamera(p);
				MessageManager.sendMessage(new MouseMove(event, p));
			case EKeyDown:
				switch (event.keyCode) {
					case hxd.Key.ESCAPE:
						MessageManager.sendMessage(new Restart());
					// case hxd.Key.ENTER:
				}
			case EKeyUp:
				MessageManager.sendMessage(new KeyUp(event.keyCode));
			case _:
		}
	}

	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, Restart)) {
			newGame();
		}
		return false;
	}
}