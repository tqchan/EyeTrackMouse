import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 

import org.tritonus.share.*; 
import org.tritonus.share.midi.*; 
import org.tritonus.share.sampled.*; 
import org.tritonus.share.sampled.convert.*; 
import org.tritonus.share.sampled.file.*; 
import org.tritonus.share.sampled.mixer.*; 
import javazoom.spi.*; 
import javazoom.spi.mpeg.sampled.convert.*; 
import javazoom.spi.mpeg.sampled.file.*; 
import javazoom.spi.mpeg.sampled.file.tag.*; 
import javazoom.jl.converter.*; 
import javazoom.jl.decoder.*; 
import javazoom.jl.player.*; 
import javazoom.jl.player.advanced.*; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.signals.*; 
import ddf.minim.spi.*; 
import ddf.minim.ugens.*; 
import ddf.minim.javasound.*; 
import org.tritonus.sampled.file.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class EyeTrackMouse extends PApplet {

  //minim\u30e9\u30a4\u30d6\u30e9\u30ea\u306e\u30a4\u30f3\u30dd\u30fc\u30c8

float grid[][];
PVector point;
PImage img,birdImage;
Bird[] bird = new Bird[10];
int R,G,B = 0;
int frame = 60;
PGraphics pg,birdPg,mousePg;
int i = 0;
int _sinMove = 0;
int moveSpeed = 10;
int collisionNum = 0;
PFont font;
int a = 0;
//sin\u6ce2\u4f5c\u6210\u7528
float x, y;  //x, y\u5ea7\u6a19
float A;  //\u632f\u5e45
float w;  //\u89d2\u5468\u6ce2\u6570\uff08\u5468\u671f\uff09
float p2;  //\u52d5\u753b\u7528\u521d\u671f\u4f4d\u76f8
float t2;  //\u30a2\u30cb\u30e1\u30fc\u30b7\u30e7\u30f3\u7528\u7d4c\u904e\u6642\u9593\uff08X\u5ea7\u6a19\uff09
float rad = (TWO_PI/60.0f)/3;//1\u79d2\u30671\u56de\u8ee2\u3059\u308b\u3088\u3046\u306b30\u3067\u5272\u308b\u3002\u5ea6\u6570\u6cd5\u3060\u306812\u00b0,\u66f4\u306b3\u3067\u5272\u308b\u30681\u5468\u671f3\u79d2
float w_r = 0.0f;
float myScale = 100.0f;  //\u753b\u9762\u4e0a\u3067\u898b\u3084\u3059\u3044\u3088\u3046\u306b\u62e1\u5927
Minim minim;  //Minim\u578b\u5909\u6570\u3067\u3042\u308bminim\u306e\u5ba3\u8a00
AudioPlayer player;  //\u30b5\u30a6\u30f3\u30c9\u30c7\u30fc\u30bf\u683c\u7d0d\u7528\u306e\u5909\u6570
AudioPlayer player2;
PrintWriter output; //\u30d5\u30a1\u30a4\u30eb\u66f8\u304d\u51fa\u3057
String mode; //\u30e2\u30fc\u30c9\u683c\u7d0d
int _bx, _by;

public void setup() {
  
  frameRate(frame);
  img = loadImage("data/kumo2.png");
  pg = createGraphics(width, height);
  pg.beginDraw();
  pg.image(img,0, 0, width, height);
  pg.endDraw();
    //\u65e5\u672c\u8a9e\u3092\u8868\u793a\u3059\u308b\u305f\u3081\u306b\u30d5\u30a9\u30f3\u30c8\u3092\u6307\u5b9a
  font = createFont("Yu Gothic",48,true);
  textFont(font);
  for (int i = 0; i < bird.length; i++) {
    bird[i] = new Bird();
    bird[i].setup();
  }
  a = width;
  w_r = width / rad;
  //mouse\u306b\u9ce5\u306e\u753b\u50cf
  mousePg = createGraphics(width, height);
  mousePg.beginDraw();
  mousePg.image(birdImage, 0, 0);
  mousePg.endDraw();
  //\u97f3\u697d
  minim = new Minim(this);  //\u521d\u671f\u5316
  player = minim.loadFile("bgm.mp3");  //mp3\u3092\u30ed\u30fc\u30c9\u3059\u308b
  player.play();  //\u518d\u751f
  player2 = minim.loadFile("atari.mp3");
  String filename = nf(year(),4) + nf(month(),2) + nf(day(),2) + nf(hour(),2) + nf(minute(),2) + nf(second(),2);
  // \u65b0\u3057\u3044\u30d5\u30a1\u30a4\u30eb\u3092\u751f\u6210
  output = createWriter( filename + ".csv");
  output.println("unixtime,mouseX,mouseY,collision,mode");
}

public void draw() {
  image(pg, 0, 0);
  noStroke();
  Mouse(mouseX,mouseY);
  String outTime = nf(year(),4) + nf(month(),2) + nf(day(),2) + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + millis();
  if ((_sinMove % 2) == 0) {
    for (int i = 0; i < bird.length; i++) {
      bird[i].draw();
      bird[i].collision();
    }
  } else {
    bird[0].draw();
    bird[0].collision();
  }
  textSize(30);
  text("\u5f97\u70b9\uff1a" + collisionNum, 10, 30);
  if ((_sinMove % 2) == 1) {
    mode = "sin_mode" + "," + _bx + "," + _by;
  } else {
    mode = "mode" + (i % 2);
  }
  
  output.println(outTime + "," + mouseX + "," + mouseY + "," + collisionNum + "," + mode);
}

public void Mouse(float mX, float mY){
  // fill(R,G,B,255);
  float ix = mX - (birdImage.width / 2);
  float iy = mY - (birdImage.height / 2);
  image(mousePg, ix, iy);
  // ellipse(mX, mY, 10, 10);
}

public void keyPressed(){
  if (key == ENTER) {
    exit();
  }
  // if (key == BACKSPACE) {
  //   _sinMove++;
  // }
  if (key == ' ') {
    _sinMove++;
  }
}

public void mousePressed(){
  i++;
}


class Bird {
  int birdX,birdY;

  public void setup() {
    birdImage = loadImage("data/bird.png");
    birdImage.resize(0, height/10);
    birdPg = createGraphics(width/10, height/10);
    if (i % 2 == 0) {
      birdX = (int)random(0, width);
      birdY = (int)random(0, height);
    } else {
      birdY = (int)random(0, height);
      birdX = (int)random(0, width);
    }
    birdPg.beginDraw();
    birdPg.image(birdImage, 0, 0);
    birdPg.endDraw();
    A = 200.0f;    //\u632f\u5e45\u3092\u8a2d\u5b9a
    w = 1.0f;    //\u89d2\u5468\u6ce2\u6570\u3092\u8a2d\u5b9a
    p2 = 0.0f;    //\u521d\u671f\u4f4d\u76f8\u3092\u8a2d\u5b9a
    t2 = 0.0f;    //\u7d4c\u904e\u6642\u9593\u3092\u521d\u671f\u5316
  }

  public void draw() {
    image(birdPg, birdX, birdY);
    noStroke();
    sinMove();
    if ((_sinMove % 2) == 0) {
      if (i % 2 == 0) {
        birdY += moveSpeed;
        if (birdY >= height) {
          birdX = (int)random(0, width);
          birdY = 0;
        }
      } else {
        birdX -= moveSpeed;
        if ((birdX <= 0) || (width <= birdX)) {
          birdY = (int)random(0, height);
          birdX = width;
          a = width;
        }
      }
    }
    _bx = birdX;
    _by = birdY;
  }

  public void collision(){
    int bX,bY,mX,mY;
    bX = birdX;
    bY = birdY;
    mX = mouseX;
    mY = mouseY;
    if ((_sinMove % 2) == 0) {
      if (bX <= mX && mX <= bX + birdImage.width && bY <= mY && mY <= bY + birdImage.height){
        if (i % 2 == 0) {
          birdX = (int)random(0, width);
          birdY = 0;
        } else {
          birdY = (int)random(0, height);
          birdX = width;
        }
        player2.play();
        player2.rewind();  //\u518d\u751f\u304c\u7d42\u308f\u3063\u305f\u3089\u5dfb\u304d\u623b\u3057\u3066\u304a\u304f
        collisionNum ++;
      }
    }
  }

  public void sinMove(){
    if ((_sinMove % 2) == 1 ) {
      x = t2*myScale;
      y = -A*sin(w*t2 + p2);
      birdX = (int)x;
      birdY = (int)y + height / 2;
      float gamen = width/4 * rad;
      if (t2 > gamen) {
        t2 = 0.0f;//\u753b\u9762\u306e\u7aef\u306b\u884c\u3063\u305f\u3089\u539f\u70b9\u306b\u623b\u308b
      }
      if (birdX <= mouseX && mouseX <= (birdX + birdImage.width) && birdY <= mouseY && mouseY <= (birdY + birdImage.height)) {
        t2 += rad;    //\u6642\u9593\u3092\u9032\u3081\u308b
      }
    } else {
      t2 = 0.0f;
    }
  }
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "EyeTrackMouse" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
