//-----------------------------------------------------------------------------------
//
// Distributed under MIT Licence
//   See https://github.com/house-of-abbey/GarminHomeAssistant/blob/main/LICENSE
//
//-----------------------------------------------------------------------------------

using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Graphics;

//! Instinct 2 friendly monochrome glance view.
//!
//! Goals:
//! - reuse the Home Assistant launcher icon;
//! - avoid coloured rectangles/dithering on monochrome displays;
//! - show either custom glance text from JSON or a compact API status.
//
(:glance)
class HomeAssistantGlanceView extends WatchUi.GlanceView {
    private var mApp     as HomeAssistantApp;
    private var mLogo    as WatchUi.Bitmap?;
    private var mTitle   as WatchUi.Text?;
    private var mContent as WatchUi.TextArea?;

    function initialize(app as HomeAssistantApp) {
        GlanceView.initialize();
        mApp = app;
    }

    function onLayout(dc as Graphics.Dc) as Void {
        var h = dc.getHeight();
        var w = dc.getWidth();

        mLogo = new WatchUi.Bitmap({
            :rezId => $.Rez.Drawables.LauncherIcon,
            :locX  => 4,
            :locY  => (h - 62) / 2
        });

        mTitle = new WatchUi.Text({
            :text          => "HOME ASSISTANT",
            :color         => Graphics.COLOR_WHITE,
            :font          => Graphics.FONT_XTINY,
            :justification => Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER,
            :locX          => 70,
            :locY          => h / 3
        });

        mContent = new WatchUi.TextArea({
            :text          => "",
            :color         => Graphics.COLOR_WHITE,
            :font          => Graphics.FONT_XTINY,
            :justification => Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER,
            :locX          => 70,
            :locY          => h / 2,
            :width         => w - 74,
            :height        => h / 2
        });
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var apiStatus  = mApp.getApiStatus();
        var glanceText = mApp.getGlanceText();
        var text;

        GlanceView.onUpdate(dc);

        // Pure monochrome rendering for Instinct 2.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.clear();

        if (mLogo != null) {
            mLogo.draw(dc);
        }

        if (mTitle != null) {
            mTitle.setColor(Graphics.COLOR_WHITE);
            mTitle.draw(dc);
        }

        if (glanceText != null) {
            text = glanceText;
        } else if (apiStatus.equals(WatchUi.loadResource($.Rez.Strings.Available))) {
            text = "API OK";
        } else if (apiStatus.equals(WatchUi.loadResource($.Rez.Strings.Checking))) {
            text = "API ...";
        } else {
            text = "API ERR";
        }

        if (mContent != null) {
            mContent.setColor(Graphics.COLOR_WHITE);
            mContent.setText(text);
            mContent.draw(dc);
        }
    }
}
