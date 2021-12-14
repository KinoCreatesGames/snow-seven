package en;

import particles.Drift2D;
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

  public static inline var MAX_SPEED:Float = 0.0015;

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

  public var driftParticles:Drift2D;
  public var driftOver = false;

  // Drifting Controls
  public var isDrifting(get, null):Bool;

  public inline function get_isDrifting() {
    return !moveDir.equals(driftDir);
  }

  /**
   * Direction that the player is drifting in when moving
   * the drift button is held down.
   */
  public var driftDir:Point;

  public var angDir:Point;

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
    // Drift Dir and Move Dir match at the start
    // These will deviate when the player uses
    // the drift button to move in the opposite dir
    moveDir = new Point(0, 1);
    driftDir = new Point(0, 1);
    // Mode 7 Angle information
    angDir = new Point(0, 1);
    initialFov = mode7.fov;
    initialFar = mode7.far;
    snowAccum = 0.0;
    acceleration = 0;
  }

  public function setupCharacter() {
    var shadowG = new h2d.Graphics(spr);
    var shadowT = hxd.Res.img.shadow.toTile();
    shadowG.beginTileFill(0, 0, 1, 1, shadowT);
    shadowG.drawRect(0, 0, 32, 32);
    shadowG.scale(2);
    shadowG.endFill();
    shadowG.blendMode = Alpha;
    shadowG.alpha = 0.7;
    var g = new h2d.Graphics(spr);
    var t = hxd.Res.img.ship.toTile();
    g.beginTileFill(0, 0, 1, 1, t);
    g.drawRect(0, 0, 32, 32);
    g.scale(2);
    g.endFill();
    var gDrift = new h2d.Graphics(spr);
    gDrift.beginFill(0, 0);
    gDrift.drawRect(-100, -100, Game.ME.w(), Game.ME.h());
    gDrift.endFill();
    driftParticles = new Drift2D(gDrift, hxd.Res.img.drift.toTexture());
    driftParticles.x += 32;
  }

  override function update() {
    super.update();
    handleEffects();
    updateParticles();
    updateSnow();
    updateControls();
  }

  public function handleEffects() {
    if (isDrifting) {
      driftOver = false;
    }

    if (driftOver == false && !isDrifting) {
      driftOver = true;
      setSquashX(0.6);
    }
  }

  public function updateParticles() {
    driftParticles.drift.enable = isDrifting;
  }

  public function updateSnow() {
    if (acceleration > 0) {
      snowAccum += (SNOW_AMT * dt) / 25;
      snowAccum = M.fclamp(snowAccum, 0, 1);
      if (isDrifting) {
        // trace('is drifting');
        snowAccum -= (SNOW_AMT * dt) / 15;
        snowAccum = M.fclamp(snowAccum, 0, 1);
      } else {
        // trace('not drifting');
      }
    }
  }

  public function updateControls() {
    var left = ct.leftDown();
    var right = ct.rightDown();
    var accl = ct.aDown();
    var drift = ct.bDown();

    var cappedSpeed = MAX_SPEED * (1 - (snowAccum * 0.5));
    if ([left, right, accl, drift].exists(el -> el == true)) {
      if (left) {
        var ang = -rotAngle * dt;
        handleDrifting(drift, ang);
        // mode7.worldPos.x += (SPEED_X);
      }

      if (right) {
        var ang = rotAngle * dt;
        handleDrifting(drift, ang);
      }

      if (accl) {
        acceleration = M.fclamp((acceleration + SPEED * dt), 0.0, cappedSpeed);
        var topSpeed = acceleration;
        mode7.worldPos.x += (moveDir.x * topSpeed);
        mode7.worldPos.y += (moveDir.y * topSpeed);
      }

      if (drift) {
        var spd = SPEED * dt * 0.25;
        acceleration = M.fclamp(acceleration - (spd), 0.0, cappedSpeed);
      }
    }
    if (!accl) {
      acceleration = M.fclamp(acceleration - (DECEL_SPEED * dt * 0.3), 0.0,
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

  public function handleDrifting(drift, angle:Float) {
    if (drift) {
      driftDir.rotate(angle);
      mode7.viewA += angle;
      angDir.rotate(angle);
      // moveDir.lerp(moveDir, driftDir, 0.5);
      moveDir.rotate(angle * .50);
    } else {
      // When you let go of the button and they're not equal
      // We dampen the drifting angle
      // driftDir.rotate(angle);
      mode7.viewA += angle;
      angDir.rotate(angle);
      moveDir.lerp(moveDir, angDir, .8);
      // moveDir.rotate(angle * (1 + (moveDir.)));
      driftDir.lerp(driftDir, moveDir, 1);
    }
  }
}