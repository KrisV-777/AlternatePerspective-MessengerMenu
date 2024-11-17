import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.controls.Button;
import Shared.GlobalFunc;

import skyui.components.SearchWidget;
import skyui.components.TabBar;
import skyui.components.list.FilteredEnumeration;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.TabularList;
import skyui.components.list.SortedListHeader;
import skyui.components.list.ScrollingList;
import skyui.filter.ItemTypeFilter;
import skyui.filter.NameFilter;
import skyui.filter.SortFilter;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;
import skyui.util.DialogManager;
import skyui.util.Debug;

import flash.geom.ColorTransform;
import com.greensock.*;
import com.greensock.plugins.*;
import com.greensock.easing.*;

import skyui.defines.Input;
import MessengerMenu;

class OptionList extends MovieClip
{
	/* STAGE ELEMENTS */

	public var titlebar:TextField;
	public var optiondescription:TextField;
	public var mainOptions:MainList;
	public var subOptions:SubList;
	public var background:MovieClip;

	/* PRIVATE VARIABLES */

	private var _platform:Number;

	private var _savedSelectionIndex:Number = -1;

	private var _searchKey:Number = -1;
	private var _sortOrderKeyHeld:Boolean = false;

	private var _disableInput:Boolean;

	private var _greyTransform:Object;
	private var _resetTransform:Object;
	private var _activeList;
	private var _selectedMain;

	/* INITIALIZATION */

	public function OptionList()
	{
		super();
		GlobalFunctions.addArrayFunctions();
		EventDispatcher.initialize(this);
		optiondescription.text = ""

		mainOptions.suspended = true;
		subOptions.suspended = true;
		_disableInput = true;

		TweenPlugin.activate([ColorTransformPlugin]);

		_greyTransform = {redMultiplier:0.25, greenMultiplier:0.25, blueMultiplier:0.25, alphaMultiplier:1};
		_resetTransform = {redMultiplier:1, greenMultiplier:1, blueMultiplier:1, alphaMultiplier:1};
	}

	public function onLoad():Void
	{
		subOptions.listEnumeration = new BasicEnumeration(subOptions.entryList);
		subOptions.addEventListener("itemPress", this, "onItemPressSub");
		// subOptions.addEventListener("itemPressAux", this, "onItemPressSub");

		mainOptions.listEnumeration = new BasicEnumeration(mainOptions.entryList);
		mainOptions.addEventListener("clickDisabled",this,"onClickDisabled");
		mainOptions.addEventListener("selectionChange",this,"onItemsListSelectionChange");
		mainOptions.addEventListener("itemPress",this,"onItemPress");
		// mainOptions.addEventListener("itemPressAux",this,"onItemPress");

		setActiveLists(mainOptions,subOptions);

		mainOptions.suspended = false;
		mainOptions.disableInput = false;
		subOptions.suspended = false;
		subOptions.disableInput = false;
		_disableInput = false;
	}

	public function setItems(options:Array)
	{
		for (var i = 0; i < options.length; i++) {
			mainOptions.entryList.push(options[i]);
		}
		mainOptions.InvalidateData();
	}

	public function setSubOptionItems(options:Array)
	{
		subOptions.clearList();
		for (var i = 0; i < options.length; i++) {
			subOptions.entryList.push(options[i]);
		}
		subOptions.InvalidateData();
	}

	/* PUBLIC FUNCTIONS */

	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent:Function;
	public var dispatchQueue:Function;
	public var hasEventListener:Function;
	public var addEventListener:Function;
	public var removeEventListener:Function;
	public var removeAllEventListeners:Function;
	public var cleanUpEvents:Function;

	// @mixin by Shared.GlobalFunc
	public var Lock:Function;

	public function OnMenuClose():Void
	{
		_disableInput = true;
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}

	public function setPlatform(a_platform:Number, a_bPS3Switch:Boolean):Void
	{
		_platform = a_platform;

		subOptions.setPlatform(a_platform,a_bPS3Switch);
		mainOptions.setPlatform(a_platform,a_bPS3Switch);
	}

