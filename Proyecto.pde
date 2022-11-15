import TUIO.*; //Importar librería
import processing.sound.*;

TuioProcessing tuio;
int posX;
int posY;

int gameScreen = 0;
int ballX, ballY;
int ballSize = 20;
int ballColor = color(200, 0, 0);
float gravity = 0.25;
float ballSpeedVert = 0;
float ballSpeedHorizon = 3;
float airfriction = 0.0001;
float friction = 0.1;
color racketColor = color(0);
float racketWidth = 100;
float racketHeight = 10;
int racketBounceRate = 20;
int score = 0;
PImage bg,pelota,raqueta;

SoundFile juego;

/********* SETUP BLOCK *********/

void setup() {
  size(600, 600);
  tuio = new TuioProcessing(this);
  bg = loadImage("bg.jpg");
  pelota = loadImage("pelota.png");
  raqueta = loadImage("raqueta.png");
  ballX=width/4;
  ballY=height/5;
  
  juego = new SoundFile(this, "juego.mp3");  
  
  juego.play(); 
}


/********* DRAW BLOCK *********/

void draw() {
  //Dibujar un circulo en la posición X y Y del marcador, tamaño 20px x 20px
  if (gameScreen == 0) {
    initScreen();
  } else if (gameScreen == 1) {
    gameScreen();
  } else if (gameScreen == 2) {
    gameOverScreen();
  }
}


/********* SCREEN CONTENTS *********/

void initScreen() {
  background(0);
  textAlign(CENTER);
  textSize(15);
  text("¡GO UP! Click para iniciar", height/2, width/2);
}

void gameScreen() {
  background(bg);
  stroke(226, 204, 0);
  text("score " + score, 20, 20);
  drawBall();
  applyGravity();
  keepInScreen();
  drawRacket();
  watchRacketBounce();
  applyHorizontalSpeed();  
}

void gameOverScreen() {
  background(0);
  textAlign(CENTER);
  fill(255);
  textSize(30);
  text("Fin del juego. Puntaje obtenido " + score, height/2, width/2 - 20);
  textSize(15);
  text("Presiona para reiniciar", height/2, width/2 + 10);
}

void restart() {
  gameScreen = 0;
  score = 0;
  setup();
  gravity = 0.25;
  ballSpeedVert = 0;
  ballSpeedHorizon = 3;
}


void drawBall() {
  //fill(ballColor);
  //ellipse(ballX, ballY, ballSize, ballSize);
  image(pelota,ballX,ballY);
}

void applyGravity() {
  ballSpeedVert += gravity;
  ballY += ballSpeedVert;
  ballSpeedVert -= (ballSpeedVert * airfriction);
}

void applyHorizontalSpeed() {
  ballX += ballSpeedHorizon;
  ballSpeedHorizon -= (ballSpeedHorizon * airfriction);
}

void makeBounceLeft(int surface) {
  ballX = surface+(ballSize/2);
  ballSpeedHorizon*=-1;
  ballSpeedHorizon -= (ballSpeedHorizon * friction);
}

void makeBounceRight(int surface) {
  ballX = surface-(ballSize/2);
  ballSpeedHorizon*=-1;
  ballSpeedHorizon -= (ballSpeedHorizon * friction);
}

void makeBounceBottom(int surface) {
  ballY = surface-(ballSize/2);
  ballSpeedVert*=-1;
  ballSpeedVert -= (ballSpeedVert * friction);
  score = score +1;
}

void makeBounceTop(int surface) {
  ballY = surface+(ballSize/2);
  ballSpeedVert*=-1;
  ballSpeedVert -= (ballSpeedVert * friction);
}


void keepInScreen() {
  // if the ball hits floor
  if (ballY+(ballSize/2) > height) { 
    gameScreen=2;
    gameOverScreen();
  }
  // If we hit the top
  if (ballY-(ballSize/2) < 0) {
    makeBounceTop(0);
  }
  if (ballX-(ballSize/2) < 0) {
    makeBounceLeft(0);
  }
  if (ballX+(ballSize/2) > width) {
    makeBounceRight(width);
  }
}
void drawRacket() {
  //fill(racketColor);
  rectMode(CENTER);
  image(raqueta,posX,posY);
  //rect(posX, posY, racketWidth, racketHeight);
}
void watchRacketBounce() {
  float overhead = posY - pmouseY;
  if ((ballX+(ballSize/2) > posX-(racketWidth/2)) && (ballX-(ballSize/2) < posX+(racketWidth/2))) {
    if (dist(ballX, ballY, ballX, posY)<=(ballSize/2)+abs(overhead)) {
      if ((ballX+(ballSize/2) > posX-(racketWidth/2)) && (ballX-(ballSize/2) < posX+(racketWidth/2))) {
        if (dist(ballX, ballY, ballX, posY)<=(ballSize/2)+abs(overhead)) {
          makeBounceBottom(posY);
          // racket moving up
          if (overhead<0) {
            ballY+=overhead;
            ballSpeedVert+=overhead;
            ballSpeedHorizon = (ballX - posX)/5;
          }
        }
      }
    }
  }
}


/********* INPUTS *********/
void mousePressed() {
  if (gameScreen==0) {
    startGame();
  }
  if (gameScreen==2) {
    restart();
  }
}



/********* OTHER FUNCTIONS *********/

void startGame() {
  gameScreen=1;
}

//Metodo para actualizar las coordenadas del objeto 
void updateTuioObject(TuioObject objectTUIO){   
  //Actualizamos las variables globales de las posiciones X y Y
    posX = round (objectTUIO.getX()*width);
    posY = round (objectTUIO.getY()*height);
  
}
