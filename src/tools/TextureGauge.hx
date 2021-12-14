package tools;

import h2d.Mask;
import h2d.Tile;
import h2d.Bitmap;

enum abstract Flow(String) from String to String {
  var LEFT_RIGHT:String = 'LeftRight';
  var RIGHT_LEFT:String = 'RightLeft';
  var UP_DOWN:String = 'UpDown';
  var DOWN_UP:String = 'DownUp';
}

class TextureGauge {
  public var root:h2d.Object;
  public var front:Bitmap;
  public var back:Bitmap;
  public var flowType:Flow;
  public var mask:Mask;

  public var invalidated = false;

  /**
   * The percentage of the gauge.
   * Determines the amount of gauge to show.
   */
  public var delta:Float = 1;

  public var x(get, set):Int;
  public var y(get, set):Int;

  public function get_x() {
    return Std.int(this.back.x);
  }

  public function set_x(value:Int) {
    this.root.x = value;
    return Std.int(this.root.x);
  }

  public function get_y() {
    return Std.int(this.root.y);
  }

  public function set_y(value:Int) {
    this.root.y = value;
    return Std.int(this.root.y);
  }

  public function new(front:Tile, back:Tile, parent) {
    this.flowType = RIGHT_LEFT;
    root = new h2d.Object(parent);
    this.back = new Bitmap(back, root);
    this.mask = new Mask(Std.int(front.width), Std.int(front.height), root);
    this.mask.scrollBounds = h2d.col.Bounds.fromValues(-mask.width / 2,
      -mask.height / 2, mask.width * 2, mask.height * 2);
    this.front = new Bitmap(front, mask);
    this.mask.x = this.front.x;
    this.mask.y = this.front.y;
  }

  public function updatePerc(amount:Float) {
    delta = amount;
    invalidate();
  }

  public inline function invalidate() {
    invalidated = true;
    update();
  }

  public function update() {
    switch (flowType) {
      case LEFT_RIGHT:
        this.front.scaleX = -delta;
      case RIGHT_LEFT:
        this.front.scaleX = delta;
      case DOWN_UP:
        this.mask.height = Std.int(this.front.tile.height * delta);
      case UP_DOWN:
        var result = Std.int(this.front.tile.height * delta);
        var offset = this.front.tile.height - result;
        this.mask.height = result;
        this.mask.y = offset;
        this.front.y = -offset;
    }

    invalidated = false;
  }
}