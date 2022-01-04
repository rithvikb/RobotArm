import processing.serial.*;
import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;
import cc.arduino.*;
import org.firmata.*;

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

public static void wait(int ms)
{
    try
    {
        Thread.sleep(ms);
    }
    catch(InterruptedException ex)
    {
        Thread.currentThread().interrupt();
    }
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
 println(upperAngle);
 arduino.servoWrite(9, (int)leftX);
 arduino.servoWrite(8, (int)leftY);
 arduino.servoWrite(6, (int)rightX);
 arduino.servoWrite(5, (int)rightY);
 if(lbPressed) {
   arduino.servoWrite(4, 90);
 } else if(rbPressed) {
   arduino.servoWrite(4, 0);
 }
 if(yPressed) {
   if(upperAngle > 89) {
     upperAngle -= 1;
     wait(10);
   }
 } else if(aPressed) {
   if(upperAngle < 176) {
     upperAngle += 1;
     wait(10);
   }
 }
 arduino.servoWrite(7, upperAngle);
}
