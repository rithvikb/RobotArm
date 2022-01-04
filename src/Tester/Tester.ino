#include <Servo.h>

int servoPin = 9;
int servoPin2 = 8;
int servoPin3 = 7;
int servoPin4 = 6;
int servoPin5 = 5;
int servoPin6 = 4;


Servo servoBase;
Servo servoElbowLower;
Servo servoElbowUpper;
Servo servoWrist;
Servo servoClawJoint;
Servo servoClaw;

int angleBase = 0;   // servo position in degrees
int angleElbowLower = 0;
int angleElbowUpper = 0;
int angleWrist = 0;
int angleServoClawJoint = 0;
int angleServoClaw = 0;

void setup() {
  Serial.begin(9600);//begins serial comms

  servoBase.attach(servoPin);
  servoElbowLower.attach(servoPin2);
  servoElbowUpper.attach(servoPin3);
  servoWrist.attach(servoPin4);
  servoClawJoint.attach(servoPin5);
  servoClaw.attach(servoPin6);


  servoBase.write(180); //Towards 0 is clockwise, towards 180 ccw
  servoElbowLower.write(50); //0 is fully down, 50 is fully up
  servoElbowUpper.write(140); //140 is flat, 180 is fully down, anything less than 140 is up
  servoWrist.write(140); //140 is middle, 40 degrees swinging
  servoClawJoint.write(0); //0 is bottom, 180 us up
  servoClaw.write(110); //0 is close, 110 is open

}

void loop() {
  // put your main code here, to run repeatedly:

}
