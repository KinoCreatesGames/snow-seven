package scn;

import shaders.ModeSevShader;
import h2d.col.Point;
import h3d.Vector;
import h2d.col.PixelsCollider;
import hxd.Pixels;
import hxd.snd.Channel;
import en.Tree;
import en.Player;
import particles.Snow2D;

/**
 * Base level for the game that contains most of the setup
 * for any unique levels within the game.
 */
class Level extends dn.Process {
  var game(get, never):Game;

  inline function get_game()
    return Game.ME;

  var fx(get, never):Fx;

  inline function get_fx()
    return Game.ME.fx;

  /** Level grid-based width**/
  public var cWid(get, never):Int;

  inline function get_cWid()
    return 16;

  /** Level grid-based height **/
  public var cHei(get, never):Int;

  inline function get_cHei()
    return 16;

  /** Level pixel width**/
  public var pxWid(get, never):Int;

  inline function get_pxWid()
    return cWid * Const.GRID;

  /** Level pixel height**/
  public var pxHei(get, never):Int;

  inline function get_pxHei()
    return cHei * Const.GRID;

  public var mode(get, null):ModeSevShader;

  public inline function get_mode():ModeSevShader {
    return Boot.ME.mode7;
  }

  /**
   * X Scale
   */
  public var xColScale(get, null):Int;

  public inline function get_xColScale() {
    return Std.int(mode.texture.width / collisionMap.width);
  }

  /**
   * Y Scale
   */
  public var yColScale(get, null):Int;

  public inline function get_yColScale() {
    return Std.int(mode.texture.height / collisionMap.height);
  }

  var invalidated = true;

  // Game specific variables
  public var snow:Snow2D;

  public var player:Player;

  public var data:LDTkProj_Level;
  // Level Music
  public var music:Channel;

  public var objects:Group<Entity>;

  // Level Collision Below

  /**
   * Collision Mapping Using a texture
   * Color Map
   * #4d5061 - Wall Collision Check
   * #5c80bc  - Player Start Position
   * #110f06 - Road Check?
   * #cdd1c4 - Road Check
   * #30323d - Rough spots Check
   */
  public var collisionMap:h3d.mat.Texture;

  /**
   * Wall collision check
   */
  public var wallCol:Int = 0x4d5061;

  public var playerPos:Int = 0x5c80bc;

  /**
   * Road collision check
   */
  public var roadCol:Int = 0xffffff;

  /**
   * Actual pixels used in the colission 
   * checking on the map to determine
   * what's road / what's  not road.
   */
  public var collisionPixels:Pixels;

  public function new(?level:LDTkProj_Level) {
    super(Game.ME);
    createRootInLayers(Game.ME.scroller, Const.DP_BG);
    if (level != null) {
      data = level;
    }
    setup();
  }

  public function setup() {
    setupHUD();
    setupPixels();
    setupMusic();
    setupGroups();
    setupEntities();
    setupCollectibles();
    setupSnow();
  }

  public function setupHUD() {
    Game.ME.hud.show();
  }

  public function setupPixels() {
    // Track Map Collision and pixel upload
    collisionMap = hxd.Res.textures.FinalTrackColMap_png.toTexture();
    // trace(collisionMap.mipLevels);
    collisionPixels = collisionMap.capturePixels();
    // collisionMap.uploadPixels(collisionPixels);
  }

  public function setupMusic() {
    if (music == null) {
      music = hxd.Res.music.Blue_Space_v0_96.play(true);
    }
  }

  public function setupGroups() {
    objects = new Group<Entity>();
  }

  public function setupEntities() {
    createPlayer();
    createObjects();
  }

  public function createPlayer() {
    player = new Player(6, 10);
    // Get World Pos
    var pos = findPixel(playerPos);
    if (pos != null) {
      // Convert to world pos for texture
      mode.worldPos.x = ((pos.x * xColScale) / mode.texture.width);
      mode.worldPos.y = ((pos.y * yColScale) / mode.texture.height);
    }
  }

