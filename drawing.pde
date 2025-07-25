import processing.serial.*;

Serial myPort;
float distance = 0;
int angle = 0;
int previousAngle = 0;  // Track previous angle for direction
float maxDistance = 100; // Default max distance, adjustable via slider

// Slider variables
float sliderX, sliderY, sliderW, sliderH;
float sliderHandleX;
boolean sliderIsDragged = false;
ArrayList<PVector> points;
ArrayList<Float> scanHistory;
PFont font;

final int sweepWidth = 30;
ArrayList<Float> sweepAngles = new ArrayList<Float>();

void setup() {
  fullScreen();
  
  printArray(Serial.list());
  myPort = new Serial(this, "COM3", 9600);
  myPort.bufferUntil('.');
  
  points = new ArrayList<PVector>();
  scanHistory = new ArrayList<Float>();
  
  font = createFont("Courier New Bold", 12);
  textFont(font);
  
  // Initialize slider properties
  sliderW = 250;
  sliderH = 20;
  sliderX = 20;
  sliderY = height - 50;
  sliderHandleX = map(maxDistance, 0, 1000, sliderX, sliderX + sliderW);
}

// Recieves and parses data
void serialEvent(Serial myPort) {
  String data = myPort.readStringUntil('.');
  if (data != null) {
    String[] values = split(trim(data), ',');
    if (values.length == 2) {
      int newAngle = int(values[0]);
      
      // Track previous angle for direction detection
      previousAngle = angle;
      angle = newAngle;
      
      distance = float(values[1]);
       if (distance < maxDistance && distance > 0) {
        float rad = radians(360 - angle);
        float x = distance * cos(rad);
        float y = distance * sin(rad);
        points.add(new PVector(x, y, millis()));
        scanHistory.add(distance);
        if (scanHistory.size() > 100) {
          scanHistory.remove(0);
        }
      }
    }
  }
}

void draw() {
  background(5, 10, 25);
  drawSidePanels();

  pushMatrix();
  
  translate(width/2, height/2);
  float radarRadius = 320;
  
  // Draw outer glow
  for (int i = 5; i > 0; i--) {
    stroke(0, 200, 255, 10);
    strokeWeight(i * 2);
    noFill();
    ellipse(0, 0, radarRadius * 2 + i * 10, radarRadius * 2 + i * 10);
  }
  
  // Draw radar circles
  strokeWeight(1.25);
  noFill();
  for (int i = 1; i <= 5; i++) {
    float alpha = map(i, 1, 5, 80, 30);
    stroke(0, 150, 200, alpha);
    ellipse(0, 0, i * radarRadius/2.5, i * radarRadius/2.5);
  }
  
  // Draw radar lines (every 30 degrees)
  for (int i = 0; i < 360; i += 30) {
    stroke(0, 150, 200, 40);
    strokeWeight(1.25);
    float rad = radians(i);
    float x = radarRadius * cos(rad);
    float y = radarRadius * sin(rad);
    line(0, 0, x, y);
  }
  
  // Draw finer lines (every 10 degrees)
  for (int i = 0; i < 360; i += 10) {
    stroke(0, 150, 200, 20);
    strokeWeight(0.5);
    float rad = radians(i);
    float x1 = (radarRadius - 20) * cos(rad);
    float y1 = (radarRadius - 20) * sin(rad);
    float x2 = radarRadius * cos(rad);
    float y2 = radarRadius * sin(rad);
    line(x1, y1, x2, y2);
  }
  
  // Draw crosshair
  stroke(0, 200, 255, 100);
  strokeWeight(2);
  line(-radarRadius, 0, radarRadius, 0);
  line(0, -radarRadius, 0, radarRadius);
  
  // Draw angle labels
  for (int i = 0; i < 360; i += 45) {
    fill(0, 200, 255, 200);
    textAlign(CENTER, CENTER);
    textSize(15);
    float rad = radians(i);
    float x = (radarRadius + 25) * cos(rad);
    float y = (radarRadius + 25) * sin(rad);
    // Flip the angle labels
    int flippedAngle = (360 - i) % 360;
    text(flippedAngle + "°", x, y);
  }
  
  // Add the current angle to the front
  sweepAngles.add(0, float(angle));
  if (sweepAngles.size() > sweepWidth) sweepAngles.remove(sweepAngles.size() - 1);

  // Draw the afterglow lines
  for (int i = 0; i < sweepAngles.size(); i++) {
    float alpha = map(i, 0, sweepWidth - 1, 255, 0); // Newest is brightest
    float rad = radians(360 - sweepAngles.get(i));
    float x = radarRadius * cos(rad);
    float y = radarRadius * sin(rad);
    stroke(0, 255, 255, alpha);
    strokeWeight(3);
    line(0, 0, x, y);
  }
  
  // Draw main sweep line
  stroke(0, 255, 255);
  strokeWeight(3);
  float sweepRad = radians(360 - angle);
  float sweepX = radarRadius * cos(sweepRad);
  float sweepY = radarRadius * sin(sweepRad);
  line(0, 0, sweepX, sweepY);
  
  // Draw sweep glow
  stroke(0, 255, 255, 50);
  strokeWeight(8);
  line(0, 0, sweepX, sweepY);
  
  // Draw detected objects
  for (int i = points.size() - 1; i >= 0; i--) {
    PVector p = points.get(i);
    float age = millis() - p.z;
    
    if (age > 5000) {
      points.remove(i);
      continue;
    }
    
    float alpha = map(age, 0, 5000, 255, 0);
    float scaleFactor = radarRadius / maxDistance;
    float px = p.x * scaleFactor;
    float py = p.y * scaleFactor;
    
    // Object glow
    fill(255, 100, 0, alpha/4);
    noStroke();
    ellipse(px, py, 30, 30);
    
    // Object core
    fill(255, 150, 0, alpha);
    ellipse(px, py, 12, 12);
    
    // Object center
    fill(255, 255, 0, alpha);
    ellipse(px, py, 6, 6);
  }
  
  // Draw current reading
  if (distance < maxDistance && distance > 0) {
    float scaleFactor = radarRadius / maxDistance;
    float rad = radians(360 - angle);
    float x = distance * cos(rad) * scaleFactor;
    float y = distance * sin(rad) * scaleFactor;
    
    // Target indicator
    stroke(255, 255, 0, 200);
    strokeWeight(2);
    noFill();
    ellipse(x, y, 20, 20);
    line(x - 15, y, x - 5, y);
    line(x + 5, y, x + 15, y);
    line(x, y - 15, x, y - 5);
    line(x, y + 5, x, y + 15);
    
    // Distance line
    stroke(255, 255, 0, 50);
    strokeWeight(1);
    line(0, 0, x, y);
  }
  
  // Center decoration
  fill(0, 255, 255);
  noStroke();
  ellipse(0, 0, 10, 10);
  stroke(0, 255, 255, 100);
  strokeWeight(2);
  noFill();
  ellipse(0, 0, 20, 20);
  
  popMatrix();
  
  // Draw info panel
  drawInfoPanel();
  drawSlider();
}

