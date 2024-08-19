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
import skyui.util.ConfigManager;
import skyui.util.Translator;
import skyui.components.ButtonPanel;

import BottomBarEX;
import ShopLists;
import CategoryList;


class MessengerMenu extends MovieClip
{
	private static var _CSPECIAL = 0xD92F2F;

	/* STAGE */

	public var menu: OptionList;
	public var background: MovieClip;

	public var bottomBarEX: MovieClip;
	public var navPanel: ButtonPanel;

  /* PRIVATE VARIABLES */
	// private var _shopItems: Array;	// Forms listed in the shop
	// private var _extraData: Array;	// assert(_extraData[i] == _shopItems[i].extra)

	private var _switchTabKey: Number;
	private var _searchKey: Number;
	private var _searchControls: Object;
	private var _cancelControls: Object;
	private var _acceptControls: Object;
	// Console only controls
	private var _sortColumnControls: Array;
	private var _sortOrderControls: Object;

	private var _platform: Number;


	/* PAPYRUS API */

	public function openMenu(/* File Args */)
	{
		function makeDefault(name, description, id, suboptions) {
			return {
				mod: "AlternatePerspective.esp",
				enabled: true,
				color: 0x31D9E9,
				text: name,
				description: description,
				id: id,
				suboptions: suboptions
			};
		}

		var options: Array = [
			{
				mod: "N/A",
				enabled: true,
				text: "$AltPersp_None",
				description: "Begin your journey in the Resting Pilgrim, Helgen's Inn.",
				color: _CSPECIAL
			},
			{
				mod: "N/A",
				enabled: true,
				text: "$AltPersp_Random",
				description: "Randomly select an available possible starting quest.",
				color: _CSPECIAL,
				id: 0
			},
			makeDefault("$AltPersp_Regular", "$AltPersp_RegularDescr", undefined, [
				{ text: "$AltPersp_Random", id: 0, color: _CSPECIAL },
				{ text: "$AltPersp_TheBanneredMare", id: 0x3271C8 },
				{ text: "$AltPersp_TheBeeandBarb", id: 0x3457D0 },
				{ text: "$AltPersp_TheWinkingSkeever", id: 0x3457D2 },
				{ text: "$AltPersp_SilverBloodInn", id: 0x3457D4 },
				{ text: "$AltPersp_CandlehearthHall", id: 0x3457D6 },
				{ text: "$AltPersp_DeadMansDrink", id: 0x3457D9 },
				{ text: "$AltPersp_MoorsideInn", id: 0x3457DD },
				{ text: "$AltPersp_TheFrozenHearth", id: 0x3457DF },
				{ text: "$AltPersp_WindpeakInn", id: 0x3457E0 },
				{ text: "$AltPersp_TheRetching", id: 0x34A8E2 },
				{ text: "$AltPersp_TheSleeping", id: 0x34A8E3 },
				{ text: "$AltPersp_FrostfruitInn", id: 0x34A8E4 },
				{ text: "$AltPersp_VilemyrInn", id: 0x34A8E5 },
				{ text: "$AltPersp_OldHroldanInn", id: 0x34A8E6 },
				{ text: "$AltPersp_FourShieldsTavern", id: 0x34A8E7 },
				{ text: "$AltPersp_NightgateInn", id: 0x34A8E8 },
				{ text: "$AltPersp_BraidwoodInn", id: 0x34A8E9 }
			]),
			makeDefault("$AltPersp_OverSeas", "$AltPersp_OverSeasDescr", undefined, [
				{ text: "$AltPersp_Random", id: 0, color: _CSPECIAL },
				{ text: "$AltPersp_EastEmpireTradingCompany", id: 0x34F9EC },
				{ text: "$AltPersp_WindhelmDocks", id: 0x34F9EE },
				{ text: "$AltPersp_DawnstarsShore", id: 0x34F9ED },
				{ text: "$AltPersp_RavenRockDocks", id: 0x34F9F0 }
			]),
			makeDefault("$AltPersp_Criminal", "$AltPersp_CriminalDescr", undefined, [
				{ text: "$AltPersp_Random", id: 0, color: _CSPECIAL },
				{ text: "$AltPersp_Whiterun", id: 0x34FA14 },
				{ text: "$AltPersp_TheRift", id: 0x34FA15 },
				{ text: "$AltPersp_ThePale", id: 0x34FA1B },
				{ text: "$AltPersp_Winterhold", id: 0x34FA25 }
			]),
			makeDefault("$AltPersp_LeftForDead", "$AltPersp_LeftForDeadDescr", undefined, [
				{ text: "$AltPersp_Random", id: 0, color: _CSPECIAL },
				{ text: "$AltPersp_TheRift", id: 0x34FA27 },
				{ text: "$AltPersp_TheReach", id: 0x34FA29 },
				{ text: "$AltPersp_Winterhold", id: 0x34FA20 }
			]),
			makeDefault("$AltPersp_Shipwrecked", "$AltPersp_ShipwreckedDescr", 0x3877AC),
			makeDefault("$AltPersp_Home", "$AltPersp_HomeDescr", undefined, [
				{ text: "$AltPersp_Random", id: 0, color: _CSPECIAL },
				{ text: "$AltPersp_Whiterun", id: 0x396AD7 },
				{ text: "$AltPersp_Solitude ", id: 0x3A5DDA },
				{ text: "$AltPersp_Riften", id: 0x3A5DD9 },
				{ text: "$AltPersp_Markarth", id: 0x3A5DD8 }
			]),
			makeDefault("$AltPersp_Vampire", "$AltPersp_VampireDescr", undefined, [
				{ text: "$AltPersp_Random", id: 0, color: _CSPECIAL },
				{ text: "$AltPersp_PinemoonCave", id: 0x3B50DE },
				{ text: "$AltPersp_BloodletThrone", id: 0x3AAEDC },
				{ text: "$AltPersp_MovarthsLair", id: 0x3B50E0 },
				{ text: "$AltPersp_HaemarsShame", id: 0x3B50DF }
			]),
			makeDefault("$AltPersp_Werewolf", "$AltPersp_WerewolfDescr", 0x3AAEDD),
			makeDefault("$AltPersp_Forsworn", "$AltPersp_ForswornDescr", 0x46649F),
			makeDefault("$AltPersp_Guilds", "$AltPersp_GuildsDescr", undefined, [
				{ text: "$AltPersp_Random", id: 0, color: _CSPECIAL },
				{ text: "$AltPersp_CollegeofWinterhold", id: 0x3D36E6 },
				{ text: "$AltPersp_ThievesGuild", id: 0x3CE5E5 },
				{ text: "$AltPersp_DarkBrotherhood", id: 0x3D36E7 },
				{ text: "$AltPersp_Companions", id: 0x3D36E8 }
			]),
			makeDefault("$AltPersp_Dragonborn", "$AltPersp_DragonbornDescr", undefined, [
				{ text: "$AltPersp_Random", id: 0, color: _CSPECIAL },
				{ text: "$AltPersp_VanillaStart", id: 0x3BF197 },
				{ text: "$AltPersp_HighHrothgar", id: 0x40B191 }
			])
		];
		for (var i = 0; i < arguments[0].length; i++) {
			// var opt = loadData(arguments[i]);
			var arg = new Object();
			arg.enabled = true;
			arg.text = arguments[0][i].name;
			options.push(arguments[0][i]);
		}
		menu.setItems(options);
		gotoAndPlay("fadeIn");
	}

