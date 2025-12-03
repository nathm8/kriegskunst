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
        minHeight = 20;
        minWidth = 60;
        padding = 8;
        layout = Vertical;
        verticalAlign = Top;
        horizontalAlign = Left;

        watchedFormation = f.id;

        // initialise display of and interaction with formation stats
        var id_container = new Flow(this);
        id_container.debug = true;
        id_container.layout = Vertical;
        id_container.padding = 5;
        var id_text = new Text(DefaultFont.get(), id_container);
        id_text.text = StringTools.rpad("id: ", " ", 15) + '${f.id}';
        destinationText = new Text(DefaultFont.get(), id_container);
        facingText = new Text(DefaultFont.get(), id_container);
        unitNumberText = new Text(DefaultFont.get(), id_container);
        positionNumberText = new Text(DefaultFont.get(), id_container);

        // columns
        var col_container = new Flow(this);
        col_container.debug = true;
        col_container.verticalAlign = Middle;
        col_container.padding = 5;
        new Text(DefaultFont.get(), col_container).text = StringTools.rpad("Columns:", " ", 10);
        columnText = new Text(DefaultFont.get(), col_container);
        new TriangleButton(col_container, () -> {f.columns++; updateStats(f);});
        new TriangleButton(col_container, () -> {if (f.columns == 1) return; f.columns--; updateStats(f);}, true);
        new Text(DefaultFont.get(), col_container).text = StringTools.rpad("Spacing:", " ", 10);
        columnSpaceText = new Text(DefaultFont.get(), col_container);
        new TriangleButton(col_container, () -> {f.columnSpacing++; updateStats(f);});
        new TriangleButton(col_container, () -> {if (f.columnSpacing == 1) return; f.columnSpacing--; updateStats(f);}, true);

        // rows
        var row_container = new Flow(this);
        row_container.debug = true;
        row_container.verticalAlign = Middle;
        row_container.padding = 5;
        new Text(DefaultFont.get(), row_container).text = StringTools.rpad("Rows:", " ", 10);
        rowText = new Text(DefaultFont.get(), row_container);
        new TriangleButton(row_container, () -> {f.rows++; updateStats(f);});
        new TriangleButton(row_container, () -> {if (f.rows == 1) return; f.rows--; updateStats(f);}, true);
        new Text(DefaultFont.get(), row_container).text = StringTools.rpad("Spacing:", " ", 10);
        rowSpaceText = new Text(DefaultFont.get(), row_container);
        new TriangleButton(row_container, () -> {f.rowSpacing++; updateStats(f);});
        new TriangleButton(row_container, () -> {if (f.rowSpacing == 1) return; f.rowSpacing--; updateStats(f);}, true);
        
        // TODO
        // interactivity to move window around
        // enableInteractive = true;

        updateStats(f);
        MessageManager.addListener(this);
    }

    function updateStats(f: Formation) {
        destinationText.text = StringTools.rpad("destination:", " ", 15) + prettyPrintVector(f.destination);
        facingText.text = StringTools.rpad("facing:", " ", 15) + floatToStringPrecision(f.targetFacing/Math.PI, 2);
        unitNumberText.text = StringTools.rpad("units:", " ", 15) + '${f.units.length}';
        positionNumberText.text = StringTools.rpad("positions:", " ", 15) + '${f.positions}';

        rowText.text = StringTools.lpad('${f.rows}', " ", 6);
        rowSpaceText.text = StringTools.lpad('${f.rowSpacing}', " ", 6);
        
        columnText.text = StringTools.lpad('${f.columns}', " ", 6);
        columnSpaceText.text = StringTools.lpad('${f.columnSpacing}', " ", 6);
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