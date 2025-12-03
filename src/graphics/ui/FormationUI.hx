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

    public function new(f: Formation, p: Object) {
        super(p);
        // flow boilerplate
        backgroundTile = Res.img.ui.ScaleGrid.toTile();
        borderWidth = 2;
        borderHeight = 2;
        minHeight = 20;
        minWidth = 60;
        padding = 6;
        layout = Vertical;
        verticalAlign = Top;
        horizontalAlign = Left;

        watchedFormation = f.id;

        // initialise display of and interaction with formation stats
        var id_container = new Flow(this);
        var id_text = new Text(DefaultFont.get(), id_container);
        id_text.text = '${f.id}';
        destinationText = new Text(DefaultFont.get(), id_container);
        destinationText.text = prettyPrintVector(f.destination);

        // columns
        var col_container = new Flow(this);
        col_container.padding = 5;
        new Text(DefaultFont.get(), col_container).text = StringTools.lpad("Columns:", " ", 10);
        columnText = new Text(DefaultFont.get(), col_container);
        new TriangleButton(col_container, () -> {f.columns++; updateStats(f);});
        new TriangleButton(col_container, () -> {if (f.columns == 1) return; f.columns--; updateStats(f);}, true);
        new Text(DefaultFont.get(), col_container).text = StringTools.lpad("Spacing:", " ", 10);
        columnSpaceText = new Text(DefaultFont.get(), col_container);
        new TriangleButton(col_container, () -> {f.columnSpacing++; updateStats(f);});
        new TriangleButton(col_container, () -> {if (f.columnSpacing == 1) return; f.columnSpacing--; updateStats(f);}, true);

        // rows
        var row_container = new Flow(this);
        row_container.padding = 5;
        new Text(DefaultFont.get(), row_container).text = StringTools.lpad("Rows:", " ", 10);
        rowText = new Text(DefaultFont.get(), row_container);
        new TriangleButton(row_container, () -> {f.rows++;});
        new TriangleButton(row_container, () -> {if (f.rows == 1) return; f.rows--;}, true);
        new Text(DefaultFont.get(), row_container).text = StringTools.lpad("Spacing:", " ", 10);
        rowSpaceText = new Text(DefaultFont.get(), row_container);
        new TriangleButton(row_container, () -> {f.rowSpacing++; updateStats(f);});
        new TriangleButton(row_container, () -> {if (f.rowSpacing == 1) return; f.rowSpacing--; updateStats(f);}, true);
        
        // interactivity to move window around
        // enableInteractive = true;

        updateStats(f);
        MessageManager.addListener(this);
    }

    function updateStats(f: Formation) {
        rowText.text = StringTools.lpad('${f.rows}', " ", 6);
        rowSpaceText.text = StringTools.lpad(floatToStringPrecision(f.rowSpacing, 2), " ", 6);
        columnText.text = StringTools.lpad('${f.columns}', " ", 6);
        columnSpaceText.text = StringTools.lpad(floatToStringPrecision(f.columnSpacing, 2), " ", 6);
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