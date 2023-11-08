import processing.serial.*;
import processing.sound.*;
float[][] terrain;
int cols, rows;
float scl = 20;
float w = 1400;
float h = 1000;
float flying = 0;
int sprinkleIntensity_l_f = 1;
int sprinkleIntensity_l_b = 1;
boolean is_back_strong = false;
boolean is_front_strong = false;
Serial port;
boolean is_reading = false;
PImage photo;
PImage bg;
PImage startph;
int photoWidth = 600;
int photoHeight = 1000;
int sum_pressure = 0;
int combined_sprinkle = 0;
int pressure1 = 0;
int pressure2 = 0;
SoundFile sound;
boolean showNiceStep = false; // Initially, don't show the message
boolean startgame = false;
boolean gest1=false;
boolean gest2=false;
boolean gest3=false;
boolean gest4=false;
void welcomeScreen() {
  background(255);
  textSize(32);
  fill(0);
  textAlign(CENTER, CENTER);
  text("Welcome to My Sketch", width/2, height/2);
  while (!keyPressed) {} // Wait until a key is pressed
}

void setup() {
    // List available serial ports
  println(Serial.list());
  sound = new SoundFile(this, "boat_sound.mp3");

  // Initialize serial connection
    //String portname = "/dev/cu.usbserial-1130";
    String portname = "/dev/cu.HC-06";
  // Set up serial event listener
  port = new Serial(this, portname, 9600);
  fullScreen(P3D);
  cols = floor(w / scl);
  rows = floor(h / scl);

  terrain = new float[cols][rows];
  
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      terrain[x][y] = 0;
    }
  }
   photo = loadImage("boat2.png");
   bg = loadImage("wallpaper2.jpeg");
   startph = loadImage("start.jpeg");
   //image(photo,0,0);
     sound.play();

}


void draw() {
  //welcomeScreen();
    // Check if there is data available to read
  if (port.available() > 0) {
    // Read pressure values from serial port
    String data1 = port.readStringUntil('\n');
    String data2 = port.readStringUntil('\n');
    
    if (data1 != null && data2 != null) {
      // Trim whitespace and convert pressure values to integers
      data1 = trim(data1);
      data2 = trim(data2);
      String[] parts1 = split(data1, ' ');
      String[] parts2 = split(data2, ' ');
      
      if (parts1.length > 0 && parts2.length > 0) {
        pressure1 = int(parts1[0]);
        pressure2 = int(parts2[0]);
        
        println("Pressure 1: " + pressure1 + ", Pressure 2: " + pressure2);
        
        // Map pressure values to sprinkle intensity
        sprinkleIntensity_l_f = int(map(pressure1, 0, 1023, 1, 20));
        sprinkleIntensity_l_b = int(map( pressure2 , 0, 1023, 1, 20));
        //is_reading = true;
        println("Sprinkle intensity: " + sprinkleIntensity_l_f +" "+ sprinkleIntensity_l_b);
        sum_pressure = pressure1+pressure2;
        combined_sprinkle = int(map( sum_pressure, 0, 1023, 1, 20));
        println("combined sprinkle " + sum_pressure + " " + combined_sprinkle);
      }
    }
  if(startgame == true)
  {
   color terrainColor = color(0, 140, 230);
       if (sprinkleIntensity_l_f < 2 && sprinkleIntensity_l_b == 1) {
      terrainColor = color(100, 200, 100,80); // Red for low sprinkle intensity
    } else if (sprinkleIntensity_l_f < 4 && sprinkleIntensity_l_b == 1) {
      terrainColor = color(255, 255, 153,80); // Yellow for medium sprinkle intensity
    }
    else if (sprinkleIntensity_l_f < 20 && sprinkleIntensity_l_b == 1) {
      terrainColor = color(153, 255, 255,80); // Green for medium sprinkle intensity
    }
    //}
    //if (sprinkleIntensity_l_f < 2 && sprinkleIntensity_l_b == 1) {
    //  terrainColor = color(255, 100, 100,80); // Red for low sprinkle intensity
    //} else if (sprinkleIntensity_l_f < 4 && sprinkleIntensity_l_b == 1) {
    //  terrainColor = color(255, 255, 153,80); // Yellow for medium sprinkle intensity
    //}
    //else if (sprinkleIntensity_l_f < 20 && sprinkleIntensity_l_b == 1) {
    //  terrainColor = color(153, 255, 255,80); // Green for medium sprinkle intensity
    //}

    //else if (sprinkleIntensity_l_b < 2 && sprinkleIntensity_l_f == 1) {
    //  terrainColor = color(102, 102, 255,80); // Red for low sprinkle intensity
    //} else if (sprinkleIntensity_l_b < 4 && sprinkleIntensity_l_f == 1) {
    //  terrainColor = color(255, 102, 178,80); // Yellow for medium sprinkle intensity
    //}
    //else if (sprinkleIntensity_l_b < 20 && sprinkleIntensity_l_f == 1) {
    //  terrainColor = color(255, 204, 178,80); // Green for medium sprinkle intensity
    //}
    
  flying -= 0.01;
  float yoff = flying;
  
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map(noise(xoff, yoff), 0, 1, -100, 100);
      xoff += 0.2;
    }
    yoff += 0.2;
  }
  //background(0, 50,250);
    push();
  image(bg, 0, 0);  // Display the image at position (0, 0)
  pop();
  translate(100, 150);
  push();
  rotateX(PI / 3);
  fill(terrainColor); // Use determined color
  translate(h/100000, w/1000);
  for (int y = 36; y < rows - 2; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      vertex(x * scl-200, y * scl, terrain[x][y]);
      vertex(x * scl-200, (y + 1) * scl, terrain[x][y + 1]);
    }
    //is_reading = false;
    endShape();
  }

  pop();
    //translate(0, 400,-40);
  translate(-100,-100,100);
    //background(255);
  //rotateX(-2*PI);

int photoX = int(map(combined_sprinkle, 1, 20, 0, width - photoWidth+400));
int photoY = int(map(sprinkleIntensity_l_b, 1, 20, height - photoHeight-200, 0));

float angle = radians(frameCount); // Change the angle of the diagonal movement

photoX += int(sin(angle) * 40); // Move the photo diagonally using sine function
photoY += int(cos(angle) * 40); // Move the photo diagonally using cosine function
image(photo, photoX, photoY, photoWidth, photoHeight);
if (sprinkleIntensity_l_f < 20 && sprinkleIntensity_l_b == 1 && showNiceStep==true) {
       push();
       fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Nice step!", width/2, height/2);
  pop();
  showNiceStep = false;
  
}
}
else
 {   image(startph, 0, 0);  // Display the image at position (0, 0)

   text("Welcome! Please tap twice with the front part of your leg", width, height);
 println("pressure1 - "+pressure1+" ::::::    pressure 2 - "+pressure2);
 println(gest1+"-"+gest2+"-"+gest3+"-"+gest4);
        if (pressure1 > 50 && pressure2 < 20 && gest2 == true && gest3 == true) {
      println("gest4 activated");
      startgame = true;
    }
        else if (pressure1< 20 && pressure2 < 20 && gest1 == true && gest2==true) {
       gest3 = true;
      println("gest3 activated");
    }
   else if (pressure1 > 50 && pressure2 < 20 && gest1 == true) {
       gest2 = true;
       println("gest2 activated");
     }
    else if (pressure1< 20 && pressure2 < 20 && gest1 == false) {
       gest1 = true;
       println("gest1 activated");
     }
}
}
}
