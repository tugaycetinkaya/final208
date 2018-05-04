PImage start;
PImage bb;
PImage moon;
PImage sunny;
PImage sky;
PShader blur;

boolean scene1 = true;
boolean scene2 = false;
boolean scene3 = false;
boolean startmouse = true;

int sy = 900;
int vs;

int howMany = 199;
int begin; 
int duration = 5;
int time = 5;
int sc;
int l = 1;

Star[] sun = new Star[howMany];

void setup() {
  size(600, 600);
  start = loadImage("oyun-01.png");
  bb = loadImage("Asset 1.png");
  moon = loadImage("Asset 5.png");
  sunny = loadImage("Asset 7.png");
  sky = loadImage("gameover.png");
  begin = millis();  
  for (int i=0; i<howMany; i++) {
    sun[i] = new Star();
  }
}

Ball[] balls =  { 
  new Ball(600, 100, 20), 
  new Ball(500, 400, 80), 
  new Ball(100, 100, 80), 
  new Ball(200, 600, 100) 
};

void draw() {
  background(0);
  if (l >= 5 && sc < 100) {
    scene1 = false;
    scene2 = false;
    scene3 = true;
  }

  if (scene3 == true) {

    image(sky, 300, 300, 600, 600);
    sy = sy - vs;
    vs = 5;
    image(sunny, 300, sy, 500, 422);
    if (sy == 300) {
      vs = 0;
      pushStyle();
      textSize(30);
      text("GAME OVER", 225, 322);
      popStyle();
    }
  }
  if (scene3 == false) {

    for (int i=0; i<howMany; i++) {
      sun[i].shine();
    }

    for (Ball b : balls) {
      b.update();
      b.display();
      b.checkBoundaryCollision();
    }

    balls[0].checkCollision(balls[1]);
    balls[1].checkCollision(balls[2]);
    balls[1].checkCollision(balls[3]);
    balls[2].checkCollision(balls[3]);
    balls[2].checkCollision(balls[0]);
    balls[3].checkCollision(balls[0]);
    if (scene1==true) {
      //rect(130,281,186,272);
      image(start, 300, 300, 600, 600);
    }
    image(moon, 60, 84, 91, 148);
    if (scene2 == true) {
      if (time > 0) {
        time = (duration) - (millis() - begin)/1000;
      }
      if (time == 0) {
        res();
      }
      pushStyle();
      fill(#FFF490);
      textSize(35);
      text("LEVEL : " + l, 400, 50);
      popStyle();
    }
    fill(0);
    text(time, 45, 121);
    text(sc, 45, 152);
  }
}

class Star {
  // They are born dark
  float x, y, bri = -1, dir, sz;

  void shine() {
    // if the star has completely faded to black
    // make it reappear somewhere else
    // (random position, random size and random brightness increase speed)
    if (bri < 0) {
      x = random(width);
      y = random(height);
      sz = 10 - 2*l;
      dir = random(1, 3);
      bri = 0;
    }
    // set the brightness and draw the star
    fill(bri);
    ellipse(x, y, sz, sz);
    // increase or decrease the brightness
    bri = bri + dir;
    // if it achieved maximum brightness
    // choose a random fade out speed
    if (bri > 255) {
      bri = 255;
      dir = random(-1, -3);
    }
    if (scene2==true) { 
      mousePressed();
      if (mouseX > x -5 && mouseX < x + 5 && mouseY > y && mouseY < y + sz) {
        sc = sc+1;
        bri= -1;
        fill(0);
        ellipse(x, y, sz, sz);
      }
    }
  }
}

void res() {
  time= 5;
  duration= 5;
  begin = millis();
  //sc = y;
  l = l + 1;

  // sz = sz - 1;
}

class Ball {
  PVector position;
  PVector velocity;

  float radius, m;

  Ball(float x, float y, float r_) {
    position = new PVector(x, y);
    velocity = PVector.random2D();
    velocity.mult(3);
    radius = r_;
    m = radius*.1;
  }



  void update() {
    position.add(velocity);
  }

  void checkBoundaryCollision() {
    if (position.x > width-radius) {
      position.x = width-radius;
      velocity.x *= -1;
    } else if (position.x < radius) {
      position.x = radius;
      velocity.x *= -1;
    } else if (position.y > height-radius) {
      position.y = height-radius;
      velocity.y *= -1;
    } else if (position.y < radius) {
      position.y = radius;
      velocity.y *= -1;
    }
  }

  void checkCollision(Ball other) {

    // Get distances between the balls components
    PVector distanceVect = PVector.sub(other.position, position);

    // Calculate magnitude of the vector separating the balls
    float distanceVectMag = distanceVect.mag();

    // Minimum distance before they are touching
    float minDistance = radius + other.radius;

    if (distanceVectMag < minDistance) {
      float distanceCorrection = (minDistance-distanceVectMag)/2.0;
      PVector d = distanceVect.copy();
      PVector correctionVector = d.normalize().mult(distanceCorrection);
      other.position.add(correctionVector);
      position.sub(correctionVector);

      // get angle of distanceVect
      float theta  = distanceVect.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball positions. You 
       just need to worry about bTemp[1] position*/
      PVector[] bTemp = {
        new PVector(), new PVector()
      };

      /* this ball's position is relative to the other
       so you can use the vector between them (bVect) as the 
       reference point in the rotation expressions.
       bTemp[0].position.x and bTemp[0].position.y will initialize
       automatically to 0.0, which is what you want
       since b[1] will rotate around b[0] */
      bTemp[1].x  = cosine * distanceVect.x + sine * distanceVect.y;
      bTemp[1].y  = cosine * distanceVect.y - sine * distanceVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
      };

      vTemp[0].x  = cosine * velocity.x + sine * velocity.y;
      vTemp[0].y  = cosine * velocity.y - sine * velocity.x;
      vTemp[1].x  = cosine * other.velocity.x + sine * other.velocity.y;
      vTemp[1].y  = cosine * other.velocity.y - sine * other.velocity.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
      };

      // final rotated velocity for b[0]
      vFinal[0].x = ((m - other.m) * vTemp[0].x + 2 * other.m * vTemp[1].x) / (m + other.m);
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((other.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + other.m);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate ball positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
      };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update balls to screen position
      other.position.x = position.x + bFinal[1].x;
      other.position.y = position.y + bFinal[1].y;

      position.add(bFinal[0]);

      // update velocities
      velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
    }
  }

  void display() {
    if (scene3 == false) {
      noStroke();
      fill(204);
      imageMode(CENTER);
      image(bb, position.x, position.y, radius*2, radius);
    }
  }
}

void mousePressed() {
  if (scene3 == true) {
    l = 1;
    sc = 0;
    time = 5;
    duration = 5;
    scene3 = false;
    scene2 = false;
    scene1 = true;
    startmouse = true;
  }
  if (mouseX > 130 && mouseX < 316 && mouseY > 281 && mouseY < 553) {
    if (scene1 == true && scene2 == false && scene3 == false && startmouse == true) {
      begin = millis();
      startmouse = false;
      scene1 = false;
      scene2 = true;
      scene3 = false;
    }
  }
}