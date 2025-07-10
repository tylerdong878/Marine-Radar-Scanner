#include <Servo.h>. 

const int trigPin = 11;
const int echoPin = 10;

long duration;
int distance;
Servo myServo;

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  Serial.begin(9600);
  myServo.attach(12);
}

void loop() {
  for(int i = 0; i <= 180; i++){  
  myServo.write(i);
  delay(30);
  distance = calculateDistance();
  Serial.print(String(i) + "," + String(distance) + ".");
  }

  for(int i = 180; i > 0; i--){  
  myServo.write(i);
  delay(30);
  distance = calculateDistance();
  Serial.print(String(i) + "," + String(distance) + ".");
  }
}

// Calculates the distance measured by the Ultrasonic sensor
int calculateDistance(){ 
  digitalWrite(trigPin, LOW); 
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH); 
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);
  distance= duration*0.034/2;
  return distance;
}