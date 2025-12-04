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

function createText(parent:Object, text="") : Text {
    var t = new Text(DefaultFont.get(), parent);
    t.text = text;
    return t;
}

function createFlow(parent:Object, layout:FlowLayout, v_align:FlowAlign, h_align:FlowAlign) : Flow {
    var flow = new Flow(parent);
    flow.debug = true;
    flow.layout = layout;
    flow.horizontalAlign = h_align;
    flow.verticalAlign = v_align;
    flow.horizontalSpacing = 15;
    flow.verticalSpacing = 15;
    flow.padding = 5;
    flow.fillWidth = true;
    return flow;
}

function createLabelTextPair(parent: Object, label: String) : Text {
    return createLabelTextFlowTriplet(parent, label);
}

function createLabelTextFlowTriplet(parent: Object, label: String, ?flow: Flow) : Text {
    var container = createFlow(parent, Horizontal, Middle, Left);
    var label_container = createFlow(container, Horizontal, Top, Left);
    createText(label_container, StringTools.rpad(label, " ", 20));
    var text = createText(label_container);
    if (flow != null) container.addChild(flow);
    return text;
}

class FormationUI extends Flow implements MessageListener {

    var watchedFormation: Int;
    var rowText: Text;
    var rowSpaceText: Text;
    var columnText: Text;
    var columnSpaceText: Text;

    var destinationText: Text;
    var facingText: Text;
    var unitNumberText: Text;
    var positionNumberText: Text;

    public function new(f: Formation, p: Object) {
        super(p);
        debug = true;
        // flow boilerplate
        backgroundTile = Res.img.ui.ScaleGrid.toTile();
        borderWidth = 8;
        borderHeight = 8;
        padding = 5;
        layout = Vertical;
        verticalAlign = Top;
        horizontalAlign = Left;

        watchedFormation = f.id;

        // initialise display of and interaction with formation stats
        createLabelTextPair(this, "id").text = '${f.id}';
        destinationText = createLabelTextPair(this, "destination:");
        facingText = createLabelTextPair(this, "facing:");
        unitNumberText = createLabelTextPair(this, "units:");
        positionNumberText = createLabelTextPair(this, "positions:");

        // columns
        var column_controls = createFlow(null, Vertical, Middle, Left);
        column_controls.verticalSpacing = 30;
        new TriangleButton(column_controls, () -> {f.columns++; updateStats(f);});
        new TriangleButton(column_controls, () -> {if (f.columns == 1) return; f.columns--; updateStats(f);}, true);
        columnText = createLabelTextFlowTriplet(this, "columns:", column_controls);
        
        // new Text(DefaultFont.get(), col_container).text = StringTools.rpad("Spacing:", " ", 10);
        // columnSpaceText = new Text(DefaultFont.get(), col_container);
        // new TriangleButton(col_container, () -> {f.columnSpacing++; updateStats(f);});
        // new TriangleButton(col_container, () -> {if (f.columnSpacing == 1) return; f.columnSpacing--; updateStats(f);}, true);

        // rows
        // var row_container = new Flow(this);
        // row_container.debug = true;
        // row_container.verticalAlign = Middle;
        // row_container.padding = 5;
        // new Text(DefaultFont.get(), row_container).text = StringTools.rpad("Rows:", " ", 10);
        // rowText = new Text(DefaultFont.get(), row_container);
        // new TriangleButton(row_container, () -> {f.rows++; updateStats(f);});
        // new TriangleButton(row_container, () -> {if (f.rows == 1) return; f.rows--; updateStats(f);}, true);
        // new Text(DefaultFont.get(), row_container).text = StringTools.rpad("Spacing:", " ", 10);
        // rowSpaceText = new Text(DefaultFont.get(), row_container);
        // new TriangleButton(row_container, () -> {f.rowSpacing++; updateStats(f);});
        // new TriangleButton(row_container, () -> {if (f.rowSpacing == 1) return; f.rowSpacing--; updateStats(f);}, true);
        
        // prettying up the flow proportions

        // col_labels.minWidth = Math.round(id_labels.calculatedWidth);
        // id_content.minWidth = Math.round(col_content.calculatedWidth);
        // id_container.minWidth = Math.round(col_container.calculatedWidth);

        // TODO
        // interactivity to move window around
        // enableInteractive = true;

        updateStats(f);
        MessageManager.addListener(this);
    }

    function updateStats(f: Formation) {
        destinationText.text = prettyPrintVectorRounded(f.destination);
        facingText.text = floatToStringPrecision((f.targetFacing%2*Math.PI)/(Math.PI), 2)+" pi";
        unitNumberText.text = '${f.units.length}';
        positionNumberText.text = '${f.positions}';

        // rowText.text = StringTools.lpad('${f.rows}', " ", 6);
        // rowSpaceText.text = StringTools.lpad('${f.rowSpacing}', " ", 6);
        
        columnText.text = '${f.columns}';
        // columnSpaceText.text = StringTools.lpad('${f.columnSpacing}', " ", 6);

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