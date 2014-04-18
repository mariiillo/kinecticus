import java.util.Map;
import java.util.Iterator;
import java.awt.Robot;
import java.awt.AWTException;

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
  kinect.enableHand();
  kinect.startGesture(SimpleOpenNI.GESTURE_WAVE);

  // set how smooth the hand capturing should be
  kinect.setSmoothingHands(.5);
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

        float interpolatedX = lerp(previousX, p2d.x, 0.3);
        float interpolatedY = lerp(previousY, p2d.y, 0.3);

        mappedX = int(map(interpolatedX, 0, 640, 0, 1280));
        mappedY = int(map(interpolatedY, 0, 480, 0, 800));

        robot.mouseMove(int(mappedX), int(mappedY));

        previousX = interpolatedX;
        previousY = interpolatedY;
    }
  }
}


// -----------------------------------------------------------------
// hand events

void onNewHand(SimpleOpenNI curkinect,int handId,PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);

  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);

  handPathList.put(handId,vecList);
}

void onTrackedHand(SimpleOpenNI curkinect,int handId,PVector pos)
{
  println("onTrackedHand - handId: " + handId + ", pos: " + pos );

  ArrayList<PVector> vecList = handPathList.get(handId);
  if(vecList != null)
  {
    vecList.add(0,pos);
    if(vecList.size() >= handVecListSize)
      // remove the last point
      vecList.remove(vecList.size()-1);
  }
}

void onLostHand(SimpleOpenNI curkinect,int handId)
{
  println("onLostHand - handId: " + handId);
  handPathList.remove(handId);
}

// -----------------------------------------------------------------
// gesture events

void onCompletedGesture(SimpleOpenNI curkinect,int gestureType, PVector pos)
{
  println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);

  int handId = kinect.startTrackingHand(pos);
  println("hand stracked: " + handId);
}
