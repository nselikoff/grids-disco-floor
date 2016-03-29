import wblut.processing.*;
import wblut.hemesh.*;
import wblut.geom.*;
import wblut.core.*;
import wblut.math.*;
import de.looksgood.ani.*;
import oscP5.*;
import netP5.*;
import codeanticode.syphon.*;
import java.util.*;

SyphonServer server;

OscP5 oscP5;
NetAddress myBroadcastLocation; 

WB_Render render;

PShader texlightShader;
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
  server = new SyphonServer(this, "sketch_thread_lattice");

  // smooth(8);
  frameRate(60);

  colorMode(HSB, 1.0);

  textures = new ArrayList<PImage>();
  textures.add(loadImage("tex-v2.png"));
  textures.add(loadImage("tex2.png"));
  textures.add(loadImage("tex3-v2.png"));

  texlightShader = loadShader("texlightfrag.glsl", "texlightvert.glsl");

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

  // bigTiles = new ArrayList<Tile>();

  // for (int i = 0; i < 40; i++) {
  //   float x = 5000;
  //   float z = (i-1) * 2000;
  //   bigTiles.add(new Tile(x, 0, z, 300));
  //   bigTiles.add(new Tile(-1000, 0, z, 300));
  // }

  // render = new WB_Render( this );

  b1 = color(light1Hue, light1Sat*0.5, light1Val*0.5);
  b2 = color(light2Hue, light2Sat, light2Val);
}

void update() {
  // directionalLight(255, 0, 0, 1, 2, -1);
  // directionalLight(0, 0, 255, -1, 2, 1);
  directionalLight(light1Hue, light1Sat, light1Val, -1, 0, 0);
  directionalLight(light2Hue, light2Sat, light2Val, 0, 0, -1);
  directionalLight(0.125, 0.125, 0.25, 0, 1, 0);
  // ambientLight(0.25, 0.25, 0.25);
  ambientLight(0,0,0);
  lightFalloff(1, 0, 0);
  lightSpecular(0, 0, 0);

  // shader(texlightShader);

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
  camera(eye.x, eye.y, eye.z + zOffset, lookAt.x, lookAt.y, lookAt.z + zOffset, 0, 1, 0);

  for (Tile tile : tiles) {
    tile.update();
  }
  // for (Tile tile : bigTiles) {
  //   tile.update();
  // }
}

void draw() {
  background(0);

  draw2d();

  // 3D
  hint(ENABLE_DEPTH_TEST);

  update();

  // stroke(0, 0, 64);
  // strokeWeight(2);
  // noFill();
  // for (int i = 0; i < 100; i++) {
  //   float x1 = -100;
  //   float x2 = 3000;
  //   float z1 = -10 + i * 20;
  //   float z2 = -10 + i * 20;
  //   line(x1, -10, z1, x2, -10, z2);
  // }
  // for (int i = 0; i < 100; i++) {
  //   float x1 = i * 20;
  //   float x2 = i * 20;
  //   float z1 = -100;
  //   float z2 = 3000;
  //   line(x1, -10, z1, x2, -10, z2);
  // }

  // noStroke();
  // stroke(0);
  // fill(255);
  for (Tile tile : tiles) {
    tile.draw();
  }
  // for (Tile tile : bigTiles) {
  //   tile.draw(render);
  // }

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
    camSwitch = floatVal;
  }
  else if (addr.equals("/FromVDMX/Slider3")) {
    // light1Hue = floatVal;
  }
  else if (addr.equals("/FromVDMX/Slider4")) {
    // light1Sat = floatVal;
  }
  else if (addr.equals("/FromVDMX/Slider5")) {
    // light1Val = floatVal;
  }
  else if (addr.equals("/FromVDMX/Slider6")) {
    // light2Hue = floatVal;
  }
  else if (addr.equals("/FromVDMX/Slider7")) {
    // light2Sat = floatVal;
  }
  else if (addr.equals("/FromVDMX/Slider8")) {
    // light2Val = floatVal;
  }
  else if (addr.equals("/FromVDMX/S1")) {
  }
  else if (addr.equals("/FromVDMX/M1")) {
  }
  else if (addr.equals("/FromVDMX/R1")) {
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