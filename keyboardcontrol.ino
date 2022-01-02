#include <Servo.h>
#include <Arduino.h>

// setting on board servo pin locations
int servoPin = 9;
int servoPin2 = 8;
int servoPin3 = 7;
int servoPin4 = 6;
int servoPin5 = 5;
int servoPin6 = 4;

// creating servos
Servo servoBase;
Servo servoShoulder;
Servo servoElbow;
Servo servoWrist;
Servo servoClawJoint;
Servo servoClaw;

// base servo position in degrees
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
int val; // serial read variable

/*
 * set up the initial conditions for the arm
 */
void setup() {
  // begins serial comms
  Serial.begin(9600);

  // set angles
  float angleBase = 0; 
  float angleShoulder = 0;
  float angleElbow = 90;
  float angleWrist = 140;
  float angleServoClawJoint = 180; 
  float angleServoClaw = 90; 
  
  // connect servos to arduino
  servoBase.attach(servoPin);
  servoShoulder.attach(servoPin2);
  servoElbow.attach(servoPin3);
  servoWrist.attach(servoPin4);
  servoClawJoint.attach(servoPin5);
  servoClaw.attach(servoPin6);

  // set servos to base position
  servoBase.write(angleBase); 
  servoShoulder.write(angleShoulder); 
  servoElbow.write(angleElbow); 
  servoWrist.write(angleWrist);
  servoClawJoint.write(angleServoClawJoint); 
  servoClaw.write(angleServoClaw);
  delay(2000);  

  // set servos to base invKin position
  setPosition(10,20, 30, 0);
}

/*
 * run functions continuously
 */
void loop(){
  keyboardControl();
}

/*
 * inverse kinematics algorithm to calculate the  servo angles given end effector location and angle
 */
void setPosition(double x, double y, double z, double gripAngle) { 
  x_ = x; y_ = y; z_ = z; phi = gripAngle;

  // calculate pitch angle of base motor
  t0 = atan2(x_, y_);
  
  // finding position of 2DOF end effector
  float wy = y_ - c3 * cos(radians(phi));
  float wz = z_ - c3 * sin(radians(phi)) - c0;

  // shoulder-elbow angle
  float delta = sq(wy) + sq(wz);
  float a2 = (delta - sq(c1) - sq(c2)) / (2 * c1 * c2);
  float s2 = sqrt(1 - sq(a2)); // elbow down
  t2 = atan2(s2, a2);

  // shoulder-base angle
  float s1 = ((c1 + c2 * a2) * wz - c2 * s2 * wy) / delta;
  float a1 = ((c1 + c2 * a2) * wy + c2 * s2 * wz) / delta;
  t1 = atan2(s1,a1);

  // wrist angle
  t3 = radians(phi) - t1 - t2;

  // if angles return as "nan", find new grip angle phi
  if (isnan(t1)) {
    for (float j = 0; j <= 180; j++) {
      phi_h = j;
      setPositionHelper(x_, y_, z_, phi_h);
      if (isnan(t1) || isnan(t2) || isnan(t3)) {
        continue;
      } else {
        phi = phi_h;
        break;
      }
    }
  }
  
  // if no grip angle achieves a possible orientation, return 
  if (isnan(t1)) {
    Serial.println("unreachable position");
    return;
  }
  
  Serial.println("Angle Calculations: ");
  Serial.println(degrees(t0));
  Serial.println(degrees(t1));
  Serial.println(degrees(t2));
  Serial.println(degrees(t3));
  
  servoBase.write(degrees(t0));
  servoShoulder.write(degrees(t1)); 
  servoElbow.write(90 - degrees(t2)); 
  servoClawJoint.write(degrees(t3) + 90);
}

/*
 * helper function to determine angles if unreachable phi
 */
void setPositionHelper(double x, double y, double z, double phi) { 
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
}

/*
 * connect to putty.exe com5 for continues movment change
 * mapped to keyboard keys
 */ 
void keyboardControl() {
  if (Serial.available()) { // if serial value is available 
    val = Serial.read(); // then read the serial value
    if (val == 'd') { // if value input is equals to d 
      y_++;
      setPosition(x_, y_, z_, phi);
      delay(10);
    }
    if (val == 'a'){ // if value input is equals to d
      y_--;
      setPosition(x_, y_, z_, phi);
      delay(10);
    }
    if (val == 'w') { // if value input is equals to d 
      z_++;
      setPosition(x_, y_, z_, phi);
      delay(10);
    }
    if (val == 's'){ // if value input is equals to d
      z_--;
      setPosition(x_, y_, z_, phi);
      delay(10);
    }
  }
}
