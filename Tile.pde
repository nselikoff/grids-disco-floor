class Tile {

  PVector mPos;
  float mRadius;
  float yOffset = 0;
  boolean mIsUp = false;
  boolean mIsAnimating = false;
  int mDelay;
  int mTimer;
  PShape mCube;
  PShape mThread;

  Tile(float x, float y, float z, PImage tex, float radius) {
    init(x, y, z, radius, tex);
    mCube.setTint(color(0,0,1,0.15));
  }

  Tile(float x, float y, float z, PImage tex) {
    init(x, y, z, 10, tex);
  }

  void init(float x, float y, float z, float radius, PImage tex) {
    mPos = new PVector(x, y, z);
    mRadius = radius;
    mDelay = 180 * int(random(1, 4));
    mTimer = 1000000;
    createCube(tex);
    createThread();
  }

  void draw() {
    pushMatrix();
      translate(mPos.x, mPos.y + yOffset, mPos.z);

      pushMatrix();
        scale(mRadius, mRadius, mRadius);
        
        shape(mCube);
        if (mIsUp) {
          shape(mThread);
        }

      popMatrix();

    popMatrix();  
  }

  void createThread() {
    mThread = createShape();
    mThread.setFill(false);
    mThread.setStroke(color(0,1,1));
    mThread.setStrokeWeight(1);
    mThread.beginShape();
    mThread.vertex(-1, 1,  1);
    mThread.vertex(-1, -1,  1);
    mThread.vertex(-1, -1, -1);
    mThread.vertex( 1, -1, -1);
    mThread.vertex( 1, 1, -1);
    mThread.endShape();
  }

  void createCube(PImage tex) {
    textureMode(NORMAL);
    mCube = createShape();
    mCube.beginShape(QUADS);
    mCube.noStroke();
    mCube.texture(tex);

    // Given one texture and six faces, we can easily set up the uv coordinates
    // such that four of the faces tile "perfectly" along either u or v, but the other
    // two faces cannot be so aligned.  This code tiles "along" u, "around" the X/Z faces
    // and fudges the Y faces - the Y faces are arbitrarily aligned such that a
    // rotation along the X axis will put the "top" of either texture at the "top"
    // of the screen, but is not otherwised aligned with the X/Z faces. (This
    // just affects what type of symmetry is required if you need seamless
    // tiling all the way around the cube)
    
    // +Z "front" face
    mCube.vertex(-1, -1,  1, 0, 0);
    mCube.vertex( 1, -1,  1, 1, 0);
    mCube.vertex( 1,  1,  1, 1, 1);
    mCube.vertex(-1,  1,  1, 0, 1);

    // -Z "back" face
    mCube.vertex( 1, -1, -1, 0, 0);
    mCube.vertex(-1, -1, -1, 1, 0);
    mCube.vertex(-1,  1, -1, 1, 1);
    mCube.vertex( 1,  1, -1, 0, 1);

    // +Y "bottom" face
    mCube.vertex(-1,  1,  1, 0, 0);
    mCube.vertex( 1,  1,  1, 1, 0);
    mCube.vertex( 1,  1, -1, 1, 1);
    mCube.vertex(-1,  1, -1, 0, 1);

    // -Y "top" face
    mCube.vertex(-1, -1, -1, 0, 0);
    mCube.vertex( 1, -1, -1, 1, 0);
    mCube.vertex( 1, -1,  1, 1, 1);
    mCube.vertex(-1, -1,  1, 0, 1);

    // +X "right" face
    mCube.vertex( 1, -1,  1, 0, 0);
    mCube.vertex( 1, -1, -1, 1, 0);
    mCube.vertex( 1,  1, -1, 1, 1);
    mCube.vertex( 1,  1,  1, 0, 1);

    // -X "left" face
    mCube.vertex(-1, -1, -1, 0, 0);
    mCube.vertex(-1, -1,  1, 1, 0);
    mCube.vertex(-1,  1,  1, 1, 1);
    mCube.vertex(-1,  1, -1, 0, 1);

    mCube.endShape();
  }

  void update() {
    mTimer++;
    if (mTimer > mDelay) {
      if (mIsUp) down(); else up();
      mTimer = 0;
    }
  }

  void up() {
    mIsAnimating = true;
    Ani.to(this, 3.0, "yOffset", random(-mRadius, mRadius), Ani.EXPO_IN, "onEnd:setIsUp");
  }

  void setIsUp() {
    mIsUp = true;
    mIsAnimating = false;
  }

  void down() {
    mIsAnimating = true;
    Ani.to(this, 3.0, "yOffset", random(-mRadius, mRadius), Ani.EXPO_IN, "onEnd:setIsDown");
  }

  void setIsDown() {
    mIsUp = false;
    mIsAnimating = false;
  }

};