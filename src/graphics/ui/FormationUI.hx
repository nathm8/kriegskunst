package graphics.ui;

import graphics.ui.ParsingTextInput.ParsingType;
import h2d.Bitmap;
import graphics.ui.BitmapButton.ReticleButton;
import graphics.ui.BitmapButton.RotationButton;
import hxd.Window;
import hxd.Event;
import utilities.Utilities.prettyPrintVectorRounded;
import graphics.ui.BitmapButton.TriangleButton;
import hxd.res.DefaultFont;
import utilities.Utilities.floatToStringPrecision;
import h2d.Text;
import gamelogic.Formation;
import hxd.Res;
import utilities.MessageManager;
import h2d.Flow;
import h2d.Object;

// whether to show box debugging visualisation
var DEBUGFLOWS = false;

function getAllChildren(o: Object) : Array<Object> {
    var out = new Array<Object>();
    for (c in o) {
        out.push(c);
        out = out.concat(getAllChildren(c));
    }
    return out;
}

function createText(parent:Object, text="") : {text: Text, flow: Flow} {
    var f = createFlow(parent, Left, Top);
    var t = new Text(DefaultFont.get(), f);
    t.smooth = false;
    t.scale(2);
    t.text = text;
    return {text: t, flow: f};
}

function createParsingTextInput(parent:Object, callback: (t:ParsingTextInput) -> Void, type: ParsingType) : {text: Text, flow: Flow} {
    var f = createFlow(parent, Left, Top);
    var t: ParsingTextInput;
    switch(type) {
        case Int:
            t = new ParsingTextInput(DefaultFont.get(), Int, f); 
        case Float:
            t = new ParsingTextInput(DefaultFont.get(), Float, f); 
        case Vector2D:
            t = new ParsingTextInput(DefaultFont.get(), Vector2D, f);
    }
    t.onFocus = (_) -> {t.textColor = 0xAAAAAAAA;}
    t.onFocusLost = (_) -> {t.textColor = 0xFFFFFF; callback(t);}
    t.inputWidth = 60;
    t.smooth = false;
    t.scale(2);
    return {text: t, flow: f};
}

function createFlow(parent:Object, layout = FlowLayout.Vertical, h_align = FlowAlign.Middle, v_align = FlowAlign.Middle) : Flow {
    var flow = new Flow(parent);
    flow.debug = DEBUGFLOWS;
    flow.layout = layout;
    flow.horizontalAlign = h_align;
    flow.verticalAlign = v_align;
    flow.padding = 5;
    return flow;
}

// a null callback will result in static data text, instead of an InputText that uses the callback
function createLabelDataControlTriplet(label_container: Flow, label: String, data_container: Flow, callback: (t:ParsingTextInput)->Void, type: ParsingType, control_container: Flow, ?controls: Flow) : Text {
    createText(label_container, label);
    var text: Text;
    if (callback == null)
        text = createText(data_container).text;
    else
        text = createParsingTextInput(data_container, callback, type).text;
    if (controls == null)
        controls = createText(null, " ").flow;
    control_container.addChild(controls);
    return text;
}

class FormationUI extends Flow implements MessageListener {

    var labels: Flow;
    var data: Flow;
    var controls: Flow;

    var watchedFormation: Int;
    var columnText: Text;
    var columnSpaceText: Text;
    var rowText: Text;
    var rowSpaceText: Text;

    var idText: Text;
    var destinationText: Text;
    var facingText: Text;
    var unitNumberText: Text;
    var positionNumberText: Text;

    var isMoving = false;
    var xOffset = 0.0;
    var yOffset = 0.0;
    
    var reticleCursor: Bitmap;

