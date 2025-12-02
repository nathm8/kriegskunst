package graphics.ui;

import utilities.MessageManager;
import h2d.Flow;
import h2d.Object;

class FormationUI extends Flow implements MessageListener {

    var watchedFormation: Int;

    public function new(id: Int, p: Object) {
        super(p);
        watchedFormation = id;

        MessageManager.addListener(this);
    }


    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, FormationUpdate)) {
			var params = cast(msg, FormationUpdate);
        }
        return false;
    }
}