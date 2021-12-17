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
  public var driftMultiplierText:h2d.Text;
  public var snowGauge:TextureGauge;

  public function new() {
    super(Game.ME);

    createRootInLayers(game.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

    flow = new h2d.Flow(root);
    createUIEl();
    dn.Process.resizeAll();
  }

  public function createUIEl() {
    createScore();
    createDriftMultiplier();
    createSnowGauge();
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

  public function createDriftMultiplier() {
    driftMultiplierText = new h2d.Text(Assets.fontSmall, flow);
    driftMultiplierText.text = 'Drift Factor x1';
    driftMultiplierText.textColor = 0xffa0aa;
    driftMultiplierText.dropShadow = {
      dx: 0.2,
      dy: 0.2,
      alpha: 1,
      color: 0xffa0aa
    };
  }

  public function createSnowGauge() {
    var front = hxd.Res.img.SnowGFront.toTile();
    var back = hxd.Res.img.SnowGBack.toTile();
    snowGauge = new TextureGauge(front, back, root);
    snowGauge.flowType = UP_DOWN;
    resizeSnowGauge();
  }

  override function onResize() {
    super.onResize();
    root.setScale(Const.UI_SCALE);
    resizeSnowGauge();
  }

  public inline function invalidate()
    invalidated = true;

  function render() {
    if (level != null && level.player != null) {
      renderScore();
      renderDriftMultiplier();
      renderSnowGauge();
    }
  }

  function renderScore() {
    scoreText.text = 'Score ${level.player.score}';
  }

  function renderDriftMultiplier() {
    driftMultiplierText.text = 'Drift Factor x${M.floor(level.player.driftMultiplier)}';
  }

  public function renderSnowGauge() {
    var pl = level.player;
    snowGauge.updatePerc(pl.snowAccum / en.Player.SNOW_AMT);
  }

  public function resizeSnowGauge() {
    snowGauge.x = 32;
    snowGauge.y = Std.int((h() / Const.UI_SCALE) * .75);
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
    snowGauge.hide();
  }

  public function show() {
    flow.visible = true;
    snowGauge.show();
  }
}