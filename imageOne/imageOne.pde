import SimpleOpenNI.*;
SimpleOpenNI kinect;

int closestValue;
int closestX;
int closestY;
float previousX;
float previousY;
float image1X;
float image1Y;

PImage image1;

boolean imageMoving;

void setup()
{
  size(640, 480);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  imageMoving = true;

  image1 = loadImage("wat.jpg");
  background(0);
}

void draw() {
  closestValue = 8000;
  kinect.update();

  background(0);

  int[] depthValues = kinect.depthMap();

  for(int row = 0; row < 480; row++){
    for(int pixelInRow = 0; pixelInRow < 640; pixelInRow++){
      int reversedX = 640 - pixelInRow - 1;
      int pixel = reversedX + row * 640;
      int currentDepthValue = depthValues[pixel];

      // 600 corresponds to 600 mm (60cm) and 1500 to 1.5m
      if(currentDepthValue > 600 && currentDepthValue < 1500 && currentDepthValue < closestValue){
        closestValue = currentDepthValue;
        closestX = pixelInRow;
        closestY = row;
      }
    }
  }

  float interpolatedX = lerp(previousX, closestX, 0.3);
  float interpolatedY = lerp(previousY, closestY, 0.3);

  if(imageMoving){
    image1X = interpolatedX;
    image1Y = interpolatedY;
  }
  image(image1,image1X,image1Y);
  previousX = interpolatedX;
  previousY = interpolatedY;
}

void mousePressed(){
  imageMoving = !imageMoving;
}
