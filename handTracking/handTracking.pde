import SimpleOpenNI.*;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.event.InputEvent;

SimpleOpenNI  context;
PImage img;
Robot robot;

PVector projRHand;
float previousX;
float previousY;

void setup(){
  size(640, 480);

  context = new SimpleOpenNI(this);
  context.enableDepth();
  context.enableUser();
  context.setMirror(true);

  try {
    robot = new Robot();
  }catch (AWTException e) {
    e.printStackTrace();
  }

  img=createImage(640,480,RGB);
  img.loadPixels();

  context.enableHand();
  context.startGesture(SimpleOpenNI.GESTURE_CLICK);
}

void draw(){
  background(0);
  context.update();
  int[] upix=context.userMap();

  for(int i=0; i < upix.length; i++){
    if(upix[i] > 0){
      img.pixels[i]=color(0,0,255);
    }else{
     img.pixels[i]=color(0);
    }
  }

  img.updatePixels();
  image(img,0,0);
  int[] users=context.getUsers();
  ellipseMode(CENTER);

  for(int i=0; i < users.length; i++){
    int uid=users[i];
    renderPoints(context, uid);
  }

}

// Methods

void renderPoints(SimpleOpenNI context, int uid) {
  if(context.isTrackingSkeleton(uid)){

    //draw right hand
    PVector realRHand = new PVector();
    float confidence = context.getJointPositionSkeleton(uid, SimpleOpenNI.SKEL_LEFT_HAND, realRHand);
    projRHand = new PVector();
    context.convertRealWorldToProjective(realRHand, projRHand);

    // render an ellipse.
    fill(0,255,255);
    float ellipseSize = map(projRHand.z, 700, 2500, 50, 1);

    // render if confidence is high
    if(confidence > 0.5) {
      ellipse(projRHand.x, projRHand.y, ellipseSize, ellipseSize);

      float interpolatedX = lerp(previousX, projRHand.x, 0.05);
      float interpolatedY = lerp(previousY, projRHand.y, 0.05);

      int mappedX = (int)map(interpolatedX, 640, 0, 0, 1280);
      int mappedY = (int)map(interpolatedY, 0, 480, 0, 800);

      robot.mouseMove(mappedX, mappedY);

      checkScroll(mappedY);

      previousX = interpolatedX;
      previousY = interpolatedY;

    }

  }
}

void checkScroll(int posY){
  println("posY: "+posY);
  if(posY < 80 ) {
    robot.mouseWheel(1);
  }else if(posY > 670) {
    robot.mouseWheel(-1);
  }
}

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onCompletedGesture(SimpleOpenNI curkinect,int gestureType, PVector pos)
{
  println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
  robot.mousePress(InputEvent.BUTTON1_MASK);
  robot.mouseRelease(InputEvent.BUTTON1_MASK);
}

