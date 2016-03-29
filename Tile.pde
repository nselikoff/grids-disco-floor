class Tile {

  PVector mPos;
  float mRadius;
  float yOffset = 0;
  boolean mIsUp = false;
  boolean mIsAnimating = false;
  int mDelay;
  int mTimer;
  float mAlpha = 0;
  // HE_Mesh mesh;
  // color mTopColor;
  PShape mCube;

  Tile(float x, float y, float z, PImage tex, float radius) {
    init(x, y, z, radius, tex);
  }

  Tile(float x, float y, float z, PImage tex) {
    init(x, y, z, 10, tex);
  }

  void init(float x, float y, float z, float radius, PImage tex) {
    mPos = new PVector(x, y, z);
    mRadius = radius;
    // mDelay = 10 * int(random(4*mRadius, 10*mRadius));
    mDelay = 180 * int(random(1, 4));
    mTimer = 1000000;
    // Ani.to(this, 4.0, "mAlpha", 255);
    Ani.to(this, 4.0, "mAlpha", 1);

    // mesh = new HE_Mesh( new HEC_Cube().setRadius( mRadius ) );

    // loop through the faces of the cube, assign a color to each face
    // and store it in the label field of the HE_Face
    // Colors in Processing are integers, and the label field of HE_Face
    // is also an integer, so this will work fine!
    /*
    color[] colors = { #a0003d, #f77900, #003cba, #00a12a, #ff5341, #1d89fc };
    int currentFace = 0;
    for ( HE_Face f : mesh.getFacesAsList() ) {
      if (currentFace == 2) {
        mTopColor = colors[int(random(0,5))];
        f.setLabel( mTopColor );
      } else {
        f.setLabel( #ffffff );
      }

      currentFace++;
    }

    for (HE_Halfedge e : mesh.getHalfedgesAsList()) {
      if (random(0, 1) > 0.9)
        e.setLabel( #00ffff );
      else
        e.setLabel( #000000 );
    }
    */

    createCube(tex);

  }

  void draw() {
    pushMatrix();
    // fill(255, mAlpha);
    fill(1.0, mAlpha);
    translate(mPos.x, mPos.y + yOffset, mPos.z);
    // box(mRadius);
    // render.drawFaces(mesh);
    
    // Draw each face separately instead of drawing all faces at once
    // Use the label of the face as the fill color.
    /*
    for ( HE_Face f : mesh.getFacesAsList() ) {
      noStroke();
      fill( f.getLabel() );
      if (f.getLabel() != #ffffff && (mIsAnimating || mIsUp) ) {
        emissive(f.getLabel());
      } else {
        emissive(0);
      }
      render.drawFace( f, tex );
    }
    */
    pushMatrix();
    scale(mRadius, mRadius, mRadius);
    shape(mCube);
    popMatrix();

    // strokeWeight(3);
    // for (HE_Halfedge e : mesh.getHalfedgesAsList()) {
    //   if (e.getLabel() != #000000) {
    //     emissive(e.getLabel());
    //     stroke( e.getLabel() );
    //     render.drawEdge( e );
    //   }
    // }

    // emissive(0);
    

    popMatrix();  
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
    // float multiplier = 1.0;//mIsUp ? 1.0 : 5.0;
    if (mTimer > mDelay /* * multiplier */) {
      if (mIsUp) down(); else up();
      mTimer = 0;
    }
  }

  void up() {
    mIsAnimating = true;
    // Ani.to(this, 0.5*mRadius, "yOffset", -mRadius * 0.125, Ani.ELASTIC_OUT, "onEnd:setIsUp");
    Ani.to(this, 3.0, "yOffset", random(-mRadius, mRadius), Ani.EXPO_IN, "onEnd:setIsUp");
  }

  void setIsUp() {
    mIsUp = true;
    mIsAnimating = false;
  }

  void down() {
    mIsAnimating = true;
    // Ani.to(this, 0.25*mRadius, "yOffset", 0.0, Ani.EXPO_IN, "onEnd:setIsDown");
    Ani.to(this, 3.0, "yOffset", random(-mRadius, mRadius), Ani.EXPO_IN, "onEnd:setIsDown");
  }

  void setIsDown() {
    mIsUp = false;
    mIsAnimating = false;
  }

};