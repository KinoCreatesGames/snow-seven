package shaders;

import h3d.Vector;
import h3d.mat.Texture;
import h3d.shader.ScreenShader;

/**
 * A shader that puts the screen
 * within a mode seven mode.
 * this will make things further 
 * away from the screen render in
 * a 3d View.
 */
class ModeSevShader extends ScreenShader {
  static var SRC = {
    @param var screenSize:Vec2;
    @param var skyTexture:Sampler2D;
    @param var texture:Sampler2D;
    @param var worldPos:Vec2;

    /**
     * The view angle within
     * the game's frustrum.
     */
    @param var viewA:Float;

    /**
     * Near Plane in 2D space.
     */
    @param var near:Float;

    /**
     * Far clipping plane in 2D space.
     */
    @param var far:Float;

    /**
     * Field of view 
     * this is the angle 
     * that the player is looking
     * at in space.
     */
    @param var fov:Float;

    // Mode 7 We consider y to be the further away
    // We decide on the horizon
    function fragment() {
      // https://en.wikipedia.org/wiki/Mode_7
      var uv = input.uv;
      var horizon = 0.3;

      // 3D Coordinates
      var result = uv;
      var viewAngle = viewA;

      var worldY = worldPos.y;
      var worldX = worldPos.x;
      // Plane Coords Frustrum 2D Points
      var farL = vec2(worldX + cos(viewAngle - fov) * far,
        worldY + sin(viewAngle - fov) * far); // var split = 0.5;
      var farR = vec2(worldX + cos(viewAngle + fov) * far,
        worldY + sin(viewAngle + fov) * far);

      var nearL = vec2(worldX + cos(viewAngle - fov) * near,
        worldY + sin(viewAngle - fov) * near);
      var nearR = vec2(worldX + cos(viewAngle + fov) * near,
        worldY + sin(viewAngle + fov) * near);

      var depth = uv.y;
      var start = vec2((farL.x - nearL.x) / depth + nearL.x,
        (farL.y - nearL.y) / depth + nearL.y);

      var end = vec2((farR.x - nearR.x) / depth + nearR.x,
        (farR.y - nearR.y) / depth + nearR.y);

      // sample X
      var sevenSample = vec2((end.x - start.x) * uv.x + start.x,
        (end.y - start.y) * uv.x + start.y);
      if (uv.y > horizon) {
        result = sevenSample;
      }

      var texColor = texture.get(result);
      if (uv.y < horizon) {
        result.y = (1 - sevenSample.y);
        texColor = skyTexture.get(vec2(uv.x, uv.y / .4));
      }

      pixelColor = texColor;
    }
  }

  public function new(texture:Texture) {
    super();
    this.texture = texture;
    this.worldPos = new Vector(0.35, .3);
    this.viewA = (90 * 3.14) / 180;
    this.near = -0.0025; // -0.25
    this.far = 0.040; // 0.030
    this.fov = (3.14 / 4);
  }
}