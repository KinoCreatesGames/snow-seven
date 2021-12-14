package en;

import en.EObjext.EObject;

class Tree extends EObject {
  public function new(tree:Entity_Tree) {
    super(tree.cx, tree.cy);
    setupGraphic();
  }

  public override function setupGraphic() {
    var t = hxd.Res.img.Tree.toTile();
    g = new h2d.Graphics(spr);
    g.beginTileFill(t);
    g.drawRect(0, 0, t.width, t.height);
    g.endFill();
    super.setupGraphic();
  }

  override public function updateVisisble() {
    if (level.player != null) {
      var pl = level.player;
      g.visible = pl.withinFrustrum(this);
      spr.visible = pl.withinFrustrum(this);
    }
  }
}