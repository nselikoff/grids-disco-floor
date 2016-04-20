import de.looksgood.ani.*;
import oscP5.*;
import netP5.*;
import codeanticode.syphon.*;
import java.util.*;

SyphonServer server;

OscP5 oscP5;
NetAddress myBroadcastLocation; 

PShader texlightShader, lineShader;
ArrayList<PImage> textures;

PVector lookAt2 = new PVector(650, 1030, 920);
PVector eye2 = new PVector(-10, -50, 30);
// PVector lookAt = new PVector(840, 910, 920);
// PVector eye = new PVector(-10, -110, 30);
// PVector lookAt = new PVector(840, 340, 920);
// PVector eye = new PVector(-10, -100, 30);
PVector lookAt, eye;
PVector lookAt1 = new PVector(850, 210, 920);
PVector eye1 = new PVector(-10, -40, 30);
float camSwitch = 0;
float yOffset = 0;
float yOffsetDelayed = 0;
float zOffset = 0;

int nextRow = 20;
int numColumns = 20;

// int screenWidth = 1280, screenHeight = 289;
int screenWidth = 1920, screenHeight = 434;

ArrayList<Tile> tiles;
ArrayList<Tile> bigTiles;

float light1Hue = 0.12;
float light1Sat = 0.54;
float light1Val = 0.58;
float light2Hue = 0.61;
float light2Sat = 0.76;
float light2Val = 0.09;

int Y_AXIS = 1;
int X_AXIS = 2;
color b1, b2;

void settings() {
  size(screenWidth, screenHeight, P3D);
  PJOGL.profile=1; // OpenGL 1.2 / 2.x context, for Syphon compatibility
}

void setup() {
  
  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "sketch_disco_floor");

  // smooth(8);
  frameRate(60);

  colorMode(HSB, 1.0);

  textures = new ArrayList<PImage>();
  textures.add(loadImage("tex-v2.png"));
  textures.add(loadImage("tex2.png"));
  textures.add(loadImage("tex3-v2.png"));

  texlightShader = loadShader("texlightfrag.glsl", "texlightvert.glsl");
  lineShader = loadShader("linefrag.glsl", "linevert.glsl");

  Ani.init(this);

  /* create a new instance of oscP5. 
   * 12000 is the port number you are listening for incoming osc messages.
   */
  oscP5 = new OscP5(this,12000);

  tiles = new ArrayList<Tile>();

  for (int i = 0; i < nextRow; i++) {
    for (int j = 0; j < numColumns; j++) {
      float x = -50 + j * 20;
      float z = i * 20;
      tiles.add(new Tile(x, 0, z, textures.get(int(random(0,3)))));
    }
  }

  bigTiles = new ArrayList<Tile>();

  bigTiles.add(new Tile(5000, 0, 5000, textures.get(int(random(0,3))), 1000));
  bigTiles.add(new Tile(5000, -500, 15000, textures.get(int(random(0,3))), 1000));
  bigTiles.add(new Tile(0, 0, 15000, textures.get(int(random(0,3))), 300));
  bigTiles.add(new Tile(10000, 0, 2000, textures.get(int(random(0,3))), 300));
  bigTiles.add(new Tile(15000, 2000, 2000, textures.get(int(random(0,3))), 2000));

  b1 = color(light1Hue, light1Sat*0.5, light1Val*0.5);
  b2 = color(light2Hue, light2Sat, light2Val);

  hint(ENABLE_STROKE_PERSPECTIVE);
}

void update() {

  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), cameraZ/10.0, cameraZ*10.0);
  camera();

  directionalLight(light1Hue, light1Sat, light1Val, -1, 0, 0);
  directionalLight(light2Hue, light2Sat, light2Val, 0, 0, -1);
  directionalLight(0.125, 0.125, 0.25, 0, 1, 0);
  ambientLight(0,0,0);
  lightFalloff(1, 0, 0);
  lightSpecular(0, 0, 0);

  // shader(texlightShader);
  // shader(lineShader, LINES);


  // spawn new tiles, erase old tiles
  if (frameCount % 600 == 0) {
    for (int i = 0; i < numColumns; i++) {
      float x = -50 + i * 20;
      float z = nextRow * 20;
      tiles.add(new Tile(x, 0, z, textures.get(int(random(0,3)))));
    }
    nextRow++;
    tiles.subList(0, numColumns).clear();
    // println("total tiles: " + tiles.size());
    println(frameRate);

    // Ani.to(this, 1.0, "zOffset", zOffset + 20);
  }

  zOffset += 0.0333;

  lookAt = PVector.lerp(lookAt1, lookAt2, camSwitch);
  eye = PVector.lerp(eye1, eye2, camSwitch);
  perspective(PI/6, float(width)/float(height), 1.0, 100000.0);
  camera(eye.x, eye.y + yOffsetDelayed, eye.z + zOffset, lookAt.x, lookAt.y + yOffsetDelayed, lookAt.z + zOffset, 0, 1, 0);

  for (Tile tile : tiles) {
    tile.update();
  }
  // for (Tile tile : bigTiles) {
  //   tile.update();
  // }
}

