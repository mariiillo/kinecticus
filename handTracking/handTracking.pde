import SimpleOpenNI.*;

SimpleOpenNI  context;
PImage img;


void setup(){
  //set size of the application window
  size(640, 480);

  //initialize context variable
  context = new SimpleOpenNI(this);

  //asks OpenNI to initialize and start receiving depth sensor's data
  context.enableDepth();

  //asks OpenNI to initialize and start receiving User data
  context.enableUser();

  //enable mirroring - flips the sensor's data horizontally
  context.setMirror(true);

  //... add more variable initialization code here...

  img=createImage(640,480,RGB);
  img.loadPixels();
}

void draw(){
  //clears the screen with the black color, this is usually a good idea
  //to avoid color artefacts from previous draw iterations
  background(0);

  //asks kinect to send new data
  context.update();

  //retrieves depth image
  PImage depthImage=context.depthImage();
  depthImage.loadPixels();

  //get user pixels - array of the same size as depthImage.pixels, that gives information about the users in the depth image:
  // if upix[i]=0, there is no user at that pixel position
  // if upix[i] > 0, upix[i] indicates which userid is at that position
  int[] upix=context.userMap();

  //colorize users
  for(int i=0; i < upix.length; i++){
    if(upix[i] > 0){
      //there is a user on that position
      //NOTE: if you need to distinguish between users, check the value of the upix[i]
      img.pixels[i]=color(0,0,255);
    }else{
      //add depth data to the image
      // if you want to show only the user, type
      // img.pixels[i] = color(0); // color(0) corresponds to black
     img.pixels[i]=depthImage.pixels[i];
    }
  }
  img.updatePixels();

  //draws the depth map data as an image to the screen
  //at position 0(left),0(top) corner
  image(img,0,0);

  //draw significant points of users

  //get array of IDs of all users present
  int[] users=context.getUsers();

  ellipseMode(CENTER);

  //iterate through users
  for(int i=0; i < users.length; i++){
    int uid=users[i];

    //draw center of mass of the user (simple mean across position of all user pixels that corresponds to the given user)
    PVector realCoM=new PVector();

    //get the CoM in realworld (3D) coordinates
    context.getCoM(uid,realCoM);
    PVector projCoM=new PVector();

    //convert realworld coordinates to projective (those that we can use to draw to our canvas)
    context.convertRealWorldToProjective(realCoM, projCoM);
    fill(255,0,0);
    ellipse(projCoM.x,projCoM.y,10,10);

    //check if the user skeleton is been tracked.
    if(context.isTrackingSkeleton(uid)){

      //draw right hand
      PVector realRHand = new PVector();

      // if you want to track the right hand, type SimpleOpenNI.SKEL_LEFT_HAND and viceversa.
      float confidence = context.getJointPositionSkeleton(uid, SimpleOpenNI.SKEL_LEFT_HAND, realRHand);

      // convert a 3D point to 2D to merge it with the depth image.
      PVector projRHand = new PVector();
      context.convertRealWorldToProjective(realRHand, projRHand);

      // render an ellipse.
      fill(0,255,255);
      float ellipseSize = map(projRHand.z, 700, 2500, 50, 1);

      // render if confidence is high
      if(confidence > 0.5) {
        ellipse(projRHand.x, projRHand.y, ellipseSize, ellipseSize);
      }

    }
  }

}

//is called everytime a new user appears
void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  //asks OpenNI to start tracking a skeleton data for this user
  //NOTE: you cannot request more than 2 skeletons at the same time due to the perfomance limitation
  //      so some user logic is necessary (e.g. only the closest user will have a skeleton)
  curContext.startTrackingSkeleton(userId);
}

//is called everytime a user disappears
void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);

}
