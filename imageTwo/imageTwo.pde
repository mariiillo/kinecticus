import SimpleOpenNI.*;
SimpleOpenNI kinect;

int closestValue;
int closestX;
int closestY;
float lastX;
float lastY;

float image1X;
float image1Y;
float image1scale;
int image1width = 100;
int image1height = 100;

float image2X;
float image2Y;
float image2scale;
int image2width = 100;
int image2height = 100;

float image3X;
float image3Y;
float image3scale;
int image3width = 100;
int image3height = 100;

int currentImage = 1;

PImage image1;
PImage image2;
PImage image3;

void setup()
{
  size(640, 480);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  image1 = loadImage("img1.png");
  image2 = loadImage("img2.png");
  image3 = loadImage("img3.png");
}

void draw(){
  background(0);
  closestValue = 8000;
  kinect.update();
  int[] depthValues = kinect.depthMap();
  for(int y = 0; y < 480; y++){
    for(int x = 0; x < 640; x++){
      int reversedX = 640-x-1;
      int i = reversedX + y * 640;
      int currentDepthValue = depthValues[i];
      if(currentDepthValue > 610 && currentDepthValue < 1525 && currentDepthValue < closestValue){
        closestValue = currentDepthValue;
        closestX = x;
        closestY = y;
      }
    }
  }
  float interpolatedX = lerp(lastX, closestX, 0.3);
  float interpolatedY = lerp(lastY, closestY, 0.3);

  switch(currentImage){
    case 1:
      image1Y = interpolatedY;
      image1X = interpolatedX;
      image1scale = map(closestValue, 610,1525, 0,4);
      break;
    case 2:
      image2X = interpolatedX;
      image2Y = interpolatedY;
      image2scale = map(closestValue, 610,1525, 0,4);
      break;
    case 3:
      image3X = interpolatedX;
      image3Y = interpolatedY;
      image3scale = map(closestValue, 610,1525, 0,4);
      break;
  }

  image(image1,image1X,image1Y, image1width * image1scale, image1height * image1scale);
  image(image2,image2X,image2Y, image2width * image2scale, image2height * image2scale);
  image(image3,image3X,image3Y, image3width * image3scale, image3height * image3scale);

  lastX = interpolatedX;
  lastY = interpolatedY;
}

void mousePressed(){
  currentImage++;
  if(currentImage > 3){
    currentImage = 1;
  }
  println(currentImage);
}
