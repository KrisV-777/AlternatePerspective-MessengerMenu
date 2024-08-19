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
import skyui.util.ConfigManager;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;
import skyui.util.DialogManager;
import skyui.util.Debug;

import skyui.defines.Input;
// import CategoryListV;
// import ExchangeType;

class OptionList extends MovieClip 
{
  /* STAGE ELEMENTS */
  
	public var mainOptions: MainList;
	public var subOptions: ScrollingList;
	public var searchWidget: MovieClip;
	public var titlebar: TextField;
	public var background: MovieClip;

  /* PRIVATE VARIABLES */
	
	private var _platform: Number;
	
	private var _currCategoryIndex: Number;
	private var _savedSelectionIndex: Number = -1;
	
	private var _searchKey: Number = -1;
	private var _switchTabKey: Number = -1;
	private var _sortOrderKey: Number = -1;
	private var _sortOrderKeyHeld: Boolean = false;
	
	// private var _bTabbed = false;
	// private var _leftTabText: String;
	// private var _rightTabText: String;

	private var _columnSelectDialog: MovieClip;
	private var _columnSelectInterval: Number;
	
	private var _disableInput: Boolean;

  /* INITIALIZATION */

	public function OptionList()
	{
		super();
		GlobalFunctions.addArrayFunctions();
		EventDispatcher.initialize(this);

		ConfigManager.registerLoadCallback(this, "onConfigLoad");
		ConfigManager.registerUpdateCallback(this, "onConfigUpdate");

		// categoryList.suspended = true;
		mainOptions.suspended = true;
		_disableInput = true;
	}
	
	public function onLoad(): Void
	{
		mainOptions.listState.maxTextLength = 30;

		// categoryList.addEventListener("itemPress", this, "onCategoriesItemPress");
		// categoryList.addEventListener("itemPressAux", this, "onCategoriesItemPress");
		// categoryList.addEventListener("selectionChange", this, "onCategoriesListSelectionChange");


		mainOptions.listEnumeration = new BasicEnumeration(mainOptions.entryList);
		mainOptions.addEventListener("selectionChange", this, "onItemsListSelectionChange");
		mainOptions.addEventListener("sortChange", this, "onSortChange");

		searchWidget.addEventListener("inputStart", this, "onSearchInputStart");
		searchWidget.addEventListener("inputEnd", this, "onSearchInputEnd");
		searchWidget.addEventListener("inputChange", this, "onSearchInputChange");

		FocusHandler.instance.setFocus(mainOptions, 0);
		// categoryList.suspended = false;
		mainOptions.suspended = false;
		mainOptions.disableInput = false;
		_disableInput = false;
	}

	public function setItems(options: Array)
	{
		for (var i = 0; i < options.length; i++) {
			mainOptions.entryList.push(options[i]);
		}
		mainOptions.InvalidateData();
	}
	
  /* PUBLIC FUNCTIONS */

	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	// @mixin by Shared.GlobalFunc
	public var Lock: Function;

	public function OnMenuClose(): Void
	{
		_disableInput = true;
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}

	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;

