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

  public var driftFlow:h2d.Flow;

  public var scoreText:h2d.Text;
  public var driftScoreText:h2d.Text;
  public var driftMultiplierText:h2d.Text;

  /**
   * Add hype text so that we can 
   * get excited with the hype of your drift.
   */
  public var driftHype:h2d.Text;

  public var snowGauge:TextureGauge;

  public function new() {
    super(Game.ME);

    createRootInLayers(game.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

    flow = new h2d.Flow(root);
    driftFlow = new h2d.Flow(root);
    driftFlow.horizontalSpacing = 12;
    driftFlow.layout = Vertical;
    createUIEl();
    dn.Process.resizeAll();
  }

  public function createUIEl() {
    createScore();
    createDriftScore();

    createDriftHype();
    createSnowGauge();
  }

  public function createDriftScore() {
    driftScoreText = new h2d.Text(Assets.fontSmall, driftFlow);
    driftScoreText.text = 'Drift 0';
    driftScoreText.textColor = 0xffffff;
  }

  public function createScore() {
    scoreText = new h2d.Text(Assets.fontSmall, flow);
    scoreText.text = 'Score 0';

    scoreText.textColor = 0xffffff;
  }

  public function createDriftMultiplier() {
    driftMultiplierText = new h2d.Text(Assets.fontSmall, driftFlow);
    driftMultiplierText.text = 'x1';
    driftMultiplierText.textColor = 0xffa0aa;
  }

  public function createDriftHype() {
    driftHype = new h2d.Text(Assets.fontSmall, driftFlow);
    driftHype.text = '';
    driftHype.textColor = 0xffa0aa;
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
      renderDriftScore();
      // renderDriftMultiplier();
      renderDriftHype();
      renderSnowGauge();
    }
  }

  function renderScore() {
    scoreText.text = 'Score ${level.player.score}';
  }

  function renderDriftScore() {
    driftScoreText.text = 'Drift ${level.player.driftScore}'
      + ' x${M.floor(level.player.driftMultiplier)}';
  }

  function renderDriftMultiplier() {
    driftMultiplierText.text = 'x${M.floor(level.player.driftMultiplier)}';
  }

  function renderDriftHype() {
    driftHype.text = getHype(level.player.driftScore);
  }

  function getHype(score:Int) {
    return switch (score) {
      case score if (score < 250 && score > 0):
        'Nice';
      case score if (score < 500 && score > 250):
        'Cool';
      case score if (score < 1000 && score > 500):
        'Awesome';
      case score if (score < 2000 && score > 1000):
        'Incredible';
      case score if (score < Math.POSITIVE_INFINITY && score > 2000):
        'Snow Drift King';
      case _:
        '';
    }
  }

  public function renderSnowGauge() {
    var pl = level.player;
    snowGauge.updatePerc(pl.snowAccum / en.Player.SNOW_AMT);
  }

  public function resizeSnowGauge() {
    snowGauge.x = 32;
    snowGauge.y = Std.int((h() / Const.UI_SCALE) * .75);
    driftFlow.x = (w() - (w() / 3)) / Const.UI_SCALE;
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
    driftFlow.visible = false;
    snowGauge.hide();
  }

  public function show() {
    flow.visible = true;
    driftFlow.visible = true;
    snowGauge.show();
  }
}