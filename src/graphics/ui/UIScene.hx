package graphics.ui;

import hxd.Window;
import graphics.ui.FormationUI;
import h2d.Scene;
import h2d.Text;
import hxd.Timer;
import utilities.MessageManager;

class UIScene extends Scene implements MessageListener {
    var fpsText: Text;

    public function new() {
        super();
        fpsText = new h2d.Text(hxd.res.DefaultFont.get(), this);
        fpsText.visible = true;
        fpsText.x = Window.getInstance().width*0.9;
        fpsText.y = Window.getInstance().height*0.9;

        defaultSmooth = true;

        MessageManager.addListener(this);
    }

    public function update(dt:Float) {
        fpsText.text = Std.string(Math.round(Timer.fps()));
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, NewFormation)) {
            var params = cast(msg, NewFormation);
            var ui = new FormationUI(params.formation, this);
            ui.x = 100;
            ui.y = 100;
        }
        return false;
    }

}
