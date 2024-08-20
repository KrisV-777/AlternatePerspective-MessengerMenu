import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;
import skyui.components.list.BasicList;
import flash.geom.ColorTransform;
import com.greensock.*;
import com.greensock.easing.*;

class MainListEntry extends BasicListEntry
{
	// Stage

	public var name:TextField;
	public var index:TextField;
	public var modname:TextField;
	public var favorite:MovieClip;
	public var hasSuboptions:MovieClip;
	public var background:MovieClip;

	public var bg_fill:MovieClip;
	public var bg_border:MovieClip;

	// Variables

	private var __width;
	private var __height;

	// Init

	public function MainListEntry()
	{
		super();

		bg_fill = background.fill;
		bg_border = background.border;
	}

	// Public Functions

	// @override BasicListEntry
	public function initialize(a_index:Number, a_list:BasicList):Void
	{
		__width = _width;
		__height = _height;
	}

	// @override BasicListEntry
	public function setEntry(a_entryObject:Object, a_state:ListState):Void
	{
		var selected = a_entryObject == a_state.list.selectedEntry;
		if (a_state.list["_selectDisable"])
			enabled = selected;
		else
			enabled = a_entryObject.enabled;

		var transform = new ColorTransform();
		if (a_entryObject.color) {
			transform.rgb = a_entryObject.color;
		}
		if (a_entryObject.favorite === true) {
			favorite.gotoAndStop("show");
		} else {
			favorite.gotoAndStop("hide");
		}
		bg_border.transform.colorTransform = transform;
		hasSuboptions._visible = a_entryObject.suboptions && a_entryObject.suboptions.length;
		modname.text = a_entryObject.mod;
		index.text = a_entryObject.itemIndex;
		name.text = a_entryObject.text;

		if (selected) {
			_alpha = enabled ? 100 : 25;

			_width = __width;
			_height = __height;
			TweenLite.to(this,0.2,{_width:__width + 2, _height:__height + 2});
		} else {
			_alpha = enabled ? 60 : 15;
			TweenLite.to(this,0.2,{_width:__width, _height:__height});
		}
	}
}