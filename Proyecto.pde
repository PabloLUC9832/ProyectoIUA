//Importan la  librería del fiducial y para el audio
import TUIO.*; 
import processing.sound.*;
//Se declaran variables
TuioProcessing tuio;
int posX;
int posY;

int gameScreen = 0;
int ballX, ballY;
int ballSize = 20;
int ballColor = color(200, 0, 0);
float gravity = 0.15;
float ballSpeedVert = 0;
float ballSpeedHorizon = 3;
float airfriction = 0.0001;
float friction = 0.1;
color racketColor = color(0);
float racketWidth = 250;
float racketHeight = 10;
int racketBounceRate = 20;
int score = 0;
PImage bg,pelota,raqueta;

SoundFile juego;

/********* CONFIGURACIÓN *********/

void setup() {
  size(600, 600);
  tuio = new TuioProcessing(this);
  //Se cargan las imagenes
  bg = loadImage("bg.jpg");  
  pelota = loadImage("pelota.png");
  raqueta = loadImage("raqueta.png");
  //Width es el ancho de la ventana actal(600), y por lo que la posición inicial de la pelota en X es 150 y en Y=120
  ballX=width/4;
  ballY=height/5;
  //Se carga el audio y se reproduce
  juego = new SoundFile(this, "juego.mp3");    
  juego.play(); 
}


/********* DRAW *********/
//Se dibuja el menu
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


//Pantalla inicial
void initScreen() {
  background(0);
  textAlign(CENTER);
  textSize(15);
  text("¡GO UP! Click para iniciar", height/2, width/2);
}
//Si se da click inicia el juego
void gameScreen() {
  background(bg);
  stroke(226, 204, 0);
  text("Puntuación:" + score, 20, 20);
  drawBall();
  applyGravity();
  keepInScreen();
  drawRacket();
  watchRacketBounce();
  applyHorizontalSpeed();  
}
//Pantalla de fin de juego, y si se presiona se reinicia
void gameOverScreen() {
  background(0);
  textAlign(CENTER);
  fill(255);
  textSize(30);
  text("Fin del juego. Puntaje obtenido " + score, height/2, width/2 - 20);
  textSize(15);
  text("Presiona para reiniciar", height/2, width/2 + 10);
}
//Cuando se da click en reiniciar, reinicia las variables
void restart() {
  gameScreen = 0;
  score = 0;
  setup();
  gravity = 0.15;
  ballSpeedVert = 0;
  ballSpeedHorizon = 3;
}

//Se dibuja la pleota cargando la imagen de la pelota de tenis
void drawBall() {
  //fill(ballColor);
  //ellipse(ballX, ballY, ballSize, ballSize);
  image(pelota,ballX,ballY);
}
//Se aplica la gravedad, velocidad con que cae la pelota
void applyGravity() {
  ballSpeedVert += gravity;
  ballY += ballSpeedVert;
  ballSpeedVert -= (ballSpeedVert * airfriction);
}
//Velocidad con que se mueve a los lados en el eje X
void applyHorizontalSpeed() {
  ballX += ballSpeedHorizon;
  ballSpeedHorizon -= (ballSpeedHorizon * airfriction);
}
//Rebote de la pelota a la izquierda
void makeBounceLeft(int surface) {
  ballX = surface+(ballSize/2);
  ballSpeedHorizon*=-1;
  ballSpeedHorizon -= (ballSpeedHorizon * friction);
}
//Rebote de la pelota a la derecha
void makeBounceRight(int surface) {
  ballX = surface-(ballSize/2);
  ballSpeedHorizon*=-1;
  ballSpeedHorizon -= (ballSpeedHorizon * friction);
}
//Rebote de la pelota a en el parte inferior
void makeBounceBottom(int surface) {
  ballY = surface-(ballSize/2);
  ballSpeedVert*=-1;
  ballSpeedVert -= (ballSpeedVert * friction);
  score = score +1;
}
//Rebote de la pelota a en el parte superior
void makeBounceTop(int surface) {
  ballY = surface+(ballSize/2);
  ballSpeedVert*=-1;
  ballSpeedVert -= (ballSpeedVert * friction);
}


void keepInScreen() {
  // Si la pelota cae, la pantalla cambia a fin del juego, y pide reiniciarse
  if (ballY+(ballSize/2) > height) { 
    gameScreen=2;
    gameOverScreen();
  }
  // Si la pelota golpea en la parte superior, rebota llamando al metodo
  if (ballY-(ballSize/2) < 0) {
    makeBounceTop(0);
  }  // Si la pelota golpea en la parte izquierda, rebota llamando al metodo
  if (ballX-(ballSize/2) < 0) {
    makeBounceLeft(0);
  }// Si la pelota golpea en la parte derecha, rebota llamando al metodo
  if (ballX+(ballSize/2) > width) {
    makeBounceRight(width);
  }
}
//Se dibuja la imagen de la raqueta
void drawRacket() {
  //fill(racketColor);
  rectMode(CENTER);
  image(raqueta,posX,posY);
  //rect(posX, posY, racketWidth, racketHeight);
}
//Cuando la pelota golpea con la raqueta
void watchRacketBounce() {
  //overhead- variable para cuando se este tocando la raqueta 
  float overhead = posY;
  if ((ballX+(ballSize/2) > posX-(racketWidth/2)) && (ballX-(ballSize/2) < posX+(racketWidth/2))) {
    if (dist(ballX, ballY, ballX, posY)<=(ballSize/2)+abs(overhead)) {
      if ((ballX+(ballSize/2) > posX-(racketWidth/2)) && (ballX-(ballSize/2) < posX+(racketWidth/2))) {
        if (dist(ballX, ballY, ballX, posY)<=(ballSize/2)+abs(overhead)) {
          //Mientras se este tocando la raqueta, esta aumentara el puntaje en 1
          makeBounceBottom(posY);
          // Al mover la raqueta
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


/********* cuando se da click *********/
void mousePressed() {
  if (gameScreen==0) {
    startGame();
  }
  if (gameScreen==2) {
    restart();
  }
}



void startGame() {
  gameScreen=1;
}

//Metodo para actualizar las coordenadas del objeto 
void updateTuioObject(TuioObject objectTUIO){   
  //Actualizamos las variables globales de las posiciones X y Y
    posX = round (objectTUIO.getX()*width);
    posY = round (objectTUIO.getY()*height);
  
}