void drawSidePanels() {
  // Left panel
  stroke(0, 170, 200, 100);
  strokeWeight(1);
  fill(0, 50, 100, 30);
  rect(10, 10, 150, 200, 5);
  
  // Decorative elements for left panel
  for (int i = 0; i < 5; i++) {
    float y = 30 + i * 35;
    stroke(0, 200, 255, 50);
    line(20, y, 150, y);
  }

  // -- Right Panel with Distance Graph --
  stroke(0, 150, 200, 100);
  strokeWeight(1);
  fill(0, 50, 100, 30);
  rect(width - 180, 10, 170, 200, 5);

  // Draw graph lines and labels
  textAlign(RIGHT, CENTER);
  textSize(10);
  fill(0, 200, 255, 150);
  for (int i = 0; i <= 4; i++) {
    float y = map(i, 0, 4, 180, 40);
    float distanceLabel = map(i, 0, 4, 0, maxDistance);
    stroke(0, 200, 255, 50);
    line(width - 150, y, width - 20, y);
    text(nf(distanceLabel, 0, 0), width - 155, y);
  }

  // Draw distance history graph
  if (scanHistory.size() > 1) {
    stroke(0, 255, 255, 150);
    strokeWeight(1.5);
    noFill();
    beginShape();
    for (int i = 0; i < scanHistory.size(); i++) {
      float x = map(i, 0, scanHistory.size() - 1, width - 150, width - 20);
      float y = map(scanHistory.get(i), 0, maxDistance, 180, 40);
      vertex(x, y);
    }
    endShape();
  }
}

void drawInfoPanel() {
  // Main info panel
  fill(0, 50, 100, 50);
  stroke(0, 200, 255, 100);
  strokeWeight(1);
  rect(width/2 - 150, height - 120, 300, 100, 5);
  
  // Info text
  fill(0, 255, 255);
  textAlign(CENTER);
  textSize(14);
  text("RADAR SYSTEM ACTIVE", width/2, height - 95);
  
  textSize(12);
  fill(0, 200, 255);
  text("Distance: " + nf(distance, 0, 1) + " cm", width/2, height - 70);
  text("Angle: " + angle + "°", width/2, height - 50);
  text("Objects: " + points.size(), width/2, height - 30);
  
  // Status indicators
  float statusY = 50;
  textAlign(LEFT);
  textSize(10);
  
  // System status
  fill(0, 255, 0);
  ellipse(20, statusY, 8, 8);
  fill(0, 200, 255);
  text("SYSTEM ONLINE", 35, statusY + 3);
  
  // Tracking status
  fill(points.size() > 0 ? color(255, 150, 0) : color(0, 100, 0));
  ellipse(20, statusY + 20, 8, 8);
  fill(0, 200, 255);
  text("TRACKING: " + (points.size() > 0 ? "ACTIVE" : "IDLE"), 35, statusY + 23);
  

}

// -- Slider Functions --
void drawSlider() {
  // Draw slider track
  stroke(0, 150, 200, 150);
  strokeWeight(2);
  fill(0, 50, 100, 100);
  rect(sliderX, sliderY, sliderW, sliderH, 5);

  // Draw slider handle
  stroke(0, 200, 255);
  strokeWeight(2);
  fill(0, 255, 255, 200);
  rect(sliderHandleX - 5, sliderY - 5, 10, sliderH + 10, 3);

  // Draw text label for max distance above the slider
  fill(0, 200, 255);
  textSize(14);
  textAlign(LEFT, CENTER);
  text("Max Distance: " + nf(maxDistance, 0, 0) + " cm", sliderX + 5, sliderY - 20);
}

void mousePressed() {
  // Check if the mouse is over the slider handle
  if (mouseX > sliderHandleX - 5 && mouseX < sliderHandleX + 5 &&
      mouseY > sliderY - 5 && mouseY < sliderY + sliderH + 5) {
    sliderIsDragged = true;
  }
}

void mouseDragged() {
  if (sliderIsDragged) {
    // Update handle position and maxDistance
    sliderHandleX = constrain(mouseX, sliderX, sliderX + sliderW);
    maxDistance = round(map(sliderHandleX, sliderX, sliderX + sliderW, 0, 1000));
  }
}

void mouseReleased() {
  sliderIsDragged = false;
}
