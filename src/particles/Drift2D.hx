package particles;

import h2d.Particles;
import h3d.mat.Texture;

class Drift2D extends Particles {
  public var drift:ParticleGroup;
  public var tex:Texture;

  public function new(parent:h2d.Object, texture:Texture) {
    super(parent);
    this.tex = texture;
    drift = addGroup();
    setup();
  }

  public function setup() {
    drift.name = 'drift';
    drift.emitLoop = false;
    drift.emitMode = Box;
    drift.texture = tex;
    drift.frameCount = 2;
    drift.frameDivisionX = 1;
    drift.frameDivisionY = 1;
    drift.isRelative = false;
    drift.emitDistY = 10;
    drift.emitAngle = 0;
    drift.gravityAngle = (0 * Math.PI) / 180;
    drift.gravity = 10;
    drift.nparts = 25;
    drift.speedRand = .5;
    drift.sizeRand = .5;
    drift.life = 2;
    drift.lifeRand = 1;
    drift.enable = false;
  }

  public function dispose() {
    drift = null;
  }
}