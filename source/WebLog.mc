//-----------------------------------------------------------------------------------
//
// Distributed under MIT Licence
//   See https://github.com/house-of-abbey/GarminHomeAssistant/blob/main/LICENSE
//
//-----------------------------------------------------------------------------------

using Toybox.Lang;
using Toybox.System;

//! WebLog compatibility implementation for the Instinct 2 build.
//!
//! The upstream WebLog network backend references the optional ClientId module
//! (webLogUrl/webLogClearUrl). That module is intentionally not part of normal
//! production builds. Keep the WebLog API available to the rest of the application,
//! but make it local/no-op so the Instinct 2 target can compile without private
//! development logging credentials.
(:glance, :background)
class WebLog {
    private var callsBuffer = 4 as Lang.Number;
    private var numCalls = 0 as Lang.Number;
    private var buffer = "" as Lang.String;

    function setCallsBuffer(l as Lang.Number) {
        callsBuffer = l;
    }

    function getCallsBuffer() as Lang.Number {
        return callsBuffer;
    }

    function print(str as Lang.String) {
        var myTime = System.getClockTime();
        buffer += myTime.hour.format("%02d") + ":" + myTime.min.format("%02d") + ":" + myTime.sec.format("%02d") + " " + str;
        numCalls++;
        if (numCalls >= callsBuffer) {
            doPrint();
        }
    }

    function println(str as Lang.String) {
        print(str + "\n");
    }

    function flush() {
        if (numCalls > 0) {
            doPrint();
        }
    }

    //! Network WebLog is disabled in this public Instinct 2 build.
    function doPrint() {
        numCalls = 0;
        buffer = "";
    }

    //! Preserve the original API while clearing only the local buffer.
    function clear() {
        numCalls = 0;
        buffer = "";
    }

    //! Retained for compatibility with code that may reference the callbacks.
    function onLog(responseCode as Lang.Number, data as Null or Lang.Dictionary or Lang.String) as Void {
    }

    function onClear(responseCode as Lang.Number, data as Null or Lang.Dictionary or Lang.String) as Void {
    }
}