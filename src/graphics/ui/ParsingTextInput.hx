package graphics.ui;

import utilities.Vector2D;
import h2d.Object;
import h2d.Font;
import h2d.TextInput;

class ParsingTextInput<T> extends TextInput {
    public var value(get, null): T;
    var type: T;

    public function new(font:Font, ?parent:Object) {
        super(font, parent);
    }

    override function set_text(t:String) {
        if (!isValid(t)) return text;
		super.set_text(t);
		if( cursorIndex > t.length ) cursorIndex = t.length;
		return t;
	}

    function isValid(t: String) : Bool {
        if (Std.isOfType(type, Int))
            return Std.parseInt(t) != null;
        else if (Std.isOfType(type, Float))
            return Std.parseFloat(t) != Math.NaN;
        else {
            var s = t.split(",");
            return Std.parseFloat(s[0]) != Math.NaN && Std.parseFloat(s[1]) != Math.NaN;
        }
    }

    public function get_value() : T {
        // assuming isValid
        if (Std.isOfType(type, Int))
            return cast Std.parseInt(text);
        else if (Std.isOfType(type, Float))
            return cast Std.parseFloat(text);
        else {
            var s = text.split(",");
            return cast new Vector2D(Std.parseFloat(s[0]), Std.parseFloat(s[1]));
        }
    }
}
