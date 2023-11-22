/* Creation & Computation 2023
   Group Members: Abha Patil, Jessica Patel
   
   PURPOSE: making 3 servos move and opera sounds to play according to the 
   position of a user's face within three vertical sections of the screen.
   
   This code was written using the "faceX servo firmata" and 
   "KnightRider_OpenCV_firmata" code files from Canvas.
*/

// Importing packages - Processing's Sound library is used to play sounds
import cc.arduino.*;
import processing.serial.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import processing.sound.*;

// Declaring objects and assigning names
SoundFile[] soundFiles; // array of sounds
Arduino arduino;
Capture video;
OpenCV opencv;

// Servo pin numbers (it goes GND, 2, 3, 4)
int[] servoPins = {2, 3, 4};

// Choosing which camera, 1 is for webcam
int cameraIndex = 1;

void setup() {
  size(640, 480);

  // Camera selection logic
  String[] cameras = Capture.list();
  printArray(cameras); // viewing list of usable cameras
  if (cameras.length > 0 && cameraIndex < cameras.length) {
    video = new Capture(this, cameras[cameraIndex]);
  } else {
    println("Camera index is out of bounds.");
    exit();
  }
  video.start();
  
  // Initializing computer vision
  opencv = new OpenCV(this, 640, 480);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  // Initializing connection to Arduino
  printArray(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[1], 57600);

  // Seting servo pins as outputs
  for (int i = 0; i < servoPins.length; i++) {
    arduino.pinMode(servoPins[i], Arduino.SERVO);
  }
  
  // Initializing the array of SoundFile instances, loading 3 sound files into array
  soundFiles = new SoundFile[3];
  for (int i = 0; i < soundFiles.length; i++) {
    soundFiles[i] = new SoundFile(this, "sounds/opera" + (i + 1) + ".mp3");
  }
}

void draw() {
  // starting video and dividing screen into 3 sections
  opencv.loadImage(video);
  image(video, 0, 0);
  Rectangle[] faces = opencv.detect();
  int sectionWidth = width / 3; // Dynamically calculate the width of each section

  // Turn off all servos
  for (int i = 0; i < servoPins.length; i++) {
    arduino.servoWrite(servoPins[i], 0);
  }
  
  // Drawing in rectangles
  for (int i = 0; i < servoPins.length; i++) {
    noFill(); // White color for inactive sections
    stroke(0);
    rect(sectionWidth * i, 0, sectionWidth, height); // Adjust height as needed
   }

  // Check if a face is detected and which section it is in
  if (faces.length > 0) {
    int faceX = faces[0].x + faces[0].width / 2; // Center of the first detected face

    // Initiating servo movement and sounds based on face location
    for (int i = 0; i < servoPins.length; i++) {
      if (faceX > sectionWidth * i && faceX < sectionWidth * (i + 1)) {
        fill(255, 0, 0, 100); // Red color for active section
        soundFiles[i].play();
        for (int pos = 0; pos <= 180; pos += 1) // goes from 0 degrees to 180 degrees in steps of 1 degree
        {
          arduino.servoWrite(servoPins[i], pos);
          delay(15); // waits 15 ms for the servo to reach the position
        }
        for (int pos = 180; pos >= 0; pos -= 1) // goes from 180 degrees to 0 degrees
        {
          arduino.servoWrite(servoPins[i], pos);
          delay(15);
        }
      }
      else {
      noFill(); // White color for inactive sections
    }
    noStroke();
    rect(sectionWidth * i, 0, sectionWidth, height); // Adjust height as needed
    } 
  }

  // Draw rectangles around detected faces
  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  for (Rectangle face : faces) {
    rect(face.x, face.y, face.width, face.height);
  }
}

void captureEvent(Capture c) {
  c.read();
}
