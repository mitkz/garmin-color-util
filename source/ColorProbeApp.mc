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

        var font = Graphics.FONT_XTINY;
        var centerX = dc.getWidth() / 2;
        var fontHeight = dc.getFontHeight(font);
        var pad = 2;

        // FG line
        var rStr = _r.format("%3d");
        var gStr = _g.format("%3d");
        var bStr = _b.format("%3d");
        var fgText = "FG " + rStr + "," + gStr + "," + bStr;
        var fgY = 36;
        var fgStartX = centerX - dc.getTextWidthInPixels(fgText, font) / 2;
        dc.drawText(fgStartX, fgY, font, fgText, Graphics.TEXT_JUSTIFY_LEFT);

        if (_selectedChannel < 3) {
            _drawHighlight(dc, font, fgStartX, fgY, fontHeight, pad,
                "FG ", rStr, gStr, bStr, _selectedChannel);
        }

        // BG line
        var bgRStr = _bgR.format("%3d");
        var bgGStr = _bgG.format("%3d");
        var bgBStr = _bgB.format("%3d");
        var bgText = "BG " + bgRStr + "," + bgGStr + "," + bgBStr;
        var bgY = fgY + fontHeight + 4;
        var bgStartX = centerX - dc.getTextWidthInPixels(bgText, font) / 2;
        dc.drawText(bgStartX, bgY, font, bgText, Graphics.TEXT_JUSTIFY_LEFT);

        if (_selectedChannel >= 3) {
            _drawHighlight(dc, font, bgStartX, bgY, fontHeight, pad,
                "BG ", bgRStr, bgGStr, bgBStr, _selectedChannel - 3);
        }
    }

    function _drawHighlight(dc as Graphics.Dc, font as Graphics.FontType,
            startX as Lang.Number, y as Lang.Number, fontHeight as Lang.Number, pad as Lang.Number,
            prefix as Lang.String, rStr as Lang.String, gStr as Lang.String, bStr as Lang.String,
            idx as Lang.Number) as Void {
        var beforeWidth = 0;
        var valWidth = 0;
        if (idx == 0) {
            beforeWidth = dc.getTextWidthInPixels(prefix, font);
            valWidth = dc.getTextWidthInPixels(rStr, font);
        } else if (idx == 1) {
            beforeWidth = dc.getTextWidthInPixels(prefix + rStr + ",", font);
            valWidth = dc.getTextWidthInPixels(gStr, font);
        } else {
            beforeWidth = dc.getTextWidthInPixels(prefix + rStr + "," + gStr + ",", font);
            valWidth = dc.getTextWidthInPixels(bStr, font);
        }
        dc.drawRectangle(startX + beforeWidth - pad, y - pad, valWidth + pad * 2, fontHeight + pad * 2);
    }

    function cycleChannel() as Void {
        _selectedChannel = (_selectedChannel + 1) % 6;
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

    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }
        return false;
    }

    function onBack() as Lang.Boolean {
        return true;
    }
}

function getApp() as ColorProbeApp {
    return Application.getApp() as ColorProbeApp;
}