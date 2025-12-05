package graphics.ui;

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
        out.concat(getAllChildren(c));
    }
    return out;
}

function createText(parent:Object, text="") : {text: Text, flow: Flow} {
    var f = createFlow(parent, Left);
    var t = new Text(DefaultFont.get(), f);
    t.smooth = false;
    t.scale(2);
    t.text = text;
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

function createLabelDataControlTriplet(label_container: Flow, label: String, data_container: Flow, control_container: Flow, ?controls: Flow) : Text {
    createText(label_container, label);
    var text = createText(data_container).text;
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
    var rowText: Text;
    var rowSpaceText: Text;
    var columnText: Text;
    var columnSpaceText: Text;

    var idText: Text;
    var destinationText: Text;
    var facingText: Text;
    var unitNumberText: Text;
    var positionNumberText: Text;

    var isMoving = false;
    var xOffset = 0.0;
    var yOffset = 0.0;

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

        // the core of our UI
        labels = createFlow(this, Vertical, Left);
        data = createFlow(this, Vertical, Left);
        controls = createFlow(this, Vertical);

        // initialise display of and interaction with formation stats
        idText = createLabelDataControlTriplet(labels, "id:", data, controls);
        destinationText = createLabelDataControlTriplet(labels, "destination:", data, controls);
        facingText = createLabelDataControlTriplet(labels, "facing:", data, controls);
        unitNumberText = createLabelDataControlTriplet(labels, "units:", data, controls);
        positionNumberText = createLabelDataControlTriplet(labels, "positions:", data, controls);

        // columns
        var column_controls = createFlow(null, Horizontal);
        new TriangleButton(column_controls, () -> {f.columns++; updateStats(f);}, Up);
        new TriangleButton(column_controls, () -> {if (f.columns == 1) return; f.columns--; updateStats(f);}, Down);
        columnText = createLabelDataControlTriplet(labels, "columns:", data, controls, column_controls);
        
        var column_spacing_controls = createFlow(null, Horizontal);
        new TriangleButton(column_spacing_controls, () -> {f.columnSpacing++; updateStats(f);}, Up);
        new TriangleButton(column_spacing_controls, () -> {if (f.columnSpacing == 1) return; f.columnSpacing--; updateStats(f);}, Down);
        columnSpaceText = createLabelDataControlTriplet(labels, "column spacing:", data, controls, column_spacing_controls);

        // rows
        var row_controls = createFlow(null, Horizontal);
        new TriangleButton(row_controls, () -> {f.rows++; updateStats(f);}, Up);
        new TriangleButton(row_controls, () -> {if (f.rows == 1) return; f.rows--; updateStats(f);}, Down);
        rowText = createLabelDataControlTriplet(labels, "rows:", data, controls, row_controls);
        
        var row_spacing_controls = createFlow(null, Horizontal);
        new TriangleButton(row_spacing_controls, () -> {f.rowSpacing++; updateStats(f);}, Up);
        new TriangleButton(row_spacing_controls, () -> {if (f.rowSpacing == 1) return; f.rowSpacing--; updateStats(f);}, Down);
        rowSpaceText = createLabelDataControlTriplet(labels, "row spacing:", data, controls, row_spacing_controls);
        
        // interactivity to move window around
        enableInteractive = true;
        interactive.onPush = (e: Event) -> {
            isMoving = true;
            xOffset = e.relX;
            yOffset=e.relY;
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
        positionNumberText.text = '${f.positions}';

        columnText.text = '${f.columns}';
        columnSpaceText.text = '${f.columnSpacing}';

        rowText.text = '${f.rows}';
        rowSpaceText.text = '${f.rowSpacing}';

        // flow beautification
        var max_height = 0;
        for (c in getAllChildren(this))
            if (Std.isOfType(c, Flow)) {
                var f = cast(c, Flow);
                max_height = f.outerHeight > max_height ? f.outerHeight : max_height;
            }
        var columns = [labels, data, controls];
        for (i in 0...3) {
            var max_width = 0;
            for (c in getAllChildren(columns[i])) {
                if (Std.isOfType(c, Flow)) {
                    var f = cast(c, Flow);
                    max_width = f.outerWidth > max_width ? f.outerWidth : max_width;
                }
            }
            for (c in getAllChildren(columns[i])) {
                if (Std.isOfType(c, Flow)) {
                    var f = cast(c, Flow);
                    f.minWidth = max_width;
                }
            }
        }
        for (c in getAllChildren(this))
            if (Std.isOfType(c, Flow)) {
                var f = cast(c, Flow);
                f.minHeight = max_height;
            }
        reflow();
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, FormationUpdate)) {
            var params = cast(msg, FormationUpdate);
            if (params.formation.id == watchedFormation) {
                updateStats(params.formation);
            }
        } if (Std.isOfType(msg, MouseMove)) {
            var params = cast(msg, MouseMove);
            if (isMoving) {
                x = params.event.relX - xOffset;
                y = params.event.relY - yOffset;
                if (x < 0) x = 0;
                if (x + outerWidth > Window.getInstance().width) x = Window.getInstance().width - outerWidth;
                if (y < 0) y = 0;
                if (y + outerHeight > Window.getInstance().height) y = Window.getInstance().height - outerHeight;
            }
        }
        return false;
    }
}