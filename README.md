# Marine Radar Scanner

A real-time radar scanning system that visualizes object detection using an ultrasonic sensor and servo motor, with a Processing-based visualization interface.

## Features

- 180° radar scanning with ultrasonic distance measurement
- Real-time visualization of detected objects
- Adjustable maximum detection range
- Historical scan visualization
- Clean, nautical-themed UI

## Hardware Requirements

- Arduino board
- Ultrasonic Sensor
- Servo Motor
- Jumper wires
- Breadboard

## Software Requirements

- Arduino IDE (for uploading the radar.ino sketch)
- Processing 3.0 or later (for running the visualization)
- Required Processing libraries:
  - Processing Serial library (included with Processing)

## Installation

1. Build the circuit as shown in the diagram
2. Upload `radar.ino` to your Arduino board using the Arduino IDE
3. Connect your Arduino to your computer
4. Open `drawing.pde` in Processing
5. Update the serial port in the code (line 19) to match your Arduino's port
6. Run the Processing sketch

## Usage

1. The radar will automatically start scanning when the Processing sketch runs
2. Use the slider at the bottom to adjust the maximum detection range
3. Detected objects will appear as points on the radar display
4. The display shows:
   - Current angle and distance of detected objects
   - Historical scan data (fading over time)
   - Distance scale and angle indicators

## Customization

You can modify the following parameters in the code:

- `maxDistance` in `drawing.pde` - Adjusts the default maximum detection range
- Scan speed - Modify the `delay(30)` values in `radar.ino`
- Color scheme - Update the color values in the `drawing.pde` file