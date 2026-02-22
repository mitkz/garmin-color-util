using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;

class ColorProbeApp extends Application.AppBase {

    // アプリケーションを初期化する
    function initialize() {
        AppBase.initialize();
    }

    // アプリケーション開始時に呼ばれるハンドラ
    function onStart(state as Dictionary?) as Void {
    }

    // アプリケーション停止時に呼ばれるハンドラ
    function onStop(state as Dictionary?) as Void {
    }

    // 起動時に表示するビューとデリゲートを返す
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new ColorProbeView();
        return [view, new ColorProbeDelegate(view)];
    }
}

class ColorProbeView extends WatchUi.View {
    const STEP_LARGE = 20;

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

    // ビューを初期化する
    function initialize() {
        View.initialize();
    }

    // レイアウト更新時に呼ばれるハンドラ
    function onLayout(dc as Dc) as Void {
    }

    // 画面全体を描画する
    function onUpdate(dc as Dc) as Void {
        _updateSquareBounds(dc.getWidth(), dc.getHeight());

        var bgColor = Graphics.createColor(_bgR, _bgG, _bgB);
        var squareColor = Graphics.createColor(_r, _g, _b);
        var textColor = _textColorForBackground();

        dc.setColor(bgColor, bgColor);
        dc.clear();

        dc.setColor(squareColor, squareColor);
        dc.fillRectangle(_squareLeft, _squareTop, _squareSize, _squareSize);

        dc.setColor(textColor, bgColor);
        dc.drawRectangle(_squareLeft, _squareTop, _squareSize, _squareSize);

        var title = "Tap square: next channel";
        var selected = "Editing: " + _channels[_selectedChannel];
        var values = "RGB " + _r + "," + _g + "," + _b + "  BG " + _bgR + "," + _bgG + "," + _bgB;
        var guide = "Top:+20 Bottom:-20 Left:-1 Right:+1";

        dc.drawText(dc.getWidth() / 2, 8, Graphics.FONT_XTINY, title, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, 26, Graphics.FONT_XTINY, selected, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 30, Graphics.FONT_XTINY, values, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 14, Graphics.FONT_XTINY, guide, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // 編集対象のチャネルを次のチャネルに切り替え、画面を更新する
    function cycleChannel() as Void {
        _selectedChannel = (_selectedChannel + 1) % _channels.size();
        WatchUi.requestUpdate();
    }

    // 選択中のチャネル値を delta 分増減し、画面を更新する
    function adjustSelected(delta as Number) as Void {
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

    // 中央正方形の左端 X 座標を返す
    function getSquareLeft() as Number {
        return _squareLeft;
    }

    // 中央正方形の上端 Y 座標を返す
    function getSquareTop() as Number {
        return _squareTop;
    }

    // 中央正方形の右端 X 座標を返す
    function getSquareRight() as Number {
        return _squareLeft + _squareSize;
    }

    // 中央正方形の下端 Y 座標を返す
    function getSquareBottom() as Number {
        return _squareTop + _squareSize;
    }

    // 指定座標 (x, y) が中央正方形の内側にあるかどうかを返す
    function isInsideSquare(x as Number, y as Number) as Boolean {
        return x >= getSquareLeft() && x <= getSquareRight() && y >= getSquareTop() && y <= getSquareBottom();
    }

    // 画面の幅・高さをもとに正方形の位置とサイズを更新する
    function _updateSquareBounds(width as Number, height as Number) as Void {
        _squareSize = (width < height ? width : height) * 0.42;
        _squareLeft = (width - _squareSize) / 2;
        _squareTop = (height - _squareSize) / 2;
    }

    // 背景色の明度に応じてテキスト用の白または黒を返す
    function _textColorForBackground() as ColorType {
        var brightness = ((_bgR * 299) + (_bgG * 587) + (_bgB * 114)) / 1000;
        if (brightness >= 140) {
            return Graphics.COLOR_BLACK;
        }
        return Graphics.COLOR_WHITE;
    }

    // 値を 0〜255 の範囲にクランプして返す
    function _clamp(value as Number) as Number {
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

    // デリゲートを初期化し、操作対象のビューを保持する
    function initialize(view as ColorProbeView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // タップ位置に応じてチャネルの切り替えまたは値の増減を行う
    function onTap(clickEvent as ClickEvent) as Boolean {
        var point = clickEvent.getCoordinates();
        var x = point[0];
        var y = point[1];

        if (_view.isInsideSquare(x, y)) {
            _view.cycleChannel();
            return true;
        }

        if (y < _view.getSquareTop()) {
            _view.adjustSelected(ColorProbeView.STEP_LARGE);
            return true;
        }

        if (y > _view.getSquareBottom()) {
            _view.adjustSelected(-ColorProbeView.STEP_LARGE);
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

// アプリケーションインスタンスを返す
function getApp() as ColorProbeApp {
    return Application.getApp() as ColorProbeApp;
}