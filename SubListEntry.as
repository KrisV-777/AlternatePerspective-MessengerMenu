import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;
import skyui.components.list.BasicList;
import flash.geom.ColorTransform;
import com.greensock.*;
import com.greensock.easing.*;

class SubListEntry extends BasicListEntry
{
	// Stage

	public var name:TextField;
	public var selectIndicator:MovieClip;
	public var background:MovieClip;
	public var border:MovieClip;

	// Variables

	private var _selected

	// Init

	public function SubListEntry()
	{
		super();
		_selected = false;
	}

	// Public Functions

	// @override BasicListEntry
	public function initialize(a_index:Number, a_list:BasicList):Void
	{
		enabled = true;
	}

	// @override BasicListEntry
	public function setEntry(a_entryObject:Object, a_state:ListState):Void
	{
		name.text = a_entryObject.text;

		var selected = a_entryObject == a_state.list.selectedEntry;
		if (a_state.list["_selectDisable"]) {
			enabled = false;
		} else {
			_selected = selected;
		}

		selectIndicator.clear();
		selectIndicator._visible = _selected;
		if (_selected) {
			_alpha = enabled ? 100 : 25;

			var color = a_entryObject.color || a_state.list["_highLightColor"];
			if (!color) {
				color = 0;
			}

			var gradientType = "radial";
			var colors = [color, 0x454545];
			var alphas = [60, 10];
			var ratios = [15, 255];
			var matrix = {matrixType: "box", x: 0, y: -(_width / 2) + (_height / 2), w: _width, h: _width, r: Math.PI / 2};
			selectIndicator.beginGradientFill(gradientType,colors,alphas,ratios,matrix);
			selectIndicator.moveTo(matrix.x,matrix.y);
			selectIndicator.lineTo(matrix.x + matrix.w,matrix.y);
			selectIndicator.lineTo(matrix.x + matrix.w,matrix.y + matrix.h);
			selectIndicator.lineTo(matrix.x,matrix.y + matrix.h);
			selectIndicator.lineTo(matrix.x,matrix.y);
			selectIndicator.endFill();
		} else {
			_alpha = enabled ? 60 : 15;
		}
	}

}