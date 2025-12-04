package graphics.ui;

import utilities.Utilities.prettyPrintVector;
import graphics.ui.BitmapButton.TriangleButton;
import hxd.res.DefaultFont;
import utilities.Utilities.floatToStringPrecision;
import h2d.Text;
import gamelogic.Formation;
import hxd.Res;
import utilities.MessageManager;
import h2d.Flow;
import h2d.Object;

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
    return flow;
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
        var id_container = createFlow(this, Horizontal, Middle, Left);
        var id_labels  = createFlow(id_container, Vertical, Middle, Left);
        var id_content  = createFlow(id_container, Vertical, Middle, Left);
        createText(id_labels, "id:");
        createText(id_content, '${f.id}');
        createText(id_labels, "destination:");
        destinationText = createText(id_content);
        createText(id_labels, "facing:");
        facingText = createText(id_content);
        createText(id_labels, "units:");
        unitNumberText = createText(id_content);
        createText(id_labels, "posiitons:");
        positionNumberText = createText(id_content);

        // columns
        var col_container = createFlow(this, Horizontal, Middle, Left);
        var col_labels  = createFlow(col_container, Vertical, Middle, Left);
        var col_content  = createFlow(col_container, Vertical, Middle, Left);
        createText(col_labels, "columns:");
        var col_display = createFlow(col_content, Horizontal, Middle, Left);
        columnText = createText(col_display);
        var column_controls = createFlow(col_display, Vertical, Middle, Left);
        column_controls.verticalSpacing = 30;
        new TriangleButton(column_controls, () -> {f.columns++; updateStats(f);});
        new TriangleButton(column_controls, () -> {if (f.columns == 1) return; f.columns--; updateStats(f);}, true);
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
        
        // TODO
        // interactivity to move window around
        // enableInteractive = true;

        updateStats(f);
        MessageManager.addListener(this);
    }

    function updateStats(f: Formation) {
        destinationText.text = prettyPrintVector(f.destination);
        facingText.text = floatToStringPrecision((f.targetFacing%2*Math.PI)/(Math.PI), 2)+" pi";
        unitNumberText.text = '${f.units.length}';
        positionNumberText.text = '${f.positions}';

        // rowText.text = StringTools.lpad('${f.rows}', " ", 6);
        // rowSpaceText.text = StringTools.lpad('${f.rowSpacing}', " ", 6);
        
        columnText.text = '${f.columns}';
        // columnSpaceText.text = StringTools.lpad('${f.columnSpacing}', " ", 6);
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