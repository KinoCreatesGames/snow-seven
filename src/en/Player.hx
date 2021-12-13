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
  public static inline var SPEED:Float = 0.0005;

  /**
   * Horizontal speed for turning
   */
  public static inline var SPEED_X:Float = 0.0001;

  public static inline var DECEL_SPEED:Float = 0.0025;

  public static inline var MAX_SPEED:Float = 0.00125;

  public static inline var SNOW_AMT:Float = 1;

  /**
   * Amount of snow 
   * that will affect your maximum speed.
   */
  public static inline var SNOW_CAP:Float = 0.5;

  /**
   * The amount of snow that has been accumulated
   * while driving.
   */
  public var snowAccum:Float;

  public var initialFov:Float;
  public var initialFar:Float;

  /**
   * Rotation angle for when the vehicle moves
   * left or right and should rotate the look
   * vector.
   */
  public var rotAngle:Float;

  public var moveDir:Point;

  public var acceleration:Float;

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
    rotAngle = (130 * Math.PI) / 180;
    moveDir = new Point(0, 1);
    initialFov = mode7.fov;
    initialFar = mode7.far;
    snowAccum = 0.0;
    acceleration = 0;
  }

  public function setupCharacter() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0xffaaff);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
  }

  override function update() {
    super.update();
    updateSnow();
    updateControls();
  }

  public function updateSnow() {
    if (acceleration > 0) {
      snowAccum += (SNOW_AMT * dt) / 25;
      snowAccum = M.fclamp(snowAccum, 0, 1);
    }
  }

  public function updateControls() {
    var left = ct.leftDown();
    var right = ct.rightDown();
    var accl = ct.aDown();
    var cappedSpeed = MAX_SPEED * (1 - (snowAccum * 0.5));
    if ([left, right, accl].exists(el -> el == true)) {
      if (left) {
        mode7.viewA += -rotAngle * dt;
        moveDir.rotate(-rotAngle * dt);
        // mode7.worldPos.x += (SPEED_X);
      }

      if (right) {
        mode7.viewA += rotAngle * dt;
        moveDir.rotate(rotAngle * dt);
        // mode7.worldPos.x += (-SPEED_X);
      }

      if (accl) {
        acceleration = M.fclamp((acceleration + SPEED * dt), 0.0, cappedSpeed);
        var topSpeed = acceleration;
        mode7.worldPos.x += (moveDir.x * topSpeed);
        mode7.worldPos.y += (moveDir.y * topSpeed);
      }
    }
    if (!accl) {
      acceleration = M.fclamp(acceleration - (DECEL_SPEED * dt), 0.0,
        cappedSpeed);
    }
    var topSpeed = acceleration;
    mode7.worldPos.x += (moveDir.x * topSpeed);
    mode7.worldPos.y += (moveDir.y * topSpeed);
    // Narrow FoV as you go faster within the game
    var narrowing = M.fclamp((topSpeed / MAX_SPEED) * 0.3, 0, 0.3);
    mode7.far = initialFar * (1 + narrowing * 1.3);
    mode7.fov = (initialFov * (1 + narrowing));
  }
}