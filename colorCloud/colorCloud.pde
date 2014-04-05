import processing.opengl.*;
import SimpleOpenNI.*;

SimpleOpenNI kinect;
float rotation = 0;

void setup() {
  size(1024, 768, OPENGL);
  kinect = new SimpleOpenNI(this);

  kinect.enableDepth();
  kinect.enableRGB();
  kinect.alternativeViewPointDepthToImage();
}

void draw() {
  background(0);
  kinect.update();
  PImage rgbImage = kinect.rgbImage();

  translate(width/2, height/2, -250);
  rotateX(radians(180));
  translate(0, 0, 1000);

  rotation = map(mouseX, 0, width, -180, 180);
  rotateY(radians(rotation));

  PVector[] depthPoints = kinect.depthMapRealWorld();
  for (int i = 0; i < depthPoints.length; ++i) {
    PVector currentPoint = depthPoints[i];
    stroke(rgbImage.pixels[i]);
    point(currentPoint.x, currentPoint.y, currentPoint.z);
  }
}