		// categoryList.setPlatform(a_platform,a_bPS3Switch);
		mainOptions.setPlatform(a_platform,a_bPS3Switch);
	}

	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (_disableInput)
			return false;

		if (_platform != 0) {
			if (details.skseKeycode == _sortOrderKey) {
				if (details.value == "keyDown") {
					_sortOrderKeyHeld = true;

					if (_columnSelectDialog)
						DialogManager.close();
					else
						_columnSelectInterval = setInterval(this, "onColumnSelectButtonPress", 1000, {type: "timeout"});

					return true;
				} else if (details.value == "keyUp") {
					_sortOrderKeyHeld = false;

					if (_columnSelectInterval == undefined)
						// keyPress handled: Key was released after the interval expired, don't process any further
						return true;

					// keyPress not handled: Clear intervals and change value to keyDown to be processed later
					clearInterval(_columnSelectInterval);
					delete(_columnSelectInterval);
					// Continue processing the event as a normal keyDown event
					details.value = "keyDown";
				} else if (_sortOrderKeyHeld && details.value == "keyHold") {
					// Fix for opening journal menu while key is depressed
					// For some reason this is the only time we receive a keyHold event
					_sortOrderKeyHeld = false;

					if (_columnSelectDialog)
						DialogManager.close();

					return true;
				}
			}

			if (_sortOrderKeyHeld) // Disable extra input while interval is active
				return true;
		}

		if (GlobalFunc.IsKeyPressed(details)) {
			// Search hotkey (default space)
			if (details.skseKeycode == _searchKey) {
				searchWidget.startInput();
				return true;
			}
		}
		
		// if (categoryList.handleInput(details, pathToFocus))
		// 	return true;
		
		var nextClip = pathToFocus.shift();
		return nextClip.handleInput(details, pathToFocus);
	}

	public function getContentBounds():Array
	{
		return [background._x, background._y, background._width, background._height];

		// var lb = panelContainer.ListBackground;
		// return [lb._x, lb._y, lb._width, lb._height];
	}
	
	public function showItemsList(): Void
	{
		// _currCategoryIndex = categoryList.selectedIndex;
		
		// categoryLabel.textField.SetText(categoryList.selectedEntry.text);

		// Start with no selection
		mainOptions.selectedIndex = -1;
		mainOptions.scrollPosition = 0;

		// if (categoryList.selectedEntry != undefined) {
		// 	// Set filter type
		// 	_typeFilter.changeFilterFlag(categoryList.selectedEntry.flag);
			
		// 	// Not set yet before the config is loaded
		// 	mainOptions.layout.changeFilterFlag(categoryList.selectedEntry.flag);
		// }
		 
		mainOptions.requestUpdate();
		
		dispatchEvent({type:"itemHighlightChange", index:mainOptions.selectedIndex});

		mainOptions.disableInput = false;
	}

	// Called whenever the underlying entryList data is updated (using an item, equipping etc.)
	// @API
	public function InvalidateListData(): Void
	{
		// var flag = categoryList.selectedEntry.flag;

		// for (var i = 0; i < categoryList.entryList.length; i++)
		// 	categoryList.entryList[i].filterFlag = categoryList.entryList[i].bDontHide ? 1 : 0;

		// mainOptions.InvalidateData();

		// // Set filter flag = 1 for non-empty categories with bDontHideOffset=false
		// for (var i = 0; i < mainOptions.entryList.length; i++) {
		// 	for (var j = 0; j < categoryList.entryList.length; ++j) {
		// 		if (categoryList.entryList[j].filterFlag != 0)
		// 			continue;

		// 		if (mainOptions.entryList[i].filterFlag & categoryList.entryList[j].flag)
		// 			categoryList.entryList[j].filterFlag = 1;
		// 	}
		// }

		// categoryList.UpdateList();

		// if (flag != categoryList.selectedEntry.flag) {
		// 	// Triggers an update if filter flag changed
		// 	_typeFilter.itemFilter = categoryList.selectedEntry.flag;
		// 	dispatchEvent({type:"categoryChange", index:categoryList.selectedIndex});
		// }
		
		// // This is called when an ItemCard list closes(ex. ShowSoulGemList) to refresh ItemCard data    
		// if (mainOptions.selectedIndex == -1)
		// 	dispatchEvent({type:"showItemsList", index: -1});
		// else
		// 	dispatchEvent({type:"itemHighlightChange", index:mainOptions.selectedIndex});
	}
	
	
  /* PRIVATE FUNCTIONS */
  
  	private function onConfigLoad(event: Object): Void
	{
		var config = event.config;
		_searchKey = config["Input"].controls.pc.search;
		
		if (_platform == 0)
			_switchTabKey = config["Input"].controls.pc.switchTab;
		else {
			_switchTabKey = config["Input"].controls.gamepad.switchTab;
			_sortOrderKey = config["Input"].controls.gamepad.sortOrder;
		}
	}
  
	private function onFilterChange(): Void
	{
		mainOptions.requestInvalidate();
	}
	
	private function onColumnSelectButtonPress(event: Object): Void
	{
		if (event.type == "timeout") {
			clearInterval(_columnSelectInterval);
			delete(_columnSelectInterval);
		}

		if (_columnSelectDialog) {
			DialogManager.close();
			return;
		}
		
		_savedSelectionIndex = mainOptions.selectedIndex;
		mainOptions.selectedIndex = -1;
		
		// categoryList.disableSelection = categoryList.disableInput = true;
		mainOptions.disableSelection = mainOptions.disableInput = true;
		searchWidget.isDisabled = true;
	}
	
	private function onColumnSelectDialogClosed(event: Object): Void
	{
		// categoryList.disableSelection = categoryList.disableInput = false;
		mainOptions.disableSelection = mainOptions.disableInput = false;
		searchWidget.isDisabled = false;
		
		mainOptions.selectedIndex = _savedSelectionIndex;
	}
	
	private function onConfigUpdate(event: Object): Void
	{
		// mainOptions.layout.refresh();
	}

	private function onCategoriesItemPress(): Void
	{
		showItemsList();
	}

	private function onCategoriesListSelectionChange(event: Object): Void
	{
		dispatchEvent({type:"categoryChange", index:event.index});
		
		if (event.index != -1)
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}

	private function onItemsListSelectionChange(event: Object): Void
	{
		dispatchEvent({type:"itemHighlightChange", index:event.index});

		if (event.index != -1)
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}

	private function onSortChange(event: Object): Void
	{
		// _sortFilter.setSortBy(event.attributes, event.options);
	}

	private function onSearchInputStart(event: Object): Void
	{
		// categoryList.disableSelection = categoryList.disableInput = true;
		mainOptions.disableSelection = mainOptions.disableInput = true
		// _nameFilter.filterText = "";
	}

	private function onSearchInputChange(event: Object)
	{
		// _nameFilter.filterText = event.data;
	}

	private function onSearchInputEnd(event: Object)
	{
		// categoryList.disableSelection = categoryList.disableInput = false;
		mainOptions.disableSelection = mainOptions.disableInput = false;
		// _nameFilter.filterText = event.data;
	}

}
