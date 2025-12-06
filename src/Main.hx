package;

import UIApp;
import graphics.ui.UIScene;
import slide.TweenManager;
import utilities.SoundManager;
import gamelogic.GameScene;
import gamelogic.physics.PhysicalWorld;
import h2d.col.Point;
import utilities.MessageManager;
import utilities.RNGManager;

class Main extends UIApp implements MessageListener {

    var gameScene: GameScene;
    var uiScene: UIScene;
    public static var tweenManager: TweenManager;

    static function main() {
        new Main();
    }

    override private function init() {
        // boilerplate
        RNGManager.initialise();
        hxd.Res.initEmbed();
        // background
        h3d.Engine.getCurrent().backgroundColor = 0x003F05;
        // controls
        hxd.Window.getInstance().addEventTarget(onEvent);    
        // gamelogic
        SoundManager.initialise();
        newGame();
    }
    
    override function update(dt:Float) {
        gameScene?.update(dt);
        uiScene?.update(dt);
        tweenManager?.update(dt);
    }

    function newGame() {
        tweenManager?.stopAll();
        tweenManager = new TweenManager();
        RNGManager.reset();
        MessageManager.reset();
        PhysicalWorld.reset();
        SoundManager.reset();
        uiScene = new UIScene();
        setUI2D(uiScene);
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
                MessageManager.send(new MouseClick(event, p));
            case ERelease:
                var p = new Point(event.relX, event.relY);
                s2d.camera.sceneToCamera(p);
                MessageManager.send(new MouseRelease(event, p));
            case EMove:
                var p = new Point(event.relX, event.relY);
                s2d.camera.sceneToCamera(p);
                MessageManager.send(new MouseMove(event, p));
            case EKeyDown:
                switch (event.keyCode) {
                    case hxd.Key.ESCAPE:
                        MessageManager.send(new Restart());
                }
            case EKeyUp:
                MessageManager.send(new KeyUp(event.keyCode));
            case EWheel:
                var p = new Point(event.relX, event.relY);
                s2d.camera.sceneToCamera(p);
                MessageManager.send(new MouseWheel(event, p));
            case _:
        }
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, Restart)) {
            newGame();
        }
        return false;
    }
}