import SimpleOpenNI.*;
SimpleOpenNI kinect;

int closestValue;
int closestX;
int closestY;
float previousX;
float previousY;

void setup()
{
  size(640, 480);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();

  background(0);
}

void draw() {
  closestValue = 8000;
  kinect.update();

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

  stroke(255, 0, 0);
  strokeWeight(3);
  line(previousX, previousY, interpolatedX, interpolatedY);

  previousX = interpolatedX;
  previousY = interpolatedY;
}

void mousePressed(){
  save("img.png");
  background(0);
}