void draw() {
  background(0,0);

  // draw2d();

  // 3D
  // hint(ENABLE_DEPTH_TEST);

  update();

  pushMatrix();
    translate(0, yOffset, 0);
    for (Tile tile : tiles) {
      tile.draw();
    }
    for (Tile tile : bigTiles) {
      tile.draw();
    }
  popMatrix();

  server.sendScreen();

}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  String addr = theOscMessage.addrPattern();
  String typetag = theOscMessage.typetag();
  float floatVal = 0;
  boolean boolVal = false;
  
  if (typetag.equals("f"))
    floatVal = theOscMessage.get(0).floatValue();
  else if (typetag.equals("b"))
    boolVal = theOscMessage.get(0).booleanValue();
  
  if (addr.equals("/FromVDMX/Slider1")) {
  }
  else if (addr.equals("/FromVDMX/Slider2")) {
  }
  else if (addr.equals("/FromVDMX/Slider3")) {
  }
  else if (addr.equals("/FromVDMX/Slider4")) {
  }
  else if (addr.equals("/FromVDMX/Slider5")) {
    camSwitch = floatVal;
  }
  else if (addr.equals("/FromVDMX/Slider6")) {
  }
  else if (addr.equals("/FromVDMX/Slider7")) {
  }
  else if (addr.equals("/FromVDMX/Slider8")) {
  }
  else if (addr.equals("/FromVDMX/S1")) {
  }
  else if (addr.equals("/FromVDMX/M1")) {
  }
  else if (addr.equals("/FromVDMX/R1")) {
  }
  else if (addr.equals("/FromVDMX/track/prev")) {
    float newYOffset = yOffset + 500;
    Ani.to(this, 1.0, "yOffset", newYOffset);
    Ani.to(this, 3.0, "yOffsetDelayed", newYOffset);
  }
  else if (addr.equals("/FromVDMX/track/next")) {
    float newYOffset = yOffset - 300;
    Ani.to(this, 1.0, "yOffset", newYOffset);
    Ani.to(this, 3.0, "yOffsetDelayed", newYOffset);
  }

  // theOscMessage.print();
}

void keyPressed(KeyEvent e) {
  if (e.isAltDown()) {

    if (keyCode == RIGHT) {
      lookAt1.x += 10;
    } else if (keyCode == LEFT) {
      lookAt1.x -= 10;
    } else if (keyCode == UP) {
      if (e.isShiftDown())
        lookAt1.z += 10;
      else
        lookAt1.y -= 10;
    } else if (keyCode == DOWN) {
      if (e.isShiftDown())
        lookAt1.z -= 10;
      else
        lookAt1.y += 10;
    }

  } else {

    if (keyCode == RIGHT) {
      eye1.x += 10;
    } else if (keyCode == LEFT) {
      eye1.x -= 10;
    } else if (keyCode == UP) {
      if (e.isShiftDown())
        eye1.z += 10;
      else
        eye1.y -= 10;
    } else if (keyCode == DOWN) {
      if (e.isShiftDown())
        eye1.z -= 10;
      else
        eye1.y += 10;
    }

  }

  if (key == ' ') {
    println("eye1: " + eye1);
    println("lookAt1: " + lookAt1);
  }
}

void draw2d() {
  hint(DISABLE_DEPTH_TEST);

  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), cameraZ/10.0, cameraZ*10.0);
  camera();

  noLights();

  beginShape();
  fill(b1);
  vertex(width,0);
  vertex(width,height);
  fill(b2);
  vertex(0,height);
  vertex(0,0);
  endShape(CLOSE);
}