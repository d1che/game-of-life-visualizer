import processing.sound.*;
import processing.opengl.*;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Program name: game of life
//  Author: Willem Deen
//  Copyright: 2013
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

AudioIn input;
Amplitude amp;
FFT fft;
BeatDetector beat;
Sound device;
int bands = 512;
float[] spectrum = new float[bands];

Sim simulation;

boolean monitoring, simulating;
int barSize, upDown, w, h, gridSize, FFTPos, beatRamp;
float x, y;

void setup() 
{
  println(Sound.list().toString());
  // sketch stuff
  size(2560, 1440, P3D);
  background(0);
  colorMode(HSB);
  frameRate(30);
  smooth();

  // audio stuff
  input = new AudioIn(this, 0);
  device = new Sound(this);
  amp = new Amplitude(this);
  fft = new FFT(this, bands);
  beat = new BeatDetector(this);

  input.start();
  device.inputDevice(14);
  amp.input(input);
  fft.input(input);
  beat.sensitivity(1);

  monitoring = true;
  simulating = false;
  // other stuff
  w = 1000;
  h = 1000;
  x = 490;
  y = 491;
  upDown = 10;
  gridSize = 10;
  barSize = 850;
  beatRamp = 0;
  simulation = new Sim(w/gridSize, h/gridSize);
}

void draw() 
{
  background(0);
  fft.analyze(spectrum);
  if (spectrum[1] > 0.2 || beatRamp >= 1000) beatRamp = 0;
  else beatRamp += 80;
  //println(beat.isBeat());
  setCamera();
  if (simulating) simulation.calculatePixels();
  //drawRoom();
  //drawGrid();
  drawPixels();
}

// VISUALS

void drawRoom()
{
  translate(w/2, h/2, 2200);
  fill(255, 0, 255);
  box(1500, 1500, 5000);
  noFill();
  translate(-w/2, -h/2, -2200);  
}

void drawGrid()
{
  stroke(0, 0, 0);
  for (int i=0; i<w; i+=gridSize)
  {
    line(0, i+gridSize/2, w, i+gridSize/2);
  }

  for (int i=0; i<h; i+=gridSize)
  {
    line(i+gridSize/2, 0, i+gridSize/2, h);
  }
  noStroke();
}


void drawPixels()
{
  int state = -1;
  simulation.resetIndex();
  noStroke();
  for (int i=0; i<h/gridSize; i++)
  {
    for (int j=0; j<w/gridSize; j++)
    {
      state = simulation.getPixel();
      barSize = 1000-beatRamp;
      fill(180, 255, 255, 255);
      if (state < -1)
      {
        specular(204, 102, 255);
        shininess(1.0);
        translate(i*gridSize, j*gridSize, barSize/2);
        box(gridSize, gridSize, barSize);
        translate(-(i*gridSize), -(j*gridSize), -barSize/2);
      }
      noFill();
    }
  }
}

void addType(int obj, int xPos, int yPos)
{
  PImage img;
  switch(obj)
  {
    case 1: img = loadImage("shapes/toad_6x6.bmp"); break;
    case 2: img = loadImage("shapes/blinker_5x5.bmp"); break;
    case 3: img = loadImage("shapes/evolver_7x7.bmp"); break;
    case 4: img = loadImage("shapes/glider_gun_38x11.bmp") ;break;
    case 5: img = loadImage("shapes/bank.bmp"); break;
    case 6: img = loadImage("shapes/peace.bmp"); break;
    default: img = loadImage("shapes/blinker_5x5.bmp");
  }
  
  img.loadPixels();

  simulation.setPixels(img, xPos, yPos);
}

void setCamera()
{
  pointLight(128, 0, 255, 200, 490, barSize+400);
  pointLight(255, 0, 255, 400, 490, barSize+400);
  pointLight(128, 0, 255, 600, 490, barSize+400);
  pointLight(255, 0, 255, 800, 490, barSize+400);
  camera(x, y, 1200, 490, 490, 490, 0, 0, -1);
}

void angleToXY(int angle, int dist)
{
  float distance = dist;
  x = 490+(cos(radians(angle)))*(distance);
  y = 490+(sin(radians(angle)))*(distance);
 
}

// KEYBINDS

void keyPressed()
{
  if (key == CODED)
  { 
    switch (keyCode)
    {
    case UP: upDown = upDown-10; println("upDown: " + upDown); break;
    case DOWN: upDown = upDown+10; println("upDown: " + upDown); break;
    case LEFT: FFTPos--; println("FFTPos: " + FFTPos); break;
    case RIGHT: FFTPos++; println("FFTPos: " + FFTPos); break;
    }
  } 

  switch (key)
  {
    case 49: addType(1, 46, 46); break;
    case 50: addType(2, 46, 46); break;
    case 51: addType(3, 46, 46); break;
    case 52: addType(4, 46, 46); break;
    case 53: addType(5, 46, 46); break;
    case 54: addType(6, 0, 0); break;
    case 's': simulating ^= true; break;
    case 'a': simulation.calculatePixels(); break;
    case 'm': monitoring ^= true; break;
    case 'r': simulation.clearPixels(); break;
  }
}