    public function new(f: Formation, p: Object) {
        super(p);
        debug = DEBUGFLOWS;
        // flow boilerplate
        backgroundTile = Res.img.ui.ScaleGrid.toTile();
        borderWidth = 5;
        borderHeight = 13;
        padding = 10;
        layout = Horizontal;
        verticalAlign = Top;
        horizontalAlign = Left;

        watchedFormation = f.id;

        reticleCursor = new Bitmap(hxd.Res.img.ui.ReticleButton.Loading.toTile().center(), parent);
        reticleCursor.visible = false;

        // the core of our UI
        labels = createFlow(this, Vertical, Left, Top);
        data = createFlow(this, Vertical, Left, Top);
        controls = createFlow(this, Vertical, Left, Top);

        // initialise display of and interaction with formation stats
        idText = createLabelDataControlTriplet(labels, "id:", data, null, null, controls);
        var destination_controls = createFlow(null, Horizontal);
        new ReticleButton(destination_controls, () -> {f.listeningForDestination = true; updateStats(f); });
        destinationText = createLabelDataControlTriplet(
            labels, "destination:",
            data, (t:ParsingTextInput) -> {f.destination = t.value; updateStats(f);}, Vector2D,
            controls, destination_controls);
        var facing_controls = createFlow(null, Horizontal);
        new RotationButton(facing_controls, () -> {f.targetFacing+=Math.PI/32; updateStats(f);}, true);
        new RotationButton(facing_controls, () -> {f.targetFacing-=Math.PI/32; updateStats(f);});
        facingText = createLabelDataControlTriplet(
            labels, "facing:",
            data, (t:ParsingTextInput) -> {f.targetFacing = t.value; updateStats(f);}, Float,
            controls, facing_controls);
        unitNumberText = createLabelDataControlTriplet(labels, "units:", data, null, null, controls);
        positionNumberText = createLabelDataControlTriplet(labels, "positions:", data, null, null, controls);

        // rows
        var row_controls = createFlow(null, Horizontal);
        new TriangleButton(row_controls, () -> {f.rows++; updateStats(f);}, Up);
        new TriangleButton(row_controls, () -> {if (f.rows == 1) return; f.rows--; updateStats(f);}, Down);
        rowText = createLabelDataControlTriplet(
            labels, "rows:",
            data, (t:ParsingTextInput) -> {f.rows = t.value; updateStats(f);}, Int,
            controls, row_controls);
        
        var row_spacing_controls = createFlow(null, Horizontal);
        new TriangleButton(row_spacing_controls, () -> {f.rowSpacing++; updateStats(f);}, Up);
        new TriangleButton(row_spacing_controls, () -> {if (f.rowSpacing == 1) return; f.rowSpacing--; updateStats(f);}, Down);
        rowSpaceText = createLabelDataControlTriplet(
            labels, "row spacing:",
            data, (t:ParsingTextInput) -> {f.rowSpacing = t.value; updateStats(f);}, Int,
            controls, row_spacing_controls);

        // columns
        var rowcontrols = createFlow(null, Horizontal);
        new TriangleButton(rowcontrols, () -> {f.columns++; updateStats(f);}, Up);
        new TriangleButton(rowcontrols, () -> {if (f.columns == 1) return; f.columns--; updateStats(f);}, Down);
        columnText = createLabelDataControlTriplet(
            labels, "columns:",
            data, (t:ParsingTextInput) -> {f.columns = t.value; updateStats(f);}, Int,
            controls, rowcontrols);
        
        var rowspacing_controls = createFlow(null, Horizontal);
        new TriangleButton(rowspacing_controls, () -> {f.columnSpacing++; updateStats(f);}, Up);
        new TriangleButton(rowspacing_controls, () -> {if (f.columnSpacing == 1) return; f.columnSpacing--; updateStats(f);}, Down);
        columnSpaceText = createLabelDataControlTriplet(
            labels, "column spacing:",
            data, (t:ParsingTextInput) -> {f.columnSpacing = t.value; updateStats(f);}, Int,
            controls, rowspacing_controls);
        
        // interactivity to move window around
        enableInteractive = true;
        interactive.onPush = (e: Event) -> {
            isMoving = true;
            xOffset = e.relX;
            yOffset = e.relY;
        }
        interactive.onRelease = (e: Event) -> {
            isMoving = false;
        }

        updateStats(f);
        MessageManager.addListener(this);
    }

    function updateStats(f: Formation) {
        idText.text = '${f.id}';
        destinationText.text = prettyPrintVectorRounded(f.destination, true);
        facingText.text = floatToStringPrecision((f.targetFacing%2*Math.PI)/(Math.PI), 2)+" pi";
        unitNumberText.text = '${f.units.length}';
        positionNumberText.text = '${f.columns*f.rows}';

        rowText.text = '${f.rows}';
        rowSpaceText.text = '${f.rowSpacing}';

        columnText.text = '${f.columns}';
        columnSpaceText.text = '${f.columnSpacing}';

        reticleCursor.visible = f.listeningForDestination;

        // flow beautification
        resizeFlows();
        reflow();
    }

    function resizeFlows() {
        var max_height = 0;
        var rows = [labels, data, controls];
        for (i in 0...3) {
            var max_width = 0;
            for (c in getAllChildren(rows[i])) {
                if (Std.isOfType(c, Flow)) {
                    var f = cast(c, Flow);
                    max_width = f.outerWidth > max_width ? f.outerWidth : max_width;
                    max_height = f.outerHeight > max_height ? f.outerHeight : max_height;
                }
            }
            for (c in getAllChildren(rows[i])) {
                if (Std.isOfType(c, Flow)) {
                    var f = cast(c, Flow);
                    f.minWidth = max_width;
                }
            }
        }
        for (i in 0...3)
            for (c in getAllChildren(rows[i]))
                if (Std.isOfType(c, Flow)) {
                    var f = cast(c, Flow);
                    f.minHeight = max_height;
                }
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, FormationUpdate)) {
            var params = cast(msg, FormationUpdate);
            if (params.formation.id == watchedFormation) {
                updateStats(params.formation);
                if (!params.formation.listeningForDestination)
                    reticleCursor.visible = false;
            }
        }
        if (Std.isOfType(msg, MouseMove)) {
            var params = cast(msg, MouseMove);
            if (isMoving) {
                x = params.event.relX - xOffset;
                y = params.event.relY - yOffset;
                if (x < 0) x = 0;
                if (x + outerWidth > Window.getInstance().width) x = Window.getInstance().width - outerWidth;
                if (y < 0) y = 0;
                if (y + outerHeight > Window.getInstance().height) y = Window.getInstance().height - outerHeight;
            }
            reticleCursor.x = params.event.relX;
            reticleCursor.y = params.event.relY;
        }
        return false;
    }
}