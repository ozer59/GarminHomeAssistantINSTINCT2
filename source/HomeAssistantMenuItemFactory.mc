//-----------------------------------------------------------------------------------
//
// Distributed under MIT Licence
//   See https://github.com/house-of-abbey/GarminHomeAssistant/blob/main/LICENSE
//
//-----------------------------------------------------------------------------------

using Toybox.Application;
using Toybox.Lang;
using Toybox.WatchUi;

//! MenuItems Factory class.
//!
//! Instinct 2 fork: menu items may provide an optional JSON "icon" value:
//! car, light, alarm, solar, pause, battery.
//
class HomeAssistantMenuItemFactory {
    private var mMenuItemOptions      as Lang.Dictionary;
    private var mTapTypeIcon          as WatchUi.Bitmap;
    private var mGroupTypeIcon        as WatchUi.Bitmap;
    private var mInfoTypeIcon         as WatchUi.Bitmap;
    private var mNumericTypeIcon      as WatchUi.Bitmap;
    private var mCarIcon              as WatchUi.Bitmap;
    private var mLightIcon            as WatchUi.Bitmap;
    private var mAlarmIcon            as WatchUi.Bitmap;
    private var mSolarIcon            as WatchUi.Bitmap;
    private var mPauseIcon            as WatchUi.Bitmap;
    private var mBatteryIcon          as WatchUi.Bitmap;
    private var mHomeAssistantService as HomeAssistantService;

    private static var instance;

    private function initialize() {
        mMenuItemOptions = { :alignment => Settings.getMenuAlignment() };

        mTapTypeIcon = makeBitmap($.Rez.Drawables.TapTypeIcon);
        mGroupTypeIcon = makeBitmap($.Rez.Drawables.GroupTypeIcon);
        mInfoTypeIcon = makeBitmap($.Rez.Drawables.InfoTypeIcon);
        mNumericTypeIcon = makeBitmap($.Rez.Drawables.NumericTypeIcon);

        mCarIcon = makeBitmap($.Rez.Drawables.CarIcon);
        mLightIcon = makeBitmap($.Rez.Drawables.LightIcon);
        mAlarmIcon = makeBitmap($.Rez.Drawables.AlarmIcon);
        mSolarIcon = makeBitmap($.Rez.Drawables.SolarIcon);
        mPauseIcon = makeBitmap($.Rez.Drawables.PauseIcon);
        mBatteryIcon = makeBitmap($.Rez.Drawables.BatteryIcon);

        mHomeAssistantService = new HomeAssistantService();
    }

    private function makeBitmap(rezId) as WatchUi.Bitmap {
        return new WatchUi.Bitmap({
            :rezId => rezId,
            :locX  => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY  => WatchUi.LAYOUT_VALIGN_CENTER
        });
    }

    private function resolveIcon(iconName as Lang.String?, fallback as WatchUi.Bitmap) as WatchUi.Bitmap {
        if (iconName == null) {
            return fallback;
        }
        if (iconName.equals("car")) {
            return mCarIcon;
        } else if (iconName.equals("light")) {
            return mLightIcon;
        } else if (iconName.equals("alarm")) {
            return mAlarmIcon;
        } else if (iconName.equals("solar")) {
            return mSolarIcon;
        } else if (iconName.equals("pause")) {
            return mPauseIcon;
        } else if (iconName.equals("battery")) {
            return mBatteryIcon;
        }
        return fallback;
    }

    static function create() as HomeAssistantMenuItemFactory {
        if (instance == null) {
            instance = new HomeAssistantMenuItemFactory();
        }
        return instance;
    }

    function toggle(
        label     as Lang.String or Lang.Symbol,
        entity_id as Lang.String?,
        template  as Lang.String?,
        iconName  as Lang.String?,
        options   as {
            :exit    as Lang.Boolean,
            :confirm as Lang.Boolean,
            :pin     as Lang.Boolean
        }
    ) as WatchUi.MenuItem {
        var keys = mMenuItemOptions.keys();
        for (var i = 0; i < keys.size(); i++) {
            options[keys[i]] = mMenuItemOptions.get(keys[i]);
        }
        options[:icon] = resolveIcon(iconName, mTapTypeIcon);
        return new HomeAssistantToggleMenuItem(
            label,
            template,
            { "entity_id" => entity_id },
            options
        );
    }

    function tap(
        label     as Lang.String or Lang.Symbol,
        entity_id as Lang.String?,
        template  as Lang.String?,
        action    as Lang.String?,
        data      as Lang.Dictionary?,
        iconName  as Lang.String?,
        options   as {
            :exit    as Lang.Boolean,
            :confirm as Lang.Boolean,
            :pin     as Lang.Boolean
        }
    ) as WatchUi.MenuItem {
        if (entity_id != null) {
            if (data == null) {
                data = { "entity_id" => entity_id };
            } else {
                data["entity_id"] = entity_id;
            }
        }
        var keys = mMenuItemOptions.keys();
        for (var i = 0; i < keys.size(); i++) {
            options[keys[i]] = mMenuItemOptions.get(keys[i]);
        }

        if (action != null) {
            options[:icon] = resolveIcon(iconName, mTapTypeIcon);
            return new HomeAssistantTapMenuItem(
                label,
                template,
                action,
                data,
                options,
                mHomeAssistantService
            );
        } else {
            options[:icon] = resolveIcon(iconName, mInfoTypeIcon);
            return new HomeAssistantTapMenuItem(
                label,
                template,
                null,
                data,
                options,
                mHomeAssistantService
            );
        }
    }

    function numeric(
        label     as Lang.String or Lang.Symbol,
        entity_id as Lang.String?,
        template  as Lang.String?,
        action    as Lang.String?,
        data      as Lang.Dictionary?,
        picker    as Lang.Dictionary,
        iconName  as Lang.String?,
        options   as {
            :exit    as Lang.Boolean,
            :confirm as Lang.Boolean,
            :pin     as Lang.Boolean,
            :icon    as WatchUi.Bitmap
        }
    ) as WatchUi.MenuItem {
        if (entity_id != null) {
            if (data == null) {
                data = { "entity_id" => entity_id };
            } else {
                data["entity_id"] = entity_id;
            }
        }
        var keys = mMenuItemOptions.keys();
        for (var i = 0; i < keys.size(); i++) {
            options[keys[i]] = mMenuItemOptions.get(keys[i]);
        }
        options[:icon] = resolveIcon(iconName, mNumericTypeIcon);
        return new HomeAssistantNumericMenuItem(
            label,
            template,
            action,
            data,
            picker,
            options,
            mHomeAssistantService
        );
    }

    function group(
        definition as Lang.Dictionary,
        template   as Lang.String?,
        iconName   as Lang.String?
    ) as WatchUi.MenuItem {
        return new HomeAssistantGroupMenuItem(
            definition,
            template,
            resolveIcon(iconName, mGroupTypeIcon),
            mMenuItemOptions
        );
    }
}
