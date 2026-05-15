// Alot of thanks goes to GLV for sharing his knowledge 


import processing.serial.*;
Serial fd;

PGraphics ahi; // Artifical Horision Indicator
PGraphics ac;  // Aircraft
PGraphics gi;  // Globe Artifical horizion indicator
PGraphics dc;  // Dial Compass
PGraphics db;  // Directional Block
PGraphics lc;  // Directional Block

PImage fade;
PImage compassglass;
PImage earth;

PShape acft;
PShape globe;

float SpanAngle=120;
float yawOffset = 0.0f;
float rxo = 180;
float ryo = 180;
float rxc = 360/2;
float ryc = 360/2;

int pitch = 0;
int roll = 0;
int yaw = 0;
int yawDeg = 0;
int rollDeg = 0;
int pitchDeg = 0;
int degree = 0;
int NumberOfScaleMajorDivisions;
int NumberOfScaleMinorDivisions;
int a;

void setup()
{
  size(1120, 750, P3D);

  fd = new Serial(this, Serial.list()[1], 115200);
  fd.bufferUntil('\n');
  
  ahi = createGraphics(360, 360); // Artifical Horision Indicator
  ac = createGraphics(360, 360, P3D); // Aircraft
  gi = createGraphics(360, 360, P3D); // Globe Artifical horizion indicator
  dc = createGraphics(360, 360, P3D); // Dial Compass
  db = createGraphics(360, 360, P3D); // Directional Block
  lc = createGraphics(360, 360); // Directional Block

  acft = loadShape("model.obj");
  fade = loadImage("fade2.png");
  compassglass = loadImage("compassglass.png");
  earth = loadImage( "horz.jpg");

  globe = createShape(SPHERE, 200);
  globe.setStroke(false);
  globe.setTexture(earth);
  noStroke();
}
void draw()
{

  //background(0);

  ahi.beginDraw(); // Artifical Horision Indicator
  smooth();
  myAHI();
  ahi.endDraw();
  image(ahi, 10, 10);

  ac.beginDraw(); // Aircraft
  smooth();
  myac();
  ac.endDraw();
  image(ac, 380, 10);

  gi.beginDraw(); // Globe Artifical horizion indicator
  smooth();
  mygi();
  gi.endDraw();
  image(gi, 750, 10);

  dc.beginDraw(); // Dial Compass
  smooth();
  mydc();
  dc.endDraw();
  image(dc, 10, 380);

  db.beginDraw(); // Directional Block
  smooth();
  mydb();
  db.endDraw();
  image(db, 380, 380);

  lc.beginDraw(); // Directional Block
  smooth();
  mylc();
  image(lc, 750, 380);
  lc.endDraw();


  //a = (int) map((mouseY%360), 0, height, 0, 360);
  a = (int) map((pitch%360), 0, height, 0, 360); // For MPU
  //pitch = (int)(a%360);
  
  pitchDeg=(int)(a%360);
 
  //roll = ((int) map((mouseX%360), 0, 360, 0, 360));
  roll = ((int) map((roll%360), 0, 360, 0, 360)); // For MPU
  rollDeg = (int)(roll%360);
  
  //yaw = (int)map((mouseY%360), 0, 360, 0, 360);
  yaw = (int)map((yaw%360), 0, 360, 0, 360); // For MPU
  yawDeg = (int)(yaw%360);
  
  
 
  
}

