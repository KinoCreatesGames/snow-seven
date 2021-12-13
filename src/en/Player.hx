package en;

import h2d.col.Point;
import h3d.Vector;
import shaders.ModeSevShader;
import dn.heaps.Controller.ControllerAccess;
import dn.heaps.filter.PixelOutline;

class Player extends Entity {
  public var ct:ControllerAccess;

  public var camera(get, null):Camera;

  inline function get_camera()
    return game.camera;

  public var mode7(get, null):ModeSevShader;

  inline function get_mode7() {
    return Boot.ME.mode7;
  }

  /**
   * Vertical speed for moving 
   * within the space quickly.
   */
  public static inline var SPEED:Float = 0.001;

  /**
   * Horizontal speed for turning
   */
  public static inline var SPEED_X:Float = 0.001;

  /**
   * Rotation angle for when the vehicle moves
   * left or right and should rotate the look
   * vector.
   */
  public var rotAngle:Float;

  public var moveDir:Point;

  public function new(x:Int, y:Int) {
    super(x, y);
    spr.filter = new PixelOutline(0x0, 1);

    ct = Main.ME.controller.createAccess('Player');
    // h2d.Tile.fromColor(0xffaaff);
    setup();
  }

  public function setup() {
    setupVars();
    setupCharacter();
  }

  public function setupVars() {
    rotAngle = (1.5 * Math.PI) / 180;
    moveDir = new Point(0, 1);
  }

  public function setupCharacter() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0xffaaff);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
  }

  override function update() {
    super.update();
    updateControls();
  }

  public function updateControls() {
    var left = ct.leftDown();
    var right = ct.rightDown();
    var accl = ct.aDown();
    if ([left, right, accl].exists(el -> el == true)) {
      if (left) {
        mode7.viewA += -rotAngle;
        moveDir.rotate(-rotAngle);
        // mode7.worldPos.x += (SPEED_X);
      }

      if (right) {
        mode7.viewA += rotAngle;
        moveDir.rotate(rotAngle);
        // mode7.worldPos.x += (-SPEED_X);
      }

      if (accl) {
        mode7.worldPos.x += (moveDir.x * SPEED);
        mode7.worldPos.y += (moveDir.y * SPEED);
      }
    }
  }
}