  /* INITIALIZATION */

	public function MessengerMenu()
	{
		super();
		navPanel = bottomBarEX.bottomBar.buttonPanel;

		Mouse.addListener(this);
		FocusHandler.instance.setFocus(this, 0);
	}

	var _testID
	public function onLoad(): Void
	{
		// shopLists.addEventListener("itemHighlightChange", this, "onItemHighlightChange");
		// shopLists.addEventListener("showItemsList", this, "onShowItemsList");

		// shopLists.itemList.addEventListener("itemPress", this, "onItemSelect");

		positionFixedElements();
		navPanel.hideButtons();

		_testID = setTimeout(Delegate.create(this, test), 1000);
	}

	private function test() {
		var arg = new Array();
		for (var i = 0; i < 12; i++) {
			arg.push({
				name: i
			});
		}
		openMenu(arg);
	}

  /* PUBLIC FUNCTIONS */
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (fadedOut())
			return;

		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;

		if (GlobalFunc.IsKeyPressed(details) && (details.navEquivalent == NavigationCode.TAB || details.navEquivalent == NavigationCode.SHIFT_TAB)) {
			// save();
			// shopLists.OnMenuClose();
			skse.CloseMenu("CustomMenu");
		}

		return true;
	}

  /* PRIVATE FUNCTIONS */
	private function onShowItemsList(event: Object): Void
	{
		// shopLists.showItemsList();

		onItemHighlightChange(event);
	}

	private function onItemHighlightChange(event: Object): Void
	{
		if (event.index != -1)
			updateBottomBar(true);
	}

	private function updateBottomBar(a_bSelected: Boolean): Void
	{
		navPanel.clearButtons();

		navPanel.addButton({text: "$Exit", controls: _cancelControls});
		// navPanel.addButton({text: "$Search", controls: _searchControls});
		if (_platform != 0) {
			navPanel.addButton({text: "$Column", controls: _sortColumnControls});
			navPanel.addButton({text: "$Order", controls: _sortOrderControls});
		}
		if (a_bSelected) {
			navPanel.addButton({text: "$Buy", controls: Input.Activate});
		}

		navPanel.updateButtons(true);
	}

	private function positionFixedElements(): Void
	{
		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;

		bottomBarEX.bottomBar.positionElements(leftEdge, rightEdge);
	}

	private function fadedOut()
	{
		return menu._alpha < 10;
	}

	private function loadData(path)
	{
		var lv = new LoadVars();
		lv.onData = function(src: String) {
			var me = this["_this"];
			me._ready = true;
		};
		lv._this = this;
		lv.load(path);
	}
}
