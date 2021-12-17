package scn;

import h2d.Text;
import ui.transition.FadeToBlack;
import hxd.snd.Channel;
import h2d.Flow.FlowAlign;

class Credits extends dn.Process {
  var game(get, never):Game;

  public var bgm:Channel;
  public var mask:h2d.Bitmap;

  inline function get_game() {
    return Game.ME;
  }

  public var ca:dn.heaps.Controller.ControllerAccess;

  public var complete:Bool;
  public var win:h2d.Flow;
  public var transition:FadeToBlack;

  public function new() {
    super(Game.ME);
    createRootInLayers(Game.ME.root, Const.DP_UI);
    complete = false;
    mask = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 1), root);

    root.under(mask);
    ca = Main.ME.controller.createAccess('credits');
    // Play music
    // bgm = hxd.Res.music.happy_end.play(true);

    setupCredits();
    dn.Process.resizeAll();
  }

  public function setupCredits() {
    win = new h2d.Flow(root);
    var width = Std.int(w() / 3);
    win.backgroundTile = h2d.Tile.fromColor(0xff0000, width, 100, 0);
    win.borderHeight = 6;
    win.borderWidth = 6;
    win.verticalSpacing = 12;

    win.layout = Vertical;
    win.verticalAlign = FlowAlign.Middle;
    setupText();
  }

  public function setupText() {
    var credits = new h2d.Text(Assets.fontLarge, win);
    credits.text = Lang.t._('Credits');
    credits.center();
    var kino = new h2d.Text(Assets.fontMedium, win);
    kino.text = Lang.t._('Kino - Game Design');
    kino.center();

    var assets = new h2d.Text(Assets.fontMedium, win);
    assets.text = Lang.t._('Creative Commons Assets');
    assets.center();

    var jd = new h2d.Text(Assets.fontMedium, win);
    jd.text = Lang.t._('JDSherbert - Music - Refreshing Dawn');
    jd.center();

    var tom = new h2d.Text(Assets.fontMedium, win);
    tom.text = Lang.t._('Audible Edge - Tire Squall Audio Asset');
    tom.center();

    var pauli = new h2d.Text(Assets.fontMedium, win);
    pauli.text = Lang.t._('Pauliuw - Engine Audio Asset');
    pauli.center();

    var lusho = new h2d.Text(Assets.fontMedium, win);
    lusho.text = Lang.t._('LushoGame - Music (Plomo)');
    lusho.center();

    var foxy = new h2d.Text(Assets.fontMedium, win);
    foxy.text = Lang.t._('FoxSynergy - Music (Blue Space)');
    foxy.center();

    var thanks = new h2d.Text(Assets.fontMedium, win);
    thanks.text = Lang.t._('Thank You For Playing!');
    thanks.center();

    // var pixelS = new h2d.Text(Assets.fontMedium, win);
    // pixelS.text = Lang.t._('pixelsphere.org/The Cynic Project');
    // pixelS.center();
  }

  override public function onResize() {
    super.onResize();
    if (mask != null) {
      var w = M.ceil(w());
      var h = M.ceil(h());
      mask.scaleX = w;
      mask.scaleY = h;
    }
    win.x = (w() * 0.5 - (win.outerWidth * 0.1));
    win.y = (h() * 0.5 - (win.outerHeight * 0.5));
  }

  override public function update() {
    super.update();
    // Hit Escape to exit the credits screen
    var exitCredits = ca.isKeyboardPressed(K.ESCAPE)
      || ca.isAnyKeyPressed([K.C, K.X]);
    if (exitCredits && transition == null) {
      // new Title();
      transition = new FadeToBlack();
    }
    if (transition != null && transition.complete) {
      this.destroy();
      transition.destroy();
      new Title();
    }
  }

  override function onDispose() {
    super.onDispose();
    if (bgm != null) {
      bgm.stop();
    }
  }
}