  public function createObjects() {
    // data.l_Entities.all_Tree.iter((tree) -> {
    // var tree = data.l_Entities.all_Tree[0];
    // var elTree = new Tree(tree);
    // objects.add(elTree);
    // });
  }

  public function setupCollectibles() {}

  public function setupSnow() {
    var snowRoot = Boot.ME.s2d;
    snow = new Snow2D(snowRoot, hxd.Res.textures.SnowTex.toTexture());
  }

  /** TRUE if given coords are in level bounds **/
  public inline function isValid(cx, cy)
    return cx >= 0 && cx < cWid && cy >= 0 && cy < cHei;

  /** Gets the integer ID of a given level grid coord **/
  public inline function coordId(cx, cy)
    return cx + cy * cWid;

  /** Ask for a level render that will only happen at the end of the current frame. **/
  public inline function invalidate() {
    invalidated = true;
  }

  // Collision Detection and also checking the texture map

  public function isWall(x:Float, y:Float) {
    // Grab World Pos and convert to map position
    return isPixelCollide(x, y, wallCol);
  }

  public function isRoad(x:Float, y:Float) {
    return isPixelCollide(x, y, roadCol);
  }

  public function isPlayer(x:Float, y:Float) {
    return isPixelCollide(x, y, playerPos);
  }

  /**
   * Returns the x, y coordinate 
   * in integer x, y texture space  
   * @param color 
   */
  public function findPixel(color:Int) {
    var vec = Vector.fromColor(color);
    vec.a = 1.;
    for (x in 0...collisionPixels.width) {
      for (y in 0...collisionMap.height) {
        var colMapColor = (collisionPixels.getPixelF(x, y));
        if (vec.equals(colMapColor)) {
          return new Vector(x, y);
        }
      }
    }
    return null;
  }

  /**
   * Takes the world position in floating point
   * compares to the pixel coordinate 
   * @param x 
   * @param y 
   */
  public function isPixelCollide(x:Float, y:Float, color:Int) {
    var width = mode.texture.width;
    var height = mode.texture.height;
    var x = (mode.worldPos.x % 1.);
    var y = (mode.worldPos.y % 1.);
    var pX = Std.int((x * width) / xColScale);
    var pY = Std.int((y * height) / yColScale);
    var colMapColor = (collisionPixels.getPixelF(pX, pY));
    var vec = Vector.fromColor(color);
    // Note that the alpha channel coming from the pixels is 1
    // Ends up being 0 from the vector from color we have to account for that;
    vec.a = 1.;
    return vec.equals(colMapColor);
  }

  function render() {
    // Placeholder level render
    // root.removeChildren();
    // for (cx in 0...cWid)
    //   for (cy in 0...cHei) {
    //     var g = new h2d.Graphics(root);
    //     if (cx == 0
    //       || cy == 0
    //       || cx == cWid - 1
    //       || cy == cHei - 1) g.beginFill(0xffcc00); else
    //       g.beginFill(Color.randomColor(rnd(0, 1), 0.5, 0.4));
    //     g.drawRect(cx * Const.GRID, cy * Const.GRID, Const.GRID, Const.GRID);
    //   }
  }

  override function update() {
    super.update();
    handleGameOver();
    handlePause();
  }

  public function handlePause() {
    // Pause
    if (game.ca.isKeyboardPressed(K.ESCAPE)) {
      // hxd.Res.sound.pause_in.play(); - issue playing sound now
      // bgm.pause = true;
      this.pause();
      new Pause();
    }
  }

  public function handleGameOver() {
    if (player.snowAccum >= 1) {
      this.pause();
      new GameOver();
    }
  }

  override function postUpdate() {
    super.postUpdate();

    if (invalidated) {
      invalidated = false;
      render();
    }
  }

  override function onDispose() {
    super.onDispose();
    // Destroy / Dispose all objects
    // Hide the HUD
    Game.ME.hud.hide();
    player.dispose();

    snow.disable();
    // snow = null;

    for (el in objects) {
      el.destroy();
    }

    music.stop();
    music = null;
  }
}