
public class Links {
  PVector a;
  float angle_ = 0;
  float len_;
  PVector b = new PVector();
  float index;
  float theta;
  Links parent_ = null;
  
  Links(float x, float y, float len, float i) {
    a = new PVector(x, y);
    len_ = len;
    calculateB();
    index = i;
  }
  
  Links(Links parent, float len, float i) {
    parent_ = parent;
    a = parent.b.copy();
    len_ = len;
    calculateB();
    index = i;
  }
  
  void follow(Links child) {
    float targetX = child.a.x;
    float targetY = child.a.y;
    follow(targetX, targetY);
  }
  
  void follow(float tx, float ty) {
    PVector target = new PVector(tx, ty);
    PVector dir = PVector.sub(target, a);
    angle_ = dir.heading();
    dir.setMag(len_);
    dir.mult(-1);
    a = PVector.add(target, dir);
  }
  
  void set_a(PVector pos) {
    a = pos.copy(); 
    calculateB();
  }
  
  void calculateB() {
    float dx = len_ * cos(angle_);
    float dy = len_ * sin(angle_);
    b.set(a.x + dx, a.y + dy);
  }
  
  void update() {
    calculateB();
  }
  
  void show() {
    stroke(255);
    strokeWeight(4);
    line(a.x, a.y, b.x, b.y);
  } 
}
