import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.defines.Input;
import skyui.util.ConfigLoader;
import skyui.util.GlobalFunctions;
import skyui.components.list.ListLayout;
import skyui.components.list.SortedListHeader;
import skyui.components.list.ScrollingList;
import skyui.filter.IFilter;
import skyui.util.ConfigManager;


class MainList extends skyui.components.list.ScrollingList
{
  /* PRIVATE VARIABLES */

	private var _previousColumnKey: Number = -1;
	private var _nextColumnKey: Number = -1;
	private var _sortOrderKey: Number = -1;	
	
  /* PROPERTIES */ 
	
	public var entryWidth: Number = 170;

	/* PRIVATE */

	private var _maxEntryWidthCount;
	private var _listWidth;

	// @Override ScrollingList
	public function set scrollPosition(a_newPosition: Number)
	{
		a_newPosition -= a_newPosition % _maxEntryWidthCount;
		if (a_newPosition == _scrollPosition || a_newPosition < 0 || a_newPosition > _maxScrollPosition)
			return;
			
		if (scrollbar != undefined)
			scrollbar.position = a_newPosition;
		else
			updateScrollPosition(a_newPosition);
	}

  /* INITIALIZATION */

	public function MainList()
	{
		super();

		_listWidth = background._width - leftBorder - rightBorder;
		_maxEntryWidthCount = Math.floor(_listWidth / entryWidth);
		_maxListIndex = Math.floor(_listHeight / entryHeight) * _maxEntryWidthCount;
	}

	// @override ScrollingList
	public function onLoad(): Void
	{
		if (scrollbar != undefined) {
			scrollbar.position = 0;
			scrollbar.addEventListener("scroll", this, "onScroll");
			scrollbar._y = topBorder;
			scrollbar.height = _listHeight;
		}
	}

	// @Override ScrollingList
	public function UpdateList(): Void
	{
		if (_bSuspended) {
			_bRequestUpdate = true;
			return;
		}
		// Prepare clips
		setClipCount(_maxListIndex);
		
		var xStart = background._x + leftBorder;
		var yStart = background._y + topBorder;
		var h = 0;
		var w = 0;

		// Clear clipIndex for everything before the selected list portion
		for (var i = 0, ww = 1; i < getListEnumSize() && i < _scrollPosition ; i++)
			getListEnumEntry(i).clipIndex = undefined;

		_listIndex = 0;
		// Display the selected list portion of the list
		for (var i = _scrollPosition; i < getListEnumSize() && _listIndex < _maxListIndex; i++) {
			var entryClip = getClipByIndex(_listIndex);
			var entryItem = getListEnumEntry(i);

			entryClip.itemIndex = entryItem.itemIndex;
			entryItem.clipIndex = _listIndex;
			
			entryClip.setEntry(entryItem, listState);

			entryClip._x = xStart + w;
			entryClip._y = yStart + h;
			entryClip._visible = true;

			if (ww++ % _maxEntryWidthCount) {
				w += entryWidth;
			} else {
				h += entryHeight;
				w = 0;
			}

			++_listIndex;
		}
		
		// Clear clipIndex for everything after the selected list portion
		for (var i = _scrollPosition + _listIndex; i < getListEnumSize(); i++)
			getListEnumEntry(i).clipIndex = undefined;
			
		// Select entry under the cursor for mouse-driven navigation
		if (isMouseDrivenNav)
			for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
				if (e._parent == this && e._visible && e.itemIndex != undefined)
					doSetSelectedIndex(e.itemIndex, SELECT_MOUSE);
					
		if (scrollUpButton != undefined)
			scrollUpButton._visible = _scrollPosition > 0;
		if (scrollDownButton != undefined) 
			scrollDownButton._visible = _scrollPosition < _maxScrollPosition;
	}
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{		
		if (super.handleInput(details, pathToFocus))
			return true;

		return false;
	}

	// @Override ScrollingList
	private function calculateMaxScrollPosition(): Void
 	{
		var m = getListEnumSize();
		var e = m % _maxEntryWidthCount;
		var t = m - _maxListIndex + (e == 0 ? 0 : _maxEntryWidthCount);
		_maxScrollPosition = (t > 0) ? t : 0;

		updateScrollbar();

		if (_scrollPosition > _maxScrollPosition)
			scrollPosition = _maxScrollPosition;
	}
	
	// @Override ScrollingList
	private function updateScrollPosition(a_position: Number): Void
	{
		_scrollPosition = a_position - (a_position % _maxEntryWidthCount);
		UpdateList();
	}
}