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
      // Mode7
      var texColor = textures.get(vec3(input.uv, 0));
      // Characters
      var texThree = textures.get(vec3(input.uv, 2));
      var result = texColor + texThree;
      if (texThree.a > 0.1) {
        result = texThree;
        if (texThree.b > .90) {
          texThree.rgb = texThree.bbb;
          texThree.a = 1;
          result = texThree + texColor;
        }
      }
      pixelColor = result;
    }
  }

  public function new(textures:TextureArray) {
    super();
    this.textures = textures;
  }
}