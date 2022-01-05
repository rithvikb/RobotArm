Links[] links = new Links[3];
PVector base;
int backgroundColor = 51;


void setup() {
  size(600, 400);

  //// servos
  //control = ControlIO.getInstance(this);
  //cont = control.getMatchedDevice("xbs");
  //if (cont == null) {
  //println("not today chump"); // write better exit statements than me
  //System.exit(-1);
  //}
  //println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[2], 57600);
  arduino.pinMode(4, Arduino.SERVO);
  arduino.pinMode(5, Arduino.SERVO);
  arduino.pinMode(6, Arduino.SERVO);
  arduino.pinMode(7, Arduino.SERVO);
  arduino.pinMode(8, Arduino.SERVO);
  arduino.pinMode(9, Arduino.SERVO);

  upperAngle = 180;
  links[0] = new Links(300, 200, 50, 0);

  for (int i = 1; i < links.length; i++) {
    links[i] = new Links(links[i - 1], 50, i);
  }
  base = new PVector(width / 2, height);
}

void draw() {
  background(backgroundColor);

  // draw lines
  int total = links.length;
  Links end = links[links.length - 1];

  end.follow(mouseX, mouseY);
  end.update();

  for (int i = total - 2; i >= 0; i--) {
    links[i].update();
    links[i].follow(links[i + 1]);
  }

  links[0].set_a(base);

  for (int i = 1; i < total; i++) {
    links[i].set_a(links[i - 1].b);
  }

  for (int i = 0; i < total; i++) {
    links[i].show();
  }

  // find angles
  links[0].theta = degrees(atan2((links[0].b.x - links[0].a.x), (links[0].b.y - links[0].a.y)));

  float humerus = (sq(links[0].b.x - links[0].a.x) + sq(links[0].b.y - links[0].a.y));
  float ulna = (sq(links[1].b.x - links[1].a.x) + sq(links[1].b.y - links[1].a.y));
  float hToU = (sq(links[1].b.x - links[0].a.x) + sq(links[1].b.y - links[0].a.y));
  links[1].theta = 180 - degrees(-acos((hToU - humerus - ulna) / (2 * sqrt(humerus) * sqrt(ulna))));

  float humerus2 = (sq(links[1].b.x - links[1].a.x) + sq(links[1].b.y - links[1].a.y));
  float ulna2 = (sq(links[2].b.x - links[2].a.x) + sq(links[2].b.y - links[2].a.y));
  float hToU2 = (sq(links[2].b.x - links[1].a.x) + sq(links[2].b.y - links[1].a.y));
  links[2].theta = 180 - degrees(-acos((hToU2 - humerus2 - ulna2) / (2 * sqrt(humerus2) * sqrt(ulna2))));

  // write angles to servos
  arduino.servoWrite(5, (int) links[0].theta);
  arduino.servoWrite(6, (int) (90 -   links[1].theta));
  arduino.servoWrite(7, (int) links[2].theta + 90);
}

void mouseClicked() {
  if (backgroundColor == 51) {
  }
}
