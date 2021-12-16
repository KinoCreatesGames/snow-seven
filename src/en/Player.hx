package en;

import particles.Dust2D;
import shaders.ColorShader;
import hxd.snd.Channel;
import h2d.col.Bounds;
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

  public var freeze(get, null):ColorShader;

  inline function get_freeze() {
    return Boot.ME.freeze;
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

  public static inline var SNOW_AMT:Float = 0.5;

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

  /**
   * Shader Parameters
   */
  public var initialFov:Float;

  public var initialFar:Float;
  public var initialFreeze:Float;

  /**
   * Rotation angle for when the vehicle moves
   * left or right and should rotate the look
   * vector.
   */
  public var rotAngle:Float;

  public var moveDir:Point;

  public var acceleration:Float;

  public var isAccelerating:Bool;

  // Dust Controls
  public var dustParticles:Dust2D;

  // Drifting Controls
  public var driftParticles:Drift2D;
  public var driftOver = false;

  /**
   * Drift Multiplier.
   * This multiplier goes up 
   * the longer that you've been drifting for.
   */
  public var driftMultiplier:Float;

  public var isDrifting(get, null):Bool;

  public var score:Int;

  // Sounds
  public var driftSound:Channel;
  public var engineSound:Channel;

  public inline function get_isDrifting() {
    return !moveDir.equals(driftDir);
  }

  // Frustrum for the game using shader information
  // Far Clipping Plane
  public var farL:Vector;
  public var farR:Vector;
  // Near Clipping Plane
  public var nearL:Vector;
  public var nearR:Vector;

  /**
   * Direction that the player is drifting in when moving
   * the drift button is held down.
   */
  public var driftDir:Point;

  public var angDir:Point;

  public var worldPos:Point;

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
    initialFreeze = freeze.strength;
    snowAccum = 0.0;
    acceleration = 0;
  }

  public function setupCharacter() {
    var shadowG = new h2d.Graphics(spr);
    var shadowT = hxd.Res.img.shadow.toTile();
    shadowG.beginTileFill(0, 0, 1, 1, shadowT);
    var size = 32;
    shadowG.drawRect(0, 0, size, size);
    // shadowG.scale(2);
    shadowG.endFill();
    shadowG.blendMode = Alpha;
    shadowG.alpha = 0.7;

    var g = new h2d.Graphics(spr);
    var t = hxd.Res.img.ship.toTile();
    g.beginTileFill(0, 0, 1, 1, t);
    g.drawRect(0, 0, size, size);
    // g.scale(2);
    g.endFill();
    var gDrift = new h2d.Graphics(spr);
    gDrift.beginFill(0, 0);
    gDrift.drawRect(-100, -100, Game.ME.w(), Game.ME.h());
    gDrift.endFill();
    driftParticles = new Drift2D(gDrift, hxd.Res.img.drift.toTexture());
    driftParticles.x += size;
    dustParticles = new Dust2D(gDrift);
    dustParticles.y += (size - 4);
    dustParticles.x += (size / 2);
  }

  override function update() {
    super.update();
    updateSounds();
    updateLevelVariables();
    updateFrustrum();
    handleEffects();
    updateParticles();
    updateSnow();
    updateControls();
    updateCollisions();
  }

  public function updateSounds() {}

  /**
   * Updates Variables tha t
   * are important to the game's 
   * Core Scoring Mechanisms
   */
  public function updateLevelVariables() {
    if (acceleration > 0) {
      score += Std.int(1 * driftMultiplier);
      hud.invalidate();
    }
    if (!isDrifting) {
      driftMultiplier = 1;
    } else {
      driftMultiplier += 0.1;
    }
  }

  public function updateFrustrum() {
    var worldX = mode7.worldPos.x;
    var worldY = mode7.worldPos.y;
    worldPos = new Point(worldX, worldY);
    var far = mode7.far;
    var near = mode7.near;
    var viewAngle = mode7.viewA;
    var cos = Math.cos;
    var sin = Math.sin;
    var fov = mode7.fov;
    farL = new Vector(worldX + cos(viewAngle - fov) * far,
      worldY + sin(viewAngle - fov) * far);
    farR = new Vector(worldX + cos(viewAngle + fov) * far,
      worldY + sin(viewAngle + fov) * far);
    nearL = new Vector(worldX + cos(viewAngle - fov) * near,
      worldY + sin(viewAngle - fov) * near);
    nearR = new Vector(worldX + cos(viewAngle + fov) * near,
      worldY + sin(viewAngle + fov) * near);
  }

  public function withinFrustrum(entity:Entity) {
    var pOne = new Point(farL.x, farL.y);
    var pTwo = new Point(nearR.x, nearR.y);
    var depth = 0.1;
    var start = new Point((farL.x - nearL.x) / depth + nearL.x,
      (farL.y - nearL.y) / depth + nearL.y);

    var end = new Point((farR.x - nearR.x) / depth + nearR.x,
      (farR.y - nearR.y) / depth + nearR.y);
    var bBox = Bounds.fromPoints(start, end);
    var bBoxFlip = Bounds.fromPoints(end, start);

    // Normalize entity location on the map
    var modeTex = mode7.texture;
    var normLoc = new Point((entity.spr.x / modeTex.width),
      (entity.spr.y / modeTex.height));

    // trace(bBox.contains(normLoc));
    // if (!cd.has('test')) {
    //   cd.setS('test', 2, () -> {
    //     trace('Box Information ${bBox.xMin} | ${bBox.xMax}');
    //     trace('Box x: \n ${bBox.yMin} | ${bBox.yMax}');
    //     trace('Normalized location ${normLoc.x} ---- ${normLoc.y}');
    //   });
    // }

    return bBox.contains(normLoc) || bBoxFlip.contains(normLoc);
  }

  /**
   * Handles the audio effects
   * along with anything else related to the drifting
   * mechanics within the game.
   */
  public function handleEffects() {
    // Snow Accumulate ScreenFx
    freeze.strength = initialFreeze * snowAccum;

    if (acceleration > 0 && !isDrifting) {
      if (engineSound == null || engineSound.isReleased()) {
        engineSound = hxd.Res.sound.engine_sound.play(true);
      }
    }

    if (acceleration <= 0) {
      if (engineSound != null) {
        engineSound.stop();
      }
    }
    if (isDrifting) {
      driftOver = false;

      if (driftSound == null || driftSound.isReleased()) {
        driftSound = hxd.Res.sound.tire_squal_loop.play(true, 0.5);
      }
    }

    if (driftOver == false && !isDrifting) {
      driftOver = true;
      if (driftSound != null) {
        driftSound.stop();
      }
      setSquashX(0.6);
    }
  }

  public function updateParticles() {
    driftParticles.drift.enable = isDrifting;
    dustParticles.dust.enable = acceleration > 0;
  }

  public function updateSnow() {
    if (acceleration > 0) {
      snowAccum += (SNOW_AMT * dt) / 25;
      snowAccum = M.fclamp(snowAccum, 0, 1);
      if (isDrifting) {
        // trace('is drifting');
        snowAccum -= (SNOW_AMT * dt) / 10;
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
        // mode7.near -= (0.1 * dt);
        // trace(mode7.near);
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
      decelerate(cappedSpeed);
    }
    var topSpeed = acceleration;
    mode7.worldPos.x += (moveDir.x * topSpeed);
    mode7.worldPos.y += (moveDir.y * topSpeed);
    // Narrow FoV as you go faster within the game
    var narrowing = M.fclamp((topSpeed / MAX_SPEED) * 0.3, 0, 0.3);
    mode7.far = initialFar * (1 + narrowing * 1.3);
    mode7.fov = (initialFov * (1 + narrowing));
  }

  public function updateCollisions() {
    var cappedSpeed = MAX_SPEED * (1 - (snowAccum * 0.5));
    if (level != null) {
      var wall = level.isWall(mode7.worldPos.x, mode7.worldPos.y);
      if (wall) {
        // Decelerate
        decelerate(cappedSpeed);
      }
    }
  }

  public function decelerate(cappedSpeed) {
    acceleration = M.fclamp(acceleration - (DECEL_SPEED * dt * 0.3), 0.0,
      cappedSpeed);
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

  override inline function dispose() {
    driftParticles.dispose();
    dustParticles.dispose();
    super.destroy();
  }
}