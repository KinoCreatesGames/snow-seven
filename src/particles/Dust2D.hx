package particles;

import h3d.mat.Texture;
import h2d.Particles.ParticleGroup;
import h2d.Particles;

class Dust2D extends Particles {
  public var dust:ParticleGroup;
  public var tex:Texture;

  public function new(parent:h2d.Object, ?texture:Texture) {
    super(parent);
    if (texture != null) {
      this.tex = texture;
    } else {
      var t = h2d.Tile.fromColor(0xaaaaaa);
      this.tex = t.getTexture();
    }
    // this.blendMode = AlphaMultiply;
    dust = addGroup();
    setup();
  }

  public function setup() {
    dust.name = 'dust';
    dust.texture = tex;
    dust.nparts = 50;
    dust.blendMode = Multiply;
    dust.emitLoop = true;
    dust.emitMode = Box;
    dust.emitDist = 12;
    dust.emitDistY = 1;

    dust.emitAngle = (115 * Math.PI) / 180; // (115 * Math.PI) / 180;
    // dust.speedRand = 0.15;
    dust.speed = 0.15;
    dust.sizeRand = 0.55;
    dust.gravity = 200;
    dust.gravityAngle = 0;
    dust.life = .25;
    dust.lifeRand = .5;
    dust.enable = false;
  }

  public function dispose() {
    dust = null;
  }
}