import processing.serial.*;
import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;
import cc.arduino.*;
import org.firmata.*;
import java.lang.Math;

ControlDevice cont;
ControlIO control;
Arduino arduino;
float leftX;
float leftY;
float rightX;
float rightY;
boolean yPressed;
boolean aPressed;
boolean lbPressed;
boolean rbPressed;
int upperAngle;

int angleBase; // 0-180  
int angleShoulder; // 0-180
int angleElbow; // 90-(-90) -> 180-0
int angleWrist; // 140 aligned
int angleServoClawJoint; // 0-180 -> (-90)-90
int angleServoClaw; 

// inverse kinematics variables
float x_; float y_; float z_; // z is height, y is distance from base center out, x is side to side. y,z can only be positive
float phi_h; // helper function variables
float c0 = 9.5; float c1 = 12; float c2 = 12; float c3 = 13.5; // claw length is closed 
float t0; float t1; float t2; float t3; float phi; // phi is predetermined

public static void wait(int ms) {
    try {
        Thread.sleep(ms);
    }
    catch(InterruptedException ex) {
        Thread.currentThread().interrupt();
    }
}


void calcPositions(float x, float y, float z, float phi) { 
   x_ = x; y_ = y; z_ = z; phi_h = phi;

  // calculate pitch angle of base motor
  t0 = atan2(x_, y_);
  
  // finding position of 2DOF end effector
  float wy = y_ - c3 * cos(radians(phi));
  float wz = z_ - c3 * sin(radians(phi)) - c0;

  // shoulder-elbow angle
  float delta = sq(wy) + sq(wz);
  float a2 = (delta - sq(c1) - sq(c2)) / (2 * c1 * c2);
  float s2 = sqrt(1 - sq(a2));
  t2 = atan2(s2, a2);

  // shoulder-base angle
  float s1 = ((c1 + c2 * a2) * wz - c2 * s2 * wy) / delta;
  float a1 = ((c1 + c2 * a2) * wy + c2 * s2 * wz) / delta;
  t1 = atan2(s1,a1);

  // wrist angle
  t3 = radians(phi) - t1 - t2;
  ;
  if (Float.isNaN(t1) || Float.isNaN(t2) || Float.isNaN(t3)) {
    println("unreachable position");
    return;
  }
  
  
  
  println("Angle Calculations: ");
  println(degrees(t0));
  println(degrees(t1));
  println(degrees(t2));
  println(degrees(t3));
}

void setup() {
 size(360, 200);
 control = ControlIO.getInstance(this);
 cont = control.getMatchedDevice("xbs");
 if (cont == null) {
 println("not today chump"); // write better exit statements than me
 System.exit(-1);
 }
 // println(Arduino.list());
 arduino = new Arduino(this, Arduino.list()[2], 57600);
 arduino.pinMode(4, Arduino.SERVO);
 arduino.pinMode(5, Arduino.SERVO);
 arduino.pinMode(6, Arduino.SERVO);
 arduino.pinMode(7, Arduino.SERVO);
 arduino.pinMode(8, Arduino.SERVO);
 arduino.pinMode(9, Arduino.SERVO);
 
 upperAngle = 180;
}

public void getUserInput() {
 leftX = map(cont.getSlider("servoBase").getValue(), -1, 1, 0, 180);
 leftY = map(cont.getSlider("servoElbowLower").getValue(), -1, 1, 0, 180);
 rightX = map(cont.getSlider("servoWrist").getValue(), -1, 1, 80, 180);
 rightY = map(cont.getSlider("servoClawJoint").getValue(), -1, 1, 0, 180);
 yPressed = cont.getButton("servoElbowUpperUp").pressed();
 aPressed = cont.getButton("servoElbowUpperDown").pressed();
 lbPressed = cont.getButton("servoClawOpen").pressed();
 rbPressed = cont.getButton("servoClawClose").pressed();
}

void draw() {
 getUserInput();
 
 arduino.servoWrite(4, (int) degrees(t0));
 arduino.servoWrite(5, (int) degrees(t1));
 arduino.servoWrite(6, (int) (90 - degrees(t2)));
 arduino.servoWrite(7, (int) degrees(t3) + 90);
}
