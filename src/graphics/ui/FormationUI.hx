package graphics.ui;

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
    var colText: Text;
    var colSpaceText: Text;
    var posText: Text;
    var facingText: Text;

    public function new(f: Formation, p: Object) {
        super(p);
        // flow boilerplate
        watchedFormation = f.id;
        borderWidth = 2;
        borderHeight = 2;
        backgroundTile = Res.img.ui.ScaleGrid.toTile();
        enableInteractive = true;
        minHeight = 20;
        minWidth = 60;
        padding = 6;
        layout = Vertical;
        verticalAlign = Top;
        horizontalAlign = Left;

        // initialise display of formation stats
        var id_container = new Flow(this);
        var id_text = new Text(DefaultFont.get(), id_container);
        id_text.text = '$f.id';

        var col_container = new Flow(this);
        StringTools.lpad(new Text(DefaultFont.get(), col_container).text, "Columns:", 10);
        colText = new Text(DefaultFont.get(), col_container);
        StringTools.lpad(new Text(DefaultFont.get(), col_container).text, "Spacing:", 10);
        colSpaceText = new Text(DefaultFont.get(), col_container);

        var row_container = new Flow(this);
        StringTools.lpad(new Text(DefaultFont.get(), row_container).text, "Rows:", 10);
        rowText = new Text(DefaultFont.get(), row_container);
        StringTools.lpad(new Text(DefaultFont.get(), row_container).text, "Spacing:", 10);
        rowSpaceText = new Text(DefaultFont.get(), row_container);
        // set up interactivity to change stats
        // interactivity to move window around

        updateStats(f);
        MessageManager.addListener(this);
    }

    function updateStats(f: Formation) {
        StringTools.lpad(rowText.text, '$f.rows', 4);
        StringTools.lpad(rowSpaceText.text, floatToStringPrecision(f.rowSpacing, 2), 4);
        StringTools.lpad(colText.text, '$f.columns', 4);
        StringTools.lpad(colSpaceText.text, floatToStringPrecision(f.columnSpacing, 2), 4);
    }


    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, FormationUpdate)) {
			var params = cast(msg, FormationUpdate);
            if (params.formation.id == watchedFormation) {
                updateStats(params.formation);
            }
        }
        return false;
    }
}