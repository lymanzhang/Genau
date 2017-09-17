/**
 * Genau 1
 * An example of use of the Control class.
 * Note:
 * The position coordinates are expressed in motor steps: 
 * 80 steps = 1mm
 * Keys:
 * R       If not resetted press R to reset the AxiDraw, 
 *         manually move the head top-left and press R again. 
 *         This is necessary only the first time, as afterwards 
 *         the steps are queried from the controller.
 * SPACE   Toggles the pen
 * 1-9     Toggle motor speed
 * CURSORS Move the pen around
 * B       Prints echo.buffer
 */

Control c;

void setup() {
  size(400, 400);
  textFont(loadFont("f14.vlw"));

  c = new Control(this);
  Serial p = c.open();
  if (p == null) {
    println("Axidraw not found.");
    // exit();
    // return;
  } 
  c.readPos();  // Read out the steps, set interbal pos[] accordingly
  c.up(true);   // Force the pen to be "up" (we don't know the actual positon)
}

void draw() {

  // c.querySteps();
  // c.queryMotor();

  messageLoop(c.port);

  String out = "";

  out += "pos[]: " + c.pos()[0] + "," + c.pos()[1] + " (steps)\n";
  out += "time: " + millis() + "ms\n";
  out += "idle: " + (c.isIdle()) + "\n";

  if (!c.enabled()) {
    out += "\nManually move the pen\nto the top left corner... \n\nPress R again when done.";
    background(220, 60, 60);
  } else {
    background(220);
  }

  fill(0, 140);
  text(out, 30, 30);
}

void keyPressed() {

  int STEPS = 800; // 800 steps = 1cm

  if (keyCode == RIGHT) {
    c.move(STEPS, 0);
  } else if (keyCode == LEFT) {
    c.move(-STEPS, 0);
  } else if (keyCode == UP) {
    c.move(0, -STEPS);
  } else if (keyCode == DOWN) {
    c.move(0, STEPS);
  } else if ( key == 'h') {  // go home
    delay(c.up());     // wait that the pen is lifted before moving around...
    c.moveTo(0, 0);
  } else if ( key == ' ') {  // Toggles the pen position
    if (c.isDown()) {
      c.up();
    } else {
      c.down();
    }
  } else if (key == 'r') {   // manually reset the AxiDraw, press again to set "Zero"
    if (c.enabled()) {
      c.up(true);            // force the pen up
      c.off();
    } else {   
      c.on();
      c.zero();
      println("ZERO");
    }
  } 
  else if ( key == '1') c.motorSpeed( 500); // sloow 
  else if ( key == '2') c.motorSpeed(1000); // slow       
  else if ( key == '3') c.motorSpeed(1500); // default               
  else if ( key == '4') c.motorSpeed(2000); // ok for most cases       
  else if ( key == '5') c.motorSpeed(2500); // quick       
  else if ( key == '6') c.motorSpeed(3000); // quicker      
  else if ( key == '7') c.motorSpeed(3500); // pretty fast        
  else if ( key == '8') c.motorSpeed(4000); // probably the max useful speed
  else if ( key == '8') c.motorSpeed(4500); // not so precise
  else if ( key == '9') c.motorSpeed(5000); // even less precise

  else if (key == 'b') {
    String[] commands = split(c.echo.buffer.trim(), '\r');
    int n = 0;
    for (String l : commands) println("["+n+++"]", l);
  } else if (key == 'p') {
    // c.port.write(c.echo.buffer); // better not... as all commands are relative!
  } else if (key == 'c') {

    int cx = 5000;
    int cy = 5000;
    int res = 1000;
    float rad = random(2000, 3000);

    int time = 0; // or use c.resetTime()
    time += c.up();
    for (int i=0; i<res+1; i++) {   
      int x = round(cx + cos(TWO_PI / res * i) * rad);
      int y = round(cy + sin(TWO_PI / res * i) * rad);
      time += c.moveTo(x, y);
      if (i == 0) time += c.down();
    }
    time += c.up();
    println("Approx time to draw the circle: " + time); // or use c.getApproxTime()
  }
}