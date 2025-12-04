package graphics.ui;

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

function getAllChildren(o: Object) : Array<Object> {
    var out = new Array<Object>();
    for (c in o) {
        out.push(c);
        out.concat(getAllChildren(c));
    }
    return out;
}

function createText(parent:Object, text="") : {text: Text, flow: Flow} {
    var f = createFlow(parent);
    var t = new Text(DefaultFont.get(), f);
    t.smooth = false;
    t.scale(2);
    t.text = text;
    return {text: t, flow: f};
}

function createFlow(parent:Object, layout = FlowLayout.Vertical, v_align = FlowAlign.Middle, h_align = FlowAlign.Middle) : Flow {
    var flow = new Flow(parent);
    // flow.debug = true;
    flow.layout = layout;
    flow.horizontalAlign = h_align;
    flow.verticalAlign = v_align;
    // TODO, find and apply this automatically
    // whatever flow is the tallest should set the min height for all others
    flow.minHeight = 26*2;
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

    public function new(f: Formation, p: Object) {
        super(p);
        // debug = true;
        // flow boilerplate
        backgroundTile = Res.img.ui.ScaleGrid.toTile();
        borderWidth = 8;
        borderHeight = 8;
        padding = 10;
        layout = Horizontal;
        verticalAlign = Top;
        horizontalAlign = Left;

        watchedFormation = f.id;

        // the core of our UI
        var labels = createFlow(this, Vertical);
        var data = createFlow(this, Vertical);
        data.minWidth = 100;
        var controls = createFlow(this, Vertical);

        // initialise display of and interaction with formation stats
        idText = createLabelDataControlTriplet(labels, "id:", data, controls);
        destinationText = createLabelDataControlTriplet(labels, "destination:", data, controls);
        facingText = createLabelDataControlTriplet(labels, "facing:", data, controls);
        unitNumberText = createLabelDataControlTriplet(labels, "units:", data, controls);
        positionNumberText = createLabelDataControlTriplet(labels, "positions:", data, controls);

        // columns
        var column_controls = createFlow(null, Vertical);
        column_controls.verticalSpacing = 25;
        new TriangleButton(column_controls, () -> {f.columns++; updateStats(f);});
        new TriangleButton(column_controls, () -> {if (f.columns == 1) return; f.columns--; updateStats(f);}, true);
        columnText = createLabelDataControlTriplet(labels, "columns:", data, controls, column_controls);
        
        var column_spacing_controls = createFlow(null, Vertical);
        column_spacing_controls.verticalSpacing = 25;
        new TriangleButton(column_spacing_controls, () -> {f.columnSpacing++; updateStats(f);});
        new TriangleButton(column_spacing_controls, () -> {if (f.columnSpacing == 1) return; f.columnSpacing--; updateStats(f);}, true);
        columnSpaceText = createLabelDataControlTriplet(labels, "column spacing:", data, controls, column_spacing_controls);

        // rows
        var row_controls = createFlow(null, Vertical);
        row_controls.verticalSpacing = 25;
        new TriangleButton(row_controls, () -> {f.rows++; updateStats(f);});
        new TriangleButton(row_controls, () -> {if (f.rows == 1) return; f.rows--; updateStats(f);}, true);
        rowText = createLabelDataControlTriplet(labels, "rows:", data, controls, row_controls);
        
        var row_spacing_controls = createFlow(null, Vertical);
        row_spacing_controls.verticalSpacing = 25;
        new TriangleButton(row_spacing_controls, () -> {f.rowSpacing++; updateStats(f);});
        new TriangleButton(row_spacing_controls, () -> {if (f.rowSpacing == 1) return; f.rowSpacing--; updateStats(f);}, true);
        rowSpaceText = createLabelDataControlTriplet(labels, "row spacing:", data, controls, row_spacing_controls);
        
        // TODO
        // interactivity to move window around
        enableInteractive = true;

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
        reflow();
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, FormationUpdate)) {
            var params = cast(msg, FormationUpdate);
            if (params.formation.id == watchedFormation) {
                updateStats(params.formation);
            }
        }
        return false;
    }
}