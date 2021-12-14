package ui;

import scn.Level;

class Hud extends dn.Process {
  public var game(get, never):Game;

  inline function get_game()
    return Game.ME;

  public var fx(get, never):Fx;

  inline function get_fx()
    return Game.ME.fx;

  public var level(get, never):Level;

  inline function get_level()
    return Game.ME.level;

  var flow:h2d.Flow;
  var invalidated = true;

  public var scoreText:h2d.Text;

  public function new() {
    super(Game.ME);

    createRootInLayers(game.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

    flow = new h2d.Flow(root);
    createUIEl();
  }

  public function createUIEl() {
    createScore();
  }

  public function createScore() {
    scoreText = new h2d.Text(Assets.fontSmall, flow);
    scoreText.text = 'Score 0';
    scoreText.textColor = 0xffa0aa;
    scoreText.dropShadow = {
      dx: 0.2,
      dy: 0.2,
      alpha: 1,
      color: 0xaaaaa
    };
  }

  override function onResize() {
    super.onResize();
    root.setScale(Const.UI_SCALE);
  }

  public inline function invalidate()
    invalidated = true;

  function render() {
    if (level != null && level.player != null) {
      renderScore();
    }
  }

  function renderScore() {
    scoreText.text = 'Score ${level.player.score}';
  }

  override function postUpdate() {
    super.postUpdate();

    if (invalidated) {
      invalidated = false;
      render();
    }
  }

  public function hide() {
    flow.visible = false;
  }

  public function show() {
    flow.visible = true;
  }
}