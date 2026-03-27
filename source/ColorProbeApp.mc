using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.WatchUi;

class ColorProbeApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Lang.Dictionary?) as Void {
    }

    function onStop(state as Lang.Dictionary?) as Void {
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        var view = new ColorProbeView();
        return [view, new ColorProbeDelegate(view)];
    }
}

const STEP_LARGE = 20;

class ColorProbeView extends WatchUi.View {

    var _channels = ["R", "G", "B", "BG R", "BG G", "BG B"];

    var _r = 255;
    var _g = 0;
    var _b = 0;

    var _bgR = 0;
    var _bgG = 0;
    var _bgB = 0;

    var _selectedChannel = 0;

    var _squareLeft = 0;
    var _squareTop = 0;
    var _squareSize = 0;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        _updateSquareBounds(dc.getWidth(), dc.getHeight());

        var bgColor = Graphics.createColor(255, _bgR, _bgG, _bgB);
        var squareColor = Graphics.createColor(255, _r, _g, _b);
        var textColor = _textColorForBackground();

        dc.setColor(bgColor, bgColor);
        dc.clear();

        dc.setColor(squareColor, squareColor);
        dc.fillRectangle(_squareLeft, _squareTop, _squareSize, _squareSize);

        dc.setColor(textColor, bgColor);
        dc.drawRectangle(_squareLeft, _squareTop, _squareSize, _squareSize);

        var selected = "Editing: " + _channels[_selectedChannel];
        var fg_values = "FG " + _r + "," + _g + "," + _b;
        var bg_values = "BG " + _bgR + "," + _bgG + "," + _bgB;

        dc.drawText(dc.getWidth() / 2, 36, Graphics.FONT_XTINY, selected, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 70, Graphics.FONT_XTINY, fg_values, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 40, Graphics.FONT_XTINY, bg_values, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function cycleChannel() as Void {
        _selectedChannel = (_selectedChannel + 1) % _channels.size();
        WatchUi.requestUpdate();
    }

    function adjustSelected(delta as Lang.Number) as Void {
        if (_selectedChannel == 0) {
            _r = _clamp(_r + delta);
        } else if (_selectedChannel == 1) {
            _g = _clamp(_g + delta);
        } else if (_selectedChannel == 2) {
            _b = _clamp(_b + delta);
        } else if (_selectedChannel == 3) {
            _bgR = _clamp(_bgR + delta);
        } else if (_selectedChannel == 4) {
            _bgG = _clamp(_bgG + delta);
        } else {
            _bgB = _clamp(_bgB + delta);
        }

        WatchUi.requestUpdate();
    }

    function getSquareLeft() as Lang.Number {
        return _squareLeft;
    }

    function getSquareTop() as Lang.Number {
        return _squareTop;
    }

    function getSquareRight() as Lang.Number {
        return _squareLeft + _squareSize;
    }

    function getSquareBottom() as Lang.Number {
        return _squareTop + _squareSize;
    }

    function isInsideSquare(x as Lang.Number, y as Lang.Number) as Lang.Boolean {
        return x >= getSquareLeft() && x <= getSquareRight() && y >= getSquareTop() && y <= getSquareBottom();
    }

    function _updateSquareBounds(width as Lang.Number, height as Lang.Number) as Void {
        var minDim = width;
        if (height < width) {
            minDim = height;
        }
        _squareSize = (minDim * 42 / 100).toNumber();
        _squareLeft = (width - _squareSize) / 2;
        _squareTop = (height - _squareSize) / 2;
    }

    function _textColorForBackground() as Graphics.ColorType {
        var brightness = ((_bgR * 299) + (_bgG * 587) + (_bgB * 114)) / 1000;
        if (brightness >= 140) {
            return Graphics.COLOR_BLACK;
        }
        return Graphics.COLOR_WHITE;
    }

    function _clamp(value as Lang.Number) as Lang.Number {
        if (value < 0) {
            return 0;
        }
        if (value > 255) {
            return 255;
        }
        return value;
    }
}

class ColorProbeDelegate extends WatchUi.BehaviorDelegate {
    var _view as ColorProbeView;

    function initialize(view as ColorProbeView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Lang.Boolean {
        var point = clickEvent.getCoordinates();
        var x = point[0];
        var y = point[1];

        if (_view.isInsideSquare(x, y)) {
            _view.cycleChannel();
            return true;
        }

        if (y < _view.getSquareTop()) {
            _view.adjustSelected(STEP_LARGE);
            return true;
        }

        if (y > _view.getSquareBottom()) {
            _view.adjustSelected(-STEP_LARGE);
            return true;
        }

        if (x < _view.getSquareLeft()) {
            _view.adjustSelected(-1);
            return true;
        }

        if (x > _view.getSquareRight()) {
            _view.adjustSelected(1);
            return true;
        }

        return false;
    }
}

function getApp() as ColorProbeApp {
    return Application.getApp() as ColorProbeApp;
}