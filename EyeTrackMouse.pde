import ddf.minim.*;  //minimライブラリのインポート
import java.util.Date;

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
//sin波作成用
float x, y;  //x, y座標
float A;  //振幅
float w;  //角周波数（周期）
float p2;  //動画用初期位相
float t2;  //アニメーション用経過時間（X座標）
float rad = (TWO_PI/60.0)/3;//1秒で1回転するように30で割る。度数法だと12°,更に3で割ると1周期3秒
float w_r = 0.0;
float myScale = 100.0;  //画面上で見やすいように拡大
Minim minim;  //Minim型変数であるminimの宣言
AudioPlayer player;  //サウンドデータ格納用の変数
AudioPlayer player2;
PrintWriter output; //ファイル書き出し
String mode; //モード格納
int _bx, _by;
Date d;

void setup() {
  fullScreen();
  frameRate(frame);
  img = loadImage("data/kumo2.png");
  pg = createGraphics(width, height);
  pg.beginDraw();
  pg.image(img,0, 0, width, height);
  pg.endDraw();
    //日本語を表示するためにフォントを指定
  font = createFont("Yu Gothic",48,true);
  textFont(font);
  for (int i = 0; i < bird.length; i++) {
    bird[i] = new Bird();
    bird[i].setup();
  }
  a = width;
  w_r = width / rad;
  //mouseに鳥の画像
  mousePg = createGraphics(width, height);
  mousePg.beginDraw();
  mousePg.image(birdImage, 0, 0);
  mousePg.endDraw();
  //音楽
  minim = new Minim(this);  //初期化
  player = minim.loadFile("bgm.mp3");  //mp3をロードする
  player.play();  //再生
  player2 = minim.loadFile("atari.mp3");
  String filename = "log/" + nf(year(),4) + nf(month(),2) + nf(day(),2) + nf(hour(),2) + nf(minute(),2) + nf(second(),2);
  // 新しいファイルを生成
  output = createWriter( filename + ".csv");
  output.println("unixtime,mouseX,mouseY,collision,mode");
}

void draw() {
  d = new Date();
  image(pg, 0, 0);
  noStroke();
  Mouse(mouseX,mouseY);
  // String outTime = nf(year(),4) + nf(month(),2) + nf(day(),2) + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + millis();
  
  // String outTime = String.valueOf(d.getTime());

  long outTime = d.getTime();
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
  text("得点：" + collisionNum, 10, 30);
  if ((_sinMove % 2) == 1) {
    mode = "sin_mode" + "," + _bx + "," + _by;
  } else {
    mode = "mode" + (i % 2);
  }
  
  output.println(outTime + "," + mouseX + "," + mouseY + "," + collisionNum + "," + mode);
}

void Mouse(float mX, float mY){
  // fill(R,G,B,255);
  float ix = mX - (birdImage.width / 2);
  float iy = mY - (birdImage.height / 2);
  image(mousePg, ix, iy);
  // ellipse(mX, mY, 10, 10);
}

void keyPressed(){
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

void mousePressed(){
  i++;
}


class Bird {
  int birdX,birdY;

  void setup() {
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
    A = 200.0;    //振幅を設定
    w = 1.0;    //角周波数を設定
    p2 = 0.0;    //初期位相を設定
    t2 = 0.0;    //経過時間を初期化
  }

  void draw() {
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

  void collision(){
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
        player2.rewind();  //再生が終わったら巻き戻しておく
        collisionNum ++;
      }
    }
  }

  void sinMove(){
    if ((_sinMove % 2) == 1 ) {
      x = t2*myScale;
      y = -A*sin(w*t2 + p2);
      birdX = (int)x;
      birdY = (int)y + height / 2;
      float gamen = width/4 * rad;
      if (t2 > gamen) {
        t2 = 0.0;//画面の端に行ったら原点に戻る
      }
      if (birdX <= mouseX && mouseX <= (birdX + birdImage.width) && birdY <= mouseY && mouseY <= (birdY + birdImage.height)) {
        t2 += rad;    //時間を進める
      }
    } else {
      t2 = 0.0;
    }
  }
}