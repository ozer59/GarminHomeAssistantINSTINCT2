//-----------------------------------------------------------------------------------
//
// Distributed under MIT Licence
//   See https://github.com/house-of-abbey/GarminHomeAssistant/blob/main/LICENSE
//
//-----------------------------------------------------------------------------------

using Toybox.Application;
using Toybox.Lang;
using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;

//! Home Assistant menu construction.
//! Instinct 2 fork: supports optional JSON "icon" on menu items.
class HomeAssistantView extends WatchUi.Menu2 {

    function initialize(
        definition as Lang.Dictionary,
        options as {
            :focus as Lang.Number,
            :icon  as Graphics.BitmapType or WatchUi.Drawable or Lang.Symbol
        }?
    ) {
        if (options == null) {
            options = { :title => definition.get("title") as Lang.String };
        } else {
            options[:title] = definition.get("title") as Lang.String;
        }
        WatchUi.Menu2.initialize(options);

        var items = definition.get("items") as Lang.Array<Lang.Dictionary>;
        for (var i = 0; i < items.size(); i++) {
            if (items[i] instanceof(Lang.Dictionary)) {
                var type       = items[i].get("type")       as Lang.String?;
                var name       = items[i].get("name")       as Lang.String?;
                var content    = items[i].get("content")    as Lang.String?;
                var entity     = items[i].get("entity")     as Lang.String?;
                var iconName   = items[i].get("icon")       as Lang.String?;
                var tap_action = items[i].get("tap_action") as Lang.Dictionary?;
                var action     = items[i].get("service")    as Lang.String?;
                var confirm    = false as Lang.Boolean or Lang.String or Null;
                var pin        = false as Lang.Boolean?;
                var data       = null as Lang.Dictionary?;
                var enabled    = true as Lang.Boolean?;
                var exit       = false as Lang.Boolean?;

                if (items[i].get("enabled") != null) {
                    enabled = items[i].get("enabled");
                }
                if (items[i].get("exit") != null) {
                    exit = items[i].get("exit");
                }
                if (tap_action != null) {
                    action = tap_action.get("service");
                    if (tap_action.get("action") != null) {
                        action = tap_action.get("action");
                    }
                    data = tap_action.get("data");
                    if (tap_action.get("confirm") != null) {
                        confirm = tap_action.get("confirm");
                    }
                    if (tap_action.get("pin") != null) {
                        pin = tap_action.get("pin");
                    }
                    if (tap_action.get("exit") != null) {
                        exit = tap_action.get("exit");
                    }
                }

                if (type != null && name != null && enabled) {
                    if (pin && !System.getDeviceSettings().isTouchScreen) {
                        addItem(HomeAssistantMenuItemFactory.create().tap(
                            "PIN requires Touchscreen", null, null, null, data, null,
                            { :exit => false, :confirm => false, :pin => false }
                        ));
                    } else if (type.equals("toggle") && entity != null) {
                        addItem(HomeAssistantMenuItemFactory.create().toggle(
                            name, entity, content, iconName,
                            { :exit => exit, :confirm => confirm, :pin => pin }
                        ));
                    } else if (type.equals("tap") && action != null) {
                        addItem(HomeAssistantMenuItemFactory.create().tap(
                            name, entity, content, action, data, iconName,
                            { :exit => exit, :confirm => confirm, :pin => pin }
                        ));
                    } else if (type.equals("template") && content != null) {
                        addItem(HomeAssistantMenuItemFactory.create().tap(
                            name, entity, content, action, data, iconName,
                            { :exit => (tap_action != null ? exit : false), :confirm => confirm, :pin => pin }
                        ));
                    } else if (type.equals("numeric") && action != null) {
                        if (tap_action != null) {
                            var picker = tap_action.get("picker") as Lang.Dictionary?;
                            if (picker != null) {
                                addItem(HomeAssistantMenuItemFactory.create().numeric(
                                    name, entity, content, action, data, picker, iconName,
                                    { :exit => exit, :confirm => confirm, :pin => pin }
                                ));
                            }
                        }
                    } else if (type.equals("info") && content != null) {
                        addItem(HomeAssistantMenuItemFactory.create().tap(
                            name, entity, content, action, data, iconName,
                            { :exit => false, :confirm => confirm, :pin => pin }
                        ));
                    } else if (type.equals("group")) {
                        addItem(HomeAssistantMenuItemFactory.create().group(items[i], content, iconName));
                    }
                }
            }
        }
    }

    function getItemsToUpdate() as Lang.Array<HomeAssistantToggleMenuItem or HomeAssistantTapMenuItem or HomeAssistantGroupMenuItem or HomeAssistantNumericMenuItem or Null> {
        var fullList = [];
        var lmi = mItems as Lang.Array<WatchUi.MenuItem>;

        for (var i = 0; i < mItems.size(); i++) {
            var item = lmi[i];
            if (item instanceof HomeAssistantGroupMenuItem) {
                var gmi = item as HomeAssistantGroupMenuItem;
                if (gmi.hasTemplate()) {
                    fullList.add(item);
                }
                fullList.addAll(item.getMenuView().getItemsToUpdate());
            } else if (item instanceof HomeAssistantNumericMenuItem) {
                fullList.add(item);
            } else if (item instanceof HomeAssistantToggleMenuItem) {
                fullList.add(item);
            } else if (item instanceof HomeAssistantTapMenuItem) {
                var tmi = item as HomeAssistantTapMenuItem;
                if (tmi.hasTemplate()) {
                    fullList.add(item);
                }
            }
        }
        return fullList;
    }

    function onShow() as Void {}
}

class HomeAssistantViewDelegate extends WatchUi.Menu2InputDelegate {
    private var mIsRootMenuView as Lang.Boolean = false;
    private var mTimer as QuitTimer;

    function initialize(isRootMenuView as Lang.Boolean) {
        Menu2InputDelegate.initialize();
        mIsRootMenuView = isRootMenuView;
        mTimer = getApp().getQuitTimer();
    }

    function onBack() {
        mTimer.reset();
        if (mIsRootMenuView) {
            System.exit();
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onDone() { mTimer.reset(); }
    function onFooter() { mTimer.reset(); }

    function onSelect(item as WatchUi.MenuItem) as Void {
        mTimer.reset();
        if (item instanceof HomeAssistantToggleMenuItem) {
            var haToggleItem = item as HomeAssistantToggleMenuItem;
            haToggleItem.callAction(haToggleItem.isEnabled());
        } else if (item instanceof HomeAssistantTapMenuItem) {
            var haItem = item as HomeAssistantTapMenuItem;
            haItem.callAction();
        } else if (item instanceof HomeAssistantNumericMenuItem) {
            var haNumericItem = item as HomeAssistantNumericMenuItem;
            var mPickerFactory = new HomeAssistantNumericFactory(haNumericItem.getPicker());
            var mPicker = new HomeAssistantNumericPicker(mPickerFactory, haNumericItem);
            var mPickerDelegate = new HomeAssistantNumericPickerDelegate(mPicker);
            WatchUi.pushView(mPicker, mPickerDelegate, WatchUi.SLIDE_LEFT);
        } else if (item instanceof HomeAssistantGroupMenuItem) {
            var haMenuItem = item as HomeAssistantGroupMenuItem;
            WatchUi.pushView(haMenuItem.getMenuView(), new HomeAssistantViewDelegate(false), WatchUi.SLIDE_LEFT);
        }
    }

    function onTitle() { mTimer.reset(); }
}
