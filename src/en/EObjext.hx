package en;

import h2d.col.Point;
import h3d.Vector;

class EObject extends Entity {
  public var worldPos:Point;

  var g:h2d.Graphics;

  public function setupGraphic() {
    spr.visible = false;
    var tex = Boot.ME.mode7.texture;
    worldPos = new Point(spr.x / tex.width, spr.y / tex.height);
  }

  override function update() {
    super.update();
    updateDisplay();
    updateVisisble();
  }

  public function updateDisplay() {
    var player = level.player;
    if (player != null) {
      var normDis = worldPos.distance(player.worldPos) * 3;
      spr.scaleY = normDis;
      if (g != null) {
        g.scaleY = normDis;
      }
    }
  }

  public function updateVisisble() {
    if (level.player != null) {
      var pl = level.player;
      spr.visible = pl.withinFrustrum(this);
    }
  }
}