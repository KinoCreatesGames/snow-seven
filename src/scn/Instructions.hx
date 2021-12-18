package scn;

import h2d.Text;
import h2d.Flow.FlowAlign;
import ui.transition.FadeToBlack;

class Instructions extends dn.Process {
  var game(get, never):Game;

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
    ca = Main.ME.controller.createAccess('instructions');

    setupInstructions();
    dn.Process.resizeAll();
  }

  /**
   * Sets up the instructions on the screen 
   */
  public function setupInstructions() {
    win = new h2d.Flow(root);
    var width = Std.int(w() / 3);
    win.backgroundTile = h2d.Tile.fromColor(0xff0000, width, 100, 0);
    win.borderHeight = 6;
    win.borderWidth = 6;
    win.verticalSpacing = 16;

    win.layout = Vertical;
    win.verticalAlign = FlowAlign.Middle;
    setupText();
  }

  public function setupText() {
    var howTo = new h2d.Text(Assets.fontLarge, win);
    howTo.text = Lang.t._('How To Play');
    howTo.center();

    var instr = new h2d.Text(Assets.fontMedium, win);
    // instr.maxWidth = Std.int(w() / 4);
    instr.text = 'It\'s freezing outside. 
    Keep your wheels and tires warm this 
    holiday season by drifting on the track. 
    If the snow builds up (bottom left corner) It\'s game over! 
    Good luck!
    Press Enter';
    instr.center();
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

  override function update() {
    super.update();
    var exitCredits = ca.isKeyboardPressed(K.ESCAPE)
      || ca.isAnyKeyPressed([K.C, K.X])
      || ca.aDown()
      || ca.bDown();
    if (exitCredits && transition == null) {
      // new Title();
      transition = new FadeToBlack();
    }
    if (transition != null && transition.complete) {
      this.destroy();
      transition.destroy();
      Game.ME.startInitialGame();
    }
  }

  override function onDispose() {
    super.onDispose();
  }
}