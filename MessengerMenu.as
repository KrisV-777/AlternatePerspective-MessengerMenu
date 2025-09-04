import gfx.io.GameDelegate;
import gfx.utils.Delegate;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import gfx.managers.FocusHandler;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.props.PropertyDataExtender;

import skyui.defines.Input;
import skyui.defines.Inventory;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;
import skyui.components.ButtonPanel;

import com.greensock.*;
import com.greensock.easing.*;

class MessengerMenu extends MovieClip
{
	public static var OPTION_NONE = -1;
	public static var OPTION_RANDOM = 0;
	private static var _CSPECIAL = 0xD92F2F;

	/* STAGE */

	public var menu: OptionList;
	public var loadingWidget: MovieClip;
	public var background: MovieClip;

  /* PRIVATE VARIABLES */

	private var _addonCount;
	private var _options;

	// Build Menu

	public function openMenu(/* File Args */)
	{
		_addonCount += 2;
		loadData("../SKSE/AlternatePerspective/AlternatePerspective.json");
		for (var i = 0; i < arguments.length; i++) {
			_addonCount++;
			loadData("../" + arguments[i]);
		}
		addonDone();
	}

	private function validateConditions(entry)
	{
		// IDEA: Add condition parsing
		entry.enabled = true;	
	}

	private function addonDone()
	{
		_addonCount--;
		if (_addonCount == 0) {
			trace(_options.length)
			menu.setItems(_options);
			loadingWidget._visible = false;
			TweenLite.to(menu, 1.0, {_alpha: 100});
		}
	}

  /* INITIALIZATION */

	public function MessengerMenu()
	{
		super();
		Mouse.addListener(this);
		FocusHandler.instance.setFocus(this, 0);

		_addonCount = 0;
		_options = [
			{
				mod: "N/A",
				enabled: true,
				text: "$AltPersp_None",
				description: "$AltPersp_NoneDescr",
				color: _CSPECIAL,
				id: OPTION_NONE
			},
			{
				mod: "N/A",
				enabled: true,
				text: "$AltPersp_Random",
				description: "$AltPersp_RandomDescr",
				color: _CSPECIAL,
				id: OPTION_RANDOM
			}
		];
	}

	public function onLoad(): Void
	{
		_global.gfxExtensions = true;
		
		var minXY: Object = {x: Stage.visibleRect.x + Stage.safeRect.x, y: Stage.visibleRect.y + Stage.safeRect.y};
        var maxXY: Object = {x: Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x, y: Stage.visibleRect.y + Stage.visibleRect.height - Stage.safeRect.y};

        //  (minXY.x, minXY.y) _____________ (maxXY.x, minXY.y)
        //                    |             |
        //                    |     THE     |
        //                    |    STAGE    |
        //  (minXY.x, maxXY.y)|_____________|(maxXY.x, maxXY.y)

		globalToLocal(minXY);
		globalToLocal(maxXY);
		trace("Stage: " + minXY.x + ", " + minXY.y + " - " + maxXY.x + ", " + maxXY.y);

		background._x = (minXY.x + maxXY.x) / 2;
		background._y = (minXY.y + maxXY.y) / 2;
		background._width = maxXY.x - minXY.x;
		background._height = maxXY.y - minXY.y;
		
		var stageMidY = (minXY.y + maxXY.y) / 2;
		var stageHeight = maxXY.y - minXY.y;
		menu._x = (minXY.x + maxXY.x) / 2;
		menu._y = stageMidY - stageMidY * 0.1;
		menu._height = stageHeight * 0.7;
		menu._width = menu._height * 1.76;

		menu.addEventListener("closeMenu", this, "onCloseMenu");

		// setTimeout(Delegate.create(this, test), 1000);
	}

	private function test() {
		var folder = "AlternatePerspective-MessengerMenu";
		openMenu([[folder + "/NewBeginnings.json"]]);
	}

  /* PUBLIC FUNCTIONS */
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (fadedOut())
			return;

		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;

		if (GlobalFunc.IsKeyPressed(details)) {
			switch (details.navEquivalent) {
				case NavigationCode.TAB :
				case NavigationCode.SHIFT_TAB :
				case NavigationCode.ESCAPE :
					{
						onCloseMenu({event: "", id: -1});
					};
					break;
			}
		}
		return true;
	}

	public function onCloseMenu(event: Object) {
		if (!event.mod || !event.id) {
			var err = "Invalid Mod or ModId: " + event.mod + " / " + event.id;
			skse.Log("[Alternate Perspective]" + err);
			trace(err);
			event.mod = "";
			event.id = OPTION_NONE;
		}
		var msg = "Closing Menu with Option " + event.mod + " / " + event.id;
		skse.Log("[Alternate Perspective]" + msg);
		trace(msg);
		skse.SendModEvent("AP_MessengerMenuSelect", event.mod, event.id);
		TweenLite.to(this, 0.6, {_alpha: 0, onComplete: skse.CloseMenu, onCompleteParams: ["CustomMenu"]});
	}

  /* PRIVATE FUNCTIONS */

	private function fadedOut()
	{
		return menu._alpha < 10;
	}

	private function loadData(path)
	{
		var lv = new LoadVars();
		lv.onData = function(src: String) {
			function sortFunc(a, b) {
				if (a.id == 0)
					return -1;
				if (b.id == 0)
					return 1;
				if (a.text < b.text)
					return -1;
				if (a.text > b.text)
					return 1;
				return 0;
			};
			function toString(a) {
				if (a.length == undefined) {
					return parseInt(a)
				} else if (a == "0x") {
					return 0
				}
				var base = 10;
				if (a.length > 2 && a.charAt(0) == '0' && a.charAt(1) == 'x') {
					base = 16;
				} else {
					for (var i = 0; i < a.length; i++) {
						var c = a.charAt(i)
						if (c == 'A' || c == 'B' || c == 'C' || c == 'D' || c == 'E' || c == 'F' ||
									c == 'a' || c == 'b' || c == 'c' || c == 'd' || c == 'e' || c == 'f') {
							base = 16;
							break;
						}
					}
				}
				trace("Converted " + a + " to " + parseInt(a, base) + " with base " + base)
				return parseInt(a, base)
			}
			try{
				var json = JSON.parse(src);
				for (var i = 0; i < json.length; i++) {
					var it = json[i]
					if (it.id) {
						it.id = toString(it.id)
					}
					if (it.suboptions) {
						for (var j = 0; j < it.suboptions.length; j++) {
							var subobj = it.suboptions[j];
							subobj.id = toString(subobj.id);
						}
						it.suboptions.sort(sortFunc);
					}
					lv["_this"].validateConditions(it);
					lv["_this"]._options.push(it);
				}
			} catch(ex) {
				var msg = "Failed to load json file: " + this["path"] + ":" + ex.name + ":" + ex.message + ":" + ex.at + ":" + ex.text
				trace(msg)
				skse.Log("[Alternate Perspective]" + msg)
			}
			lv["_this"].addonDone();
		};
		lv["_this"] = this;
		lv["path"] = path;
		lv.load(path);
	}

}