	// @GFx
	public function handleInput(details:InputDetails, pathToFocus:Array):Boolean
	{
		if (_disableInput) {
			return false;
		}

		if (_platform != 0) {
			if (_sortOrderKeyHeld) {	 // Disable extra input while interval is active
				return true;
			}
		}

		if (GlobalFunc.IsKeyPressed(details)) {
			switch (details.navEquivalent) {
				case NavigationCode.TAB :
				case NavigationCode.SHIFT_TAB :
				case NavigationCode.ESCAPE :
					{
						if (_selectedMain) {
							setActiveLists(mainOptions,subOptions);
							_selectedMain = null;
							return true;
						}
					};
					break;
			}
			// Search hotkey (default space)
			// if (details.skseKeycode == _searchKey) {
			// searchWidget.startInput();
			// return true;
			// }
		}

		var nextClip = pathToFocus.shift();
		return nextClip.handleInput(details, pathToFocus);
	}

	/* PRIVATE FUNCTIONS */

	private function setActiveLists(activeList, inactiveList)
	{
		activeList.disableInput = false;
		inactiveList.disableInput = true;
		TweenLite.to(activeList,0.3,{colorTransform:_resetTransform, ease:Linear.easeNone});
		TweenLite.to(inactiveList,0.3,{colorTransform:_greyTransform, ease:Linear.easeNone});
		FocusHandler.instance.setFocus(activeList,0);
		_activeList = activeList;
	}

	private function onClickDisabled(event: Object): Void
	{
		setActiveLists(mainOptions, subOptions);
	}

	private function onItemsListSelectionChange(event:Object):Void
	{
		var it = mainOptions.selectedEntry;
		optiondescription.text = it.description;
		setSubOptionItems(it.suboptions);

		if (event.index != -1) {
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
		}
	}

	private function onItemPress(event:Object):Void
	{
		_selectedMain = event.entry;
		if (_selectedMain.suboptions) {
			setActiveLists(subOptions, mainOptions);
			subOptions.setHighlightColor(_selectedMain.color);
			return;
		}
		mainOptions._selectDisable = true;
		mainOptions.InvalidateData();
		var entry = _selectedMain;
		var mod = entry.mod, id = entry.id;
		if (entry.id != MessengerMenu.OPTION_NONE) {
			while (entry.id == MessengerMenu.OPTION_NONE || entry.id == MessengerMenu.OPTION_RANDOM) {
				var r = drawRandom(0, mainOptions.itemCount);
				entry = mainOptions.getNthObj(r);
			}
			// assert entry.id != OPTION_NONE && != OPTION_RANDOM
			trace("Selected: " + entry.text + " (" + entry.id + " / " + entry.mod + ")");
			if (entry.suboptions && entry.suboptions.length) {
				if (entry.suboptions.length > 1 || entry.suboptions[0].id != MessengerMenu.OPTION_RANDOM) {
					do {
						var r = drawRandom(0, entry.suboptions.length);
						var it = entry.suboptions[r];
						mod = it.mod ? it.mod : entry.mod;
						id = it.id;
						trace("Suboption: " + it.text + " (" + id + " / " + mod + ")");
					} while (id == MessengerMenu.OPTION_RANDOM);
				}
			} else {
				id = entry.id;
				mod = entry.mod;
			}
		}
		dispatchEvent({type: "closeMenu", id: id, mod: mod});
	}

	private function onItemPressSub(event:Object):Void
	{
		subOptions._selectDisable = true;
		subOptions.InvalidateData();
		var it = event.entry;
		if (it.id == MessengerMenu.OPTION_RANDOM && _selectedMain.suboptions.length > 1) {
			do {
				var r = drawRandom(0, _selectedMain.suboptions.length);
				it = _selectedMain.suboptions[r];
			} while (it.id == MessengerMenu.OPTION_RANDOM)
		}
		dispatchEvent({type:"closeMenu", id: it.id, mod: it.mod || _selectedMain.mod});
	}

	// rng btw [min, max)
	private function drawRandom(min, max)
	{
		return Math.floor(Math.random() * max) + min
	}

}