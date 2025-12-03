package utilities;

import gamelogic.Formation;
import hxd.Event;
import utilities.Vector2D;

class Message {public function new(){}}

class Restart extends Message {}
class FormationUpdate extends Message {
    public var formation: Formation;
    public function new(f: Formation) {super(); formation = f;}
}
class NewFormation extends Message {
    public var formation: Formation;
    public function new(f: Formation) {super(); formation = f;}
}
class MouseClick extends Message {
    public var event: Event;
    public var worldPosition: Vector2D;
    public function new(e: Event, p: Vector2D) {super(); event = e; worldPosition = p;}
}
class KeyUp extends Message {
    public var keycode: Int;
    public function new(k: Int) {super(); keycode = k;}
}
class MouseRelease extends Message {
    public var event: Event;
    public var worldPosition: Vector2D;
    public function new(e: Event, p: Vector2D) {super(); event = e; worldPosition = p;}
}
class MouseMove extends Message {
    public var event: Event;
    public var worldPosition: Vector2D;
    public function new(e: Event, p: Vector2D) {super(); event = e; worldPosition = p;}
}

interface MessageListener {
    public function receive(msg: Message): Bool;
}

class MessageManager {

    static var listeners = new Array<MessageListener>();

    public static function addListener(l:MessageListener) {
        listeners.push(l);
    }

    public static function removeListener(l:MessageListener) {
        listeners.remove(l);
    }

    public static function send(msg: Message) {
        for (l in listeners)
            if (l.receive(msg)) return;
        // trace("unconsumed message", msg);
    }

    public static function reset() {
        listeners = [];
    }

}