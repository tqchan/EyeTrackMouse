// import org.jorgecardoso.processing.eyetribe.*;
// import com.theeyetribe.client.data.*;

// EyeTribe eyeTribe;
float grid[][];
PVector point;
PImage img,birdImage;
Bird[] bird = new Bird[10];
int R,G,B = 0;
int frame = 60;
PGraphics pg,birdPg;
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
  // smooth();
  // point = new PVector();
  // eyeTribe = new EyeTribe(this);
  for (int i = 0; i < bird.length; i++) {
    bird[i] = new Bird();
    bird[i].setup();
  }
  a = width;
  w_r = width / rad;
}

void draw() {
  // background(0);
  image(pg, 0, 0);
  noStroke();
  Mouse(mouseX,mouseY);
  if ((_sinMove % 2) == 0) {
    for (int i = 0; i < bird.length; i++) {
      bird[i].draw();
      bird[i].collision();
    }
  } else {
    bird[0].draw();
    // bird[0].collision();
  }
  
  textSize(30);
  text("得点：" + collisionNum, 10, 30);
}

void Mouse(float mX, float mY){
  fill(R,G,B,255);
  ellipse(mX, mY, 10, 10);
}

void keyPressed(){
  if (key == ENTER) {
    exit();
  }
  if (key == BACKSPACE) {
    _sinMove++;
  }
}

void mousePressed(){
  i++;
}

// void onGazeUpdate(PVector gaze, PVector leftEye_, PVector rightEye_, GazeData data) {
//   if ( gaze != null ) {
//     point = gaze.get();
//     int x = (int)constrain(round(map(point.x, 0, width, 0, COLS-1)), 0, COLS-1);
//     int y = (int)constrain(round(map(point.y, 0, height, 0, ROWS-1)), 0, ROWS-1);
//     grid[y][x] = constrain( grid[y][x]+10, 0, 255);
//   }
// }

// void trackerStateChanged(String state) {
//   println("Tracker state: " + state);
// }


class Bird {
  int birdX,birdY;

  void setup() {
    birdImage = loadImage("data/bird.png");
    birdPg = createGraphics(width/10, height/10);
    if (i % 2 == 0) {
      birdX = (int)random(0, width);
      birdY = 0;
    } else {
      birdY = (int)random(0, height);
      birdX = width;
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
    
  }

  void collision(){
    int bX,bY,mX,mY;
    bX = birdX;
    bY = birdY;
    mX = mouseX;
    mY = mouseY;
    if (bX <= mX && mX <= bX + birdImage.width && bY <= mY && mY <= bY + birdImage.height){
      if (i % 2 == 0) {
        birdX = (int)random(0, width);
        birdY = 0;
      } else {
        birdY = (int)random(0, height);
        birdX = width;
      }
      collisionNum ++;
    }
  }

  void sinMove(){
    if ((_sinMove % 2) == 1 ) {
      // a += moveSpeed;
      // float x = a * (2*PI/width);
      // float y = sin(x);
      // int posY= (int)((-y+2)*(height/4));
      // ellipse(x, posY, 5, 5);
      // birdX = (int)x;
      // birdY = (int)posY;
      // if (birdX <= 0) {
      //     a = width;
      //   }
      x = t2*myScale;
      y = -A*sin(w*t2 + p2);
      // ellipse(x, y + height/2, 10, 10);
      t2 += rad;    //時間を進める
      birdX = (int)x;
      birdY = (int)y + height / 2;
      float gamen = width/4 * rad;
      if (t2 > gamen) {
        t2 = 0.0;//画面の端に行ったら原点に戻る
      }
      text(t2, 10, 20);
    } else {
      t2 = 0.0;
    }
  }
}