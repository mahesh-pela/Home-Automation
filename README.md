Home Automation App

A Flutter-based Home Automation System that allows users to control home appliances wirelessly using Bluetooth communication with an Arduino and HC-05 Bluetooth module.
The app also includes voice control capabilities with a wake word detection system powered by Picovoice Porcupine.

🚀 Features

🔗 Bluetooth Connectivity – Connects your phone to an HC-05 module for wireless communication.
💡 Device Control – Turn ON/OFF home appliances directly from the app.
🎤 Voice Commands – Control devices using voice recognition.
🗣️ Wake Word Detection – App listens for a specific wake word (e.g., “Hey Lyra”) before activating voice control using Picovoice Porcupine.
🧭 User-Friendly Interface – Simple and clean UI built with Flutter’s Material Design.

🛠️ Tech Stack

Frontend	Flutter (Dart)
Hardware	Arduino UNO 
Communication	HC-05 Bluetooth Module
Voice Detection	Picovoice Porcupine SDK
IDE	Android Studio / VS Code

🧩 System Architecture

The Flutter app connects to the HC-05 Bluetooth module.
The Arduino interprets incoming commands from Bluetooth and toggles connected appliances (e.g., lights, fans, etc.).
The app’s voice module uses Porcupine SDK to detect the wake word.
Upon wake word detection, it activates speech recognition to execute control commands (like “turn on light”, “turn off fan”).

⚙️ Setup Instructions
🧰 Prerequisites

Flutter SDK installed
Arduino IDE installed
HC-05 Bluetooth Module configured and paired with your phone
Picovoice account and API key (Sign up)

🔧 Steps to Run the Project

1. Clone the Repository

git clone https://github.com/yourusername/home_automation.git
cd home_automation

2. Install Dependencies

flutter pub get

3. Configure Picovoice

Create an account on Picovoice
  Obtain your Access Key.
  Add it to your Flutter project (usually in a .env or config file).

4. Upload Arduino Code

Open the corresponding Arduino sketch file (home_automation_arduino.ino).
Connect your Arduino board.
Upload the code through Arduino IDE.
Ensure your HC-05 module is correctly wired (RX/TX pins).

5. Pair Bluetooth Device

On your mobile phone, pair with the HC-05 module (default PIN: 1234 or 0000).

6. Run the Flutter App

flutter run

7. Connect and Control

Open the app and tap Connect Bluetooth.
Once connected, control appliances manually or use the wake word + voice commands.

🎙️ Voice Commands Example
Command	Action

“Turn on light”	Turns on the light
“Turn off fan”	Turns off the fan
“Turn off all”	Turns off all appliances
