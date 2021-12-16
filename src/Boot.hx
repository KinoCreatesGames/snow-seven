/**
  This class is the entry point for the app.
  It doesn't do much, except creating Main and taking care of app speed ()
**/

import shaders.ModeSevShader;
import shaders.CompositeShader;
import h3d.Vector;
import shaders.ColorShader;
import h3d.pass.ScreenFx;
import h3d.shader.ScreenShader;
import h3d.mat.Texture;
import h3d.mat.TextureArray;
import h3d.Engine;
import renderer.CustomRenderer;
import dn.heaps.Controller;
import dn.heaps.Controller.ControllerAccess;

class Boot extends hxd.App {
  public static var ME:Boot;

  public var renderer:CustomRenderer;
  public var mode7:ModeSevShader;
  public var freeze:ColorShader;

  #if debug
  var tmodSpeedMul = 1.0;
  var ca(get, never):ControllerAccess;

  inline function get_ca()
    return Main.ME.ca;
  #end

  /**
    App entry point
  **/
  static function main() {
    new Boot();
  }

  /**
    Called when engine is ready, actual app can start
  **/
  override function init() {
    ME = this;
    renderer = new CustomRenderer();
    s3d.renderer = renderer;
    new Main(s2d);
    var ground = hxd.Res.textures.TestTrack.toTexture();
    ground.wrap = Repeat;
    var sky = hxd.Res.textures.NightSky.toTexture();
    sky.wrap = Repeat;
    mode7 = new ModeSevShader(ground);
    mode7.skyTexture = sky;

    var finalTex = new Texture(engine.width, engine.height, [Target]);
    freeze = new ColorShader(Vector.fromColor(0xaaffff), finalTex);
    freeze.strength = .4;
    onResize();
  }

  override function onResize() {
    super.onResize();
    dn.Process.resizeAll();
  }

  /** Main app loop **/
  override function update(deltaTime:Float) {
    super.update(deltaTime);

    // Controller update
    Controller.beforeUpdate();

    var currentTmod = hxd.Timer.tmod;
    #if debug
    if (Main.ME != null && !Main.ME.destroyed) {
      // Slow down app (toggled with a key)
      if (ca.isKeyboardPressed(K.NUMPAD_SUB)
        || ca.isKeyboardPressed(K.HOME) || ca.dpadDownPressed())
        tmodSpeedMul = tmodSpeedMul >= 1 ? 0.2 : 1;
      currentTmod *= tmodSpeedMul;

      // Turbo (by holding a key)
      currentTmod *= ca.isKeyboardDown(K.NUMPAD_ADD)
        || ca.isKeyboardDown(K.END) || ca.ltDown() ? 5 : 1;
    }
    #end

    // Update all dn.Process instances
    dn.Process.updateAll(currentTmod);
  }

  @:access(h3d.scene.Scene, h3d.scene.Renderer, CustomRenderer)
  override function render(e:Engine) {
    // Grab Render Texture for the 2D scene so that can make modifications
    // Level Rendering
    if (Game.ME != null && Game.ME.level != null) {
      var level = Game.ME.level;
      var shader = mode7;
      var renderTarget = new Texture(engine.width, engine.height, [Target]);
      // Composite Shader
      var compShader = new CompositeShader(new TextureArray(engine.width,
        engine.height, 3, [Target]));
      engine.pushTarget(compShader.textures, 2);
      engine.clear(0, 1);

      // Disable level snow before render texture screen shader pass
      Game.ME.scroller.visible = true;
      level.snow.visible = false;
      s2d.render(e);
      engine.popTarget();

      // Dsiable level before rendering snow
      level.snow.visible = true;
      Game.ME.scroller.visible = false;

      engine.pushTarget(compShader.textures, 1);
      engine.clear(0, 1);
      s2d.render(e);
      engine.popTarget();

      // Compsite for all textures passed into the texture array
      ScreenFx.run(shader, compShader.textures, 0);
      ScreenFx.run(compShader, freeze.texture, 0);
      // Color Screen
      new ScreenFx(freeze).render();
    } else {
      super.render(e);
    }
  }
}