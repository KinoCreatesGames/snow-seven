package shaders;

import h3d.mat.TextureArray;
import h3d.shader.ScreenShader;
import h3d.Vector;
import h3d.mat.Texture;
import h3d.mat.TextureArray;

class CompositeShader extends ScreenShader {
  static var SRC = {
    /**
     * Render texture we use to make
     * screen modifications.
     */
    @param var textures:Sampler2DArray;

    /**
     * The color vector for tinting
     * the game with that specified color.
     */
    function fragment() {
      var texColor = textures.get(vec3(input.uv, 0));
      var texTwo = textures.get(vec3(input.uv, 1));
      var texThree = textures.get(vec3(input.uv, 2));
      var result = texColor + texTwo;
      if (texThree.r > 0.1) {
        result = texThree;
      }
      pixelColor = result;
    }
  }

  public function new(textures:TextureArray) {
    super();
    this.textures = textures;
  }
}