//**************************************
// Arificial Horizion Indicator
//**************************************
void myAHI()
{

  ahi.background(0);
  ahi.stroke(255);
  ahi.noFill();
  ahi.rect(30, 30, 300, 300);

  int ps = 45; // try other values!
  int mx = ((a%360) + 360 + ps) % 360;   // 0..359, safe for larger angles
  int t = mx%180; // 360/2 = 180 the halfway mark that rolls over
  float split = t*4;
  ahi.pushMatrix(); //0 start  // The push() pop() pair not needed in this example. No harm leaving.

  float rxo = 180;
  float ryo = 180;

  float rxc = 360/2;  // See below for rect() dimensions and origin.
  float ryc = 360/2;  // ...

  ahi.translate(rxc, ryc);
  ahi.rotate(radians(roll%360));
  ahi.translate(-rxc, -ryc);

  // Simplified shape (no colour)
  ahi.noStroke();
  ahi.fill(0, 180, 255); //SKY
  ahi.rect(rxo-rxo, ryo-ryo, 360, 360);

  ahi.fill(95, 55, 40); //GROUND
  ahi.rect (rxo-rxo, ryo-ryo + 360-split, 360, 360);
  ahi.stroke(255);
  ahi.strokeWeight(2);
  ahi.line(rxo-ryo, (height/2-15) - split, 360+rxo, (height/2-15) - split);
  
  ahi.translate(rxc, ryc);

  PitchScale(ahi);
  Axis(ahi);
  ahi.translate(-rxc, -ryc);

  ahi.popMatrix(); //0 end

  ahi.push();
  ahi.translate(180, 180); // Places pitch scale center
  ahi.rotate(-PI-PI/6); // Centers upper scale

  SpanAngle=120;
  NumberOfScaleMajorDivisions=12;
  NumberOfScaleMinorDivisions=24;

  CircularScale(ahi);//Draws upper scale
  ahi.rotate(PI+PI/6); // Centers lower scale
  ahi.rotate(-PI/6);   //
  CircularScale(ahi); //Draws lower scale
  ahi.translate(-180, -180);
  ahi.pop();
 
  ahi.stroke(0);
  ahi.strokeWeight(70);
  ahi.noFill();
  ahi.rect(10, 10, 340, 340, 75 ); // Draw the outside frame
  ahi.rect(0, 0, 360, 360 );
};
//**********************************************
// Aircraft
void myac()
{
  ac.background(80, 80, 80);
 
  ac.pushMatrix();
  
  ac.translate(rxc, ryc, -100); // center
  ac.lights();
  ac.scale(60.0);
  ac.rotateZ(radians((roll%360)-10));
  ac.rotateX(radians((a%360)*2)-135);

  ac.shape(acft);
  
  ac.popMatrix();

  ac.stroke(255);
  ac.strokeWeight(1);
  ac.line(175, 180, 185, 180); // Draw cross hairs for visual reference horizontal
  ac.line(180, 175, 180, 185);
  ac.line(180, 50, 180, 150);  // vertical line
  ac.line(180, 210, 180, 310);
  ac.line(50, 180, 150, 180);  // horizontal line
  ac.line(210, 180, 310, 180);
  ac.noFill();
  ac.ellipse(180, 180, 35, 35); // center
  ac.stroke(0);
  ac.strokeWeight(70);
  ac.rect(10, 10, 340, 340, 75 );
  ac.rect(0, 0, 360, 360 );
}

//****************************************************
// Globe Artificial horizion indicator
//****************************************************
void mygi()
{

  gi.background(0);
  gi.translate(rxc, ryc, -200); // Places pitch scale center
  gi.pushMatrix();

  gi.rotateX(radians((a%360)*2));
  gi.rotateZ(radians(roll%360));

  gi.shape(globe);

  gi.popMatrix();

  gi.translate(0, 0, 200); // places pitch scaale and axis infront of globe

  gi.push();
  gi.rotateZ(radians(roll%360));
    
  PitchScale(gi);
  Axis(gi);
  gi.pop();

  gi.rotate(-PI-PI/6); // Centers upper scale
    
  SpanAngle=120;
  NumberOfScaleMajorDivisions=12;
  NumberOfScaleMinorDivisions=24;

  CircularScale(gi); //Draws upper scale
  gi.rotate(PI+PI/6); // Centers lower scale
  gi.rotate(-PI/6);   //
  CircularScale(gi); //Draws lower scale
  gi.rotate(PI/6);    // Aligns pitch scale and axis
  
}

//***************************************************
// Dial Compass
//***************************************************

void mydc()
{
  dc.background(0);

  if ((int)yaw >= 1 && (int)yaw <= 180) // keeps degrees positive
    yawDeg = (int)yaw;
  else yawDeg = 360 + (int)yaw;
  
  dc.pushMatrix();
  dc.noStroke();
  dc.fill(108, 108, 108); // Fill sky color
  dc.ellipse(180, 180, 245, 245);

  // DRAW DEGREES INSIDE COMPASS
  dc.noFill();
  dc.stroke(255); //Black
  dc.rect(155, 222, 50, 30);
  dc.fill(0); //Black
  dc.rect(155, 222, 50, 30);
  dc.textSize(20);
  dc.fill(255, 255, 255);
  dc.textAlign(CENTER);
  dc.text(yawDeg%360, 180, 245);

  dc.translate(180, 180);

  CompassPointer(dc);

  dc.popMatrix();
  dc.pushMatrix();

  /* Draws the circular scale on compass */
  dc.translate(180, 180);
  dc.stroke(50);
  dc.strokeWeight(1);
  dc.noFill();
  dc.ellipse(0, 0, 245, 245);
  dc.ellipse(0, 0, 299, 299);
  SpanAngle=180;
  NumberOfScaleMajorDivisions=18;
  NumberOfScaleMinorDivisions=36;

  CircularScale(dc);

  dc.rotate(PI);
  SpanAngle=180;

  CircularScale(dc);
  dc.rotate(-PI);

  dc.translate(-300, 100);
  dc.textSize(20);
  dc.fill(255, 255, 255);
  dc.textAlign(CENTER);
  dc.text("W", 165, -92);
  dc.text("E", 432, -92);
  dc.text("N", 300, -230);
  dc.text("S", 300, 42);
  dc.rotate(PI/4);
  dc.textSize(15);
  dc.text("NW", 4, -278);
  dc.text("SE", 275, -280);
  dc.popMatrix();
  dc.rotate(-PI/4);
  dc.text("NE", 135, 258);
  dc.text("SW", -135, 258);
  dc.image(compassglass, -175, 80);
}

//***************************************************
// Directional Block
//***************************************************
void mydb()
{
  db.background(0);

  if ((int)pitch >= 1 && (int)pitch <= 180) // keeps degrees positive
    pitchDeg = (int)pitch;
  else pitchDeg = 360 + (int)pitch;
  
  if ((int)roll >= 1 && (int)roll <= 180) // keeps degrees positive
    rollDeg = (int)roll;
  else rollDeg = 360 + (int)roll;
  
 // db.pushMatrix();
  db.fill(255);
  db.textSize(16);
  db.textAlign(LEFT);
  db.text("Yaw...: " + ((int) (yawDeg%360)), 15, 25);
  db.text("Pitch.: " + ((int) (pitchDeg%360)), 15, 50);
  db.text("Roll..: " + ((int) (rollDeg%360)), 15, 75);
 // db.popMatrix();

  db.pushMatrix();

  db.translate(180, 180, 0);
  db.scale(.8);
  db.rotateY(-radians(yaw - yawOffset));
  db.rotateX(radians(a%360)*2);
  db.rotateZ(radians(roll%360));

//gi.rotateX(radians((a%360)*2));
 // gi.rotateZ(radians(roll%360));

  buildBoxShape(db);

  db.popMatrix();
}

/**********************************************************/
/* DRAW LINEAR COMPASS WITH FADE
/**********************************************************/
void mylc()
{

  lc.background(0);

  // black rect (the whole compass)
  lc.noFill();
  lc.stroke(0); //Black
  lc.rect(30, 160, 299, 49);

  // white upper par of rectangle (the display)
  lc.fill(255, 255, 255);
  lc.rect(30, 160, 299, 24);

  // yellow lower  part of rectangle (the display)
  lc.fill(255, 255, 2);
  lc.rect(30, 184, 299, 24);

  // yellow triangle
  lc.stroke(0);// black
  lc.fill(255, 255, 2); // yellow
  lc.triangle(180-6, 177, 180+6, 177, 180, 183);

  if ((int)yaw >= 1 && (int)yaw <= 180) 
    yawDeg = (int)yaw;
  else yawDeg = 360 + (int)yaw;

  // DISPLAY DEGREES
  lc.stroke(0);// black
  lc.fill(0); //  black
  lc.textAlign(CENTER);
  lc.textSize(16);
  lc.text(yawDeg%360, 180, 174);

  // DRAW BLACK DEGREE MARKS
  lc.stroke(0); // black
  int lengthLine = 0;
  for (int i=0; i < 360; i+=5)
  {
    if (i%90==0) {
      lengthLine=9;
    } else if (i%45==0) {
      lengthLine=6;
    } else
    {
      lengthLine=3;
    }
    lc.line(((yaw)+i)%360, 185, ((yaw)+i)%360, 186+lengthLine);
    lc.fill(0);
  }

  lc.textSize(14);
  lc.text("S", ((yaw+1)+360)%360, 206);
  lc.text("N", ((yaw+1)+180)%360, 206);
  lc.text("E", ((yaw+1)+270)%360, 206);
  lc.text("W", ((yaw+1)+450)%360, 206);
  lc.textSize(11);
  lc.text("NW", ((yaw)+495)%360, 205);
  lc.text("NE", ((yaw)+225)%360, 205);
  lc.text("SE", ((yaw)+315)%360, 205);
  lc.text("SW", ((yaw)+405)%360, 205);

  //  draw red line in display
  lc.stroke(255, 2, 2);
  lc.line(180, 185, 180, 208);

  lc.image(fade, 30, 160); // load image
  
}
/*********************************************************/
/*  build cube                                           */
/*********************************************************/
void buildBoxShape(PGraphics p) {
  //box(60, 10, 40);
  p.pushMatrix();

  p.translate(0, 0, 0);
  p.noStroke();
  p.beginShape(QUADS);

  //Z+ (to the drawing area)
  p.fill(#00ff00);
  p.vertex(-60, -10, 100);
  p.vertex(60, -10, 100);
  p.vertex(60, 10, 100);
  p.vertex(-60, 10, 100);

  //Z-
  p.fill(#0000ff);
  p.vertex(-60, -10, -100);
  p.vertex(60, -10, -100);
  p.vertex(60, 10, -100);
  p.vertex(-60, 10, -100);

  //X-
  p.fill(#ff0000);
  p.vertex(-60, -10, -100);
  p.vertex(-60, -10, 100);
  p.vertex(-60, 10, 100);
  p.vertex(-60, 10, -100);

  //X+
  p.fill(#ffff00);
  p.vertex(60, -10, -100);
  p.vertex(60, -10, 100);
  p.vertex(60, 10, 100);
  p.vertex(60, 10, -100);

  //Y-
  p.fill(#ff00ff);
  p.vertex(-60, -10, -100);
  p.vertex(60, -10, -100);
  p.vertex(60, -10, 100);
  p.vertex(-60, -10, 100);

  //Y+
  p.fill(#00ffff);
  p.vertex(-60, 10, -100);
  p.vertex(60, 10, -100);
  p.vertex(60, 10, 100);
  p.vertex(-60, 10, 100);

  p.endShape();

  // Draw base
  p.translate(0, 0, -115);
  p.fill(#FF8400);
  p.box(30, 20, 30);
  // Draw pointer

  p.beginShape(QUAD_STRIP);
  p.vertex(-40, -10, -10);
  p.vertex(40, -10, -10);
  p.vertex(-40, 10, -10);
  p.vertex(40, 10, -10);

  p.vertex(40, -10, -10);
  p.vertex(0, -10, -50);
  p.vertex(0, 10, -50);
  p.vertex(40, 10, -10);

  p.vertex(-40, -10, -10);
  p.vertex(0, -10, -50);
  p.vertex(0, 10, -50);
  p.vertex(-40, 10, -10);
  p.endShape();
  p.beginShape(TRIANGLES);
  p.vertex(-40, -10, -10);
  p.vertex(40, -10, -10);
  p.vertex(0, -10, -50);
  p.vertex(-40, 10, -10);
  p.vertex(40, 10, -10);
  p.vertex(0, 10, -50);
  p.endShape();

  p.popMatrix();
}
//***************************************************/
//* Draw red axis lines                             */
//***************************************************/
void Axis(PGraphics p)
{
  p.stroke(255, 0, 0);
  p.strokeWeight(2);
  p.line(-45, 0, 45, 0);
  p.line(0, 90, 0, -90);
  p.fill(100, 255, 100); //GREEN
  p.stroke(0);
  p.strokeWeight(1);
  p.triangle(0, -107, -6, -90, 6, -90);
  p.triangle(0, 107, -6, 90, 6, 90);
}

//***************************************************/
/* Draw the pitch scale                            */
//***************************************************/
void PitchScale(PGraphics p)
{
  p.stroke(255);
  p.fill(255);
  p.strokeWeight(2);
  p.textSize(14);
  p.push();
  p.translate(0, 0);
  p.textAlign(CENTER, CENTER);
  for (int i=-4; i<5; i++)
  {
    if ((i==0)==false)
    {
      p.line(40, 20*i, -40, 20*i); // Draws wider lines
    }

    p.text(""+i*20, 20, 20*i -10, -150, 20); // draws left side degrees
    p.text(""+i*20, -20, 20*i -10, 150, 20); // draws right  side degrees
  }
  //textAlign(CORNER);
  p.strokeWeight(1);
  for (int i=-9; i<10; i++)
  {
    if ((i==0)==false)
    {
      p.line(20, 10*i, -20, 10*i); // Draws narrower lines
    }
  }
  p.pop();
}


//********************************************************/
//*    Draw cirular scale                                */
//* Code from Adrian Fernandez 4-19-2013                 */
//********************************************************/
void CircularScale(PGraphics p)
{
  float GaugeWidth=304;
  p.textSize(GaugeWidth/20);
  float StrokeWidth=1;
  float an;
  float DivxPhasorCloser;
  float DivxPhasorDistal;
  float DivyPhasorCloser;
  float DivyPhasorDistal;
  p.strokeWeight(2*StrokeWidth);
  p.stroke(255);
  p.noFill();


  float DivCloserPhasorLenght=GaugeWidth/2-GaugeWidth/9-StrokeWidth;
  float DivDistalPhasorLenght=GaugeWidth/2-GaugeWidth/7.5-StrokeWidth;

  for (int Division=0; Division<NumberOfScaleMinorDivisions+1; Division++)
  {
    an=SpanAngle/2+Division*SpanAngle/NumberOfScaleMinorDivisions;
    DivxPhasorCloser=DivCloserPhasorLenght*cos(radians(an));
    DivxPhasorDistal=DivDistalPhasorLenght*cos(radians(an));
    DivyPhasorCloser=DivCloserPhasorLenght*sin(radians(an));
    DivyPhasorDistal=DivDistalPhasorLenght*sin(radians(an));

    p.line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal);
  }

  DivCloserPhasorLenght=GaugeWidth/2-GaugeWidth/10-StrokeWidth;
  DivDistalPhasorLenght=GaugeWidth/2-GaugeWidth/7.4-StrokeWidth;

  for (int Division=0; Division<NumberOfScaleMajorDivisions+1; Division++)
  {
    an=SpanAngle/2+Division*SpanAngle/NumberOfScaleMajorDivisions;
    DivxPhasorCloser=DivCloserPhasorLenght*cos(radians(an));
    DivxPhasorDistal=DivDistalPhasorLenght*cos(radians(an));
    DivyPhasorCloser=DivCloserPhasorLenght*sin(radians(an));
    DivyPhasorDistal=DivDistalPhasorLenght*sin(radians(an));
    if (Division==NumberOfScaleMajorDivisions/2|Division==0|Division==NumberOfScaleMajorDivisions)
    {
      p.strokeWeight(5);
      p.stroke(255);

      p.line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal);
      p.strokeWeight(1);
      p.stroke(100, 255, 100);

      p.line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal);
    } else
    {
      p.strokeWeight(3);
      p.stroke(255);
      p.line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal);
    }
  }
}
//***************************************************/
//* Draws the compass pointer                       */
//***************************************************/
void CompassPointer(PGraphics p)
{
  p.rotate(radians(yaw));
  p.stroke(0);
  strokeWeight(1);
  p.fill(255, 255, 255);

  p.beginShape();
  p.vertex(0, -105);
  p.vertex(12, 100);
  p.vertex(0, 80);
  p.vertex(-12, 100);
  p.endShape(CLOSE);

  p.ellipse(0, 0, 9, 9);
  p.ellipse(0, 0, 3, 3);
}


//***************************************************
//*
//***************************************************
void serialEvent (Serial fd)
{
  // get the ASCII string:
  String rpstr = fd.readStringUntil('\n');
  if (rpstr != null) {
    String[] list = split(rpstr, ':');
    pitch = ((int)float(list[0]));
    roll = ((int)float(list[1]));
    yaw = ((int)float(list[2]));
  }
}
