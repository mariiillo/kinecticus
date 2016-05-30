import java.util.Map;
import java.util.Iterator;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.event.InputEvent;

import SimpleOpenNI.*;

SimpleOpenNI kinect;
Robot robot;
int handVecListSize = 20;
Map<Integer,ArrayList<PVector>>  handPathList = new HashMap<Integer,ArrayList<PVector>>();
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };

int mappedX;
int mappedY;
float previousX;
float previousY;

void setup()
{
  size(640,480);

  try{
    robot = new Robot();
  }catch(AWTException e){
    e.printStackTrace();
    exit();
  }
  kinect = new SimpleOpenNI(this);
  if(kinect.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!");
     exit();
     return;
  }

  // enable depthMap generation
  kinect.enableDepth();

  // disable mirror
  kinect.setMirror(true);

  // enable hands + gesture generation
  kinect.enableHands();
  kinect.enableGesture();
  kinect.addGesture("RaiseHand");
//  kinect.addGesture("Wave");
  kinect.addGesture("Click");
 }

void draw()
{
  // update the cam
  kinect.update();

  image(kinect.depthImage(),0,0);

  // draw the tracked hands
  if(handPathList.size() > 0)
  {
    Iterator itr = handPathList.entrySet().iterator();
    while(itr.hasNext())
    {
      Map.Entry mapEntry = (Map.Entry)itr.next();
      int handId =  (Integer)mapEntry.getKey();
      ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
      PVector p;
      PVector p2d = new PVector();

        stroke(userClr[ (handId - 1) % userClr.length ]);
        noFill();
        strokeWeight(1);
        Iterator itrVec = vecList.iterator();
        beginShape();
          while( itrVec.hasNext() )
          {
            p = (PVector) itrVec.next();

            kinect.convertRealWorldToProjective(p,p2d);
            vertex(p2d.x,p2d.y);
          }
        endShape();

        stroke(userClr[ (handId - 1) % userClr.length ]);
        strokeWeight(4);
        p = vecList.get(0);
        kinect.convertRealWorldToProjective(p,p2d);
        point(p2d.x,p2d.y);

        float interpolatedX = lerp(previousX, p2d.x, 0.05);
        float interpolatedY = lerp(previousY, p2d.y, 0.05);

        mappedX = (int)map(interpolatedX, 0, 640, 0, 1280);
        mappedY = (int)map(interpolatedY, 0, 480, 0, 800);

        robot.mouseMove((int)(mappedX), (int)(mappedY));

        previousX = interpolatedX;
        previousY = interpolatedY;
    }
  }
}


// -----------------------------------------------------------------
// hand events

void onCreateHands(int handId, PVector position, float time)
{
  println("onNewHand - handId: " + handId + ", pos: " + position);

  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(position);

  handPathList.put(handId,vecList);
}

void onUpdateHands(int handId, PVector position, float time)
{
  println("onUpdateHands - handId: " + handId + ", pos: " + position );
  
  ArrayList<PVector> vecList = handPathList.get(handId);
  if(vecList != null)
  {
    vecList.add(0,position);
    if(vecList.size() >= handVecListSize)
      // remove the last point
      vecList.remove(vecList.size()-1);
  }

  if(position.y < -460 ) {
    robot.mouseWheel(-1);
  }else if(position.y > 480) {
    robot.mouseWheel(1);
  }
}

void onDestroyHands(int handId, float time)
{
  println("onDestroyHands - handId: " + handId);
  println("======== NO HAND IS BEEN TRACKED! =======");
  println("****** SHAKE IT AGAIN TO START TRACKING IT *********");
  handPathList.remove(handId);
  kinect.addGesture("RaiseHand");
}

// -----------------------------------------------------------------
// gesture events

void onRecognizeGesture(String strGesture, PVector idPosition, PVector position) {  
  if(strGesture.equals("RaiseHand")) {
    println("Start tracking hands");
    kinect.removeGesture("RaiseHand");
    kinect.startTrackingHands(position);
  } else if (strGesture.equals("Click")) {
    println("Click");
    robot.mousePress(InputEvent.BUTTON1_MASK);
    robot.mouseRelease(InputEvent.BUTTON1_MASK);
  }
}
