// pins
#define FRONT_LED 3
#define BACK_LED 5
#define ON_SWITCH 13   // purple
#define MODE_SWITCH 2  // green
#define BRAKE_SWITCH 9 // orange

// low value for testing
#define LOW_AMPL_FRONT 32
#define HIGH_AMPL_FRONT 1023
#define LOW_AMPL_BACK 128
#define HIGH_AMPL_BACK 1023
// time in milliseconds to hold the switch for making it permanent
#define SWITCH_HOLD 300
// minimum time in milliseconds between two consecutive events, to avoid noise
#define MIN_DELAY 10
// time spent off after which the amplitude comes back to low when turning on
#define OFF_HOLD 500
// test; can be removed
#define MAX_AMPL 511

class Sound {
  private:
    int pin_;
    double frequency_;
  public:
    Sound(double frequency): pin_(DAC0), frequency_(frequency) {
      pinMode(pin_, OUTPUT);
    };
    void update() {
      unsigned long time = micros();
      double time_s = (double)time * (double)1e-6;
      double amplitude = cos(2*3.1415927*time_s*frequency_);
      int discrete_amplitude = round(MAX_AMPL*0.5*(amplitude + 1));
      analogWrite(pin_, discrete_amplitude);
    };
};


// light levels:
// 0: off, 1: low power, 2: high power
int light_level = 0;
bool mode_pressed = false;  // whether the mode button was pressed recently
bool mode_held = false;  // whether the mode button has been held pressed long enough
bool high_ampl = false;  // keeps low vs high amplitude mode in memory even if lights are briefly switched off
bool brake_on = false;  // brake lights applied
bool brake_pressed = false; // brake button detected pressed
unsigned long time_switch = 0;
unsigned long last_switch_event = 0;
unsigned long time_off = 0;
unsigned long last_brake_event = 0;

void setup() {
  analogWriteResolution(10);
  pinMode(FRONT_LED, OUTPUT);
  analogWrite(FRONT_LED, 0);
  pinMode(BACK_LED, OUTPUT);
  analogWrite(BACK_LED, 0);
  pinMode(ON_SWITCH, INPUT_PULLUP);
  pinMode(MODE_SWITCH, INPUT_PULLUP);
  pinMode(BRAKE_SWITCH, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(ON_SWITCH), check_lights, CHANGE);
  attachInterrupt(digitalPinToInterrupt(MODE_SWITCH), check_lights, CHANGE);
  attachInterrupt(digitalPinToInterrupt(BRAKE_SWITCH), check_lights, CHANGE);
  Serial.begin(9600);
}

void loop() {
  check_lights();
  delay(10);
}

void check_lights() {
  int on_switch = !digitalRead(ON_SWITCH);
  int mode_switch = digitalRead(MODE_SWITCH) && on_switch;
  int brake_switch = !digitalRead(BRAKE_SWITCH);

  unsigned long current_time = millis();
  unsigned long elapsed_switch = current_time - last_switch_event;

  // check if we should turn off the lights
  if (light_level > 0 && !on_switch) {
    light_level = 0;
    set_lights(light_level);
    time_off = current_time;
  }

  // check if we should turn on the lights
  if (light_level == 0 && on_switch) {
    // keep the level in memory only for short durations; otherwise restart at low amplitude
    if (current_time - time_off > OFF_HOLD) {
       high_ampl = false;
    }
    if (high_ampl) {
      light_level = 2;
    } else {
      light_level = 1;
    }
    set_lights(light_level);
  }

  // check for change of mode

  if (mode_switch) {
    if (!mode_pressed) {
      // the button wasn't pressed before
      mode_pressed = true;
      last_switch_event = current_time;
    } else if (elapsed_switch >= MIN_DELAY && !mode_held) {
      // the switch has been pressed for long enough, switch mode
      time_switch = current_time;  // mark when the switch is detected, so we can check later how long it was held
      mode_held = true;
      high_ampl = !high_ampl;
      if (high_ampl) {
        light_level = 2;
      } else {
        light_level = 1;
      }
      set_lights(light_level);
    }
  } else {
    // mode button not pressed
    // if we're on 2 and the button wasn't held long enough, put back the lights on 1
    unsigned long held_time = current_time - time_switch;
    if (held_time < SWITCH_HOLD && light_level == 2) {
      light_level = 1;
      high_ampl = false;
      set_lights(light_level);
    }
    // reset timer (we want it to be held continuously to register)
    mode_pressed = false;
    mode_held = false;
    last_switch_event = current_time;
  }

  // check if we need to update the brake lights, with timing to avoid problems during switching
  if (brake_switch && !brake_on) {
    if(current_time - last_brake_event >= MIN_DELAY) {
      brake_on = true;
      analogWrite(BACK_LED, HIGH_AMPL_BACK);
    } else if (!brake_pressed) {
      // start timer to see if it will be held for long enough
      brake_pressed = true;
      last_brake_event = current_time;
    }
  }
  if (!brake_switch) {
    if (brake_on) {
      // turn off the brake lights
      brake_on = false;
      analogWrite(BACK_LED, LOW_AMPL_BACK);
    }
    // in any case, reset timer
    brake_pressed = false;
    last_brake_event = current_time;
  }
}


void set_lights(int level) {
  switch (level) {
    case 0:
      analogWrite(FRONT_LED, 0);
      analogWrite(BACK_LED, 0);
      if (brake) {
        analogWrite(BACK_LED, HIGH_AMPL_BACK);
      } else {
        analogWrite(BACK_LED, 0);
      }
      break;
    case 1:
      analogWrite(FRONT_LED, LOW_AMPL_FRONT);
      analogWrite(BACK_LED, LOW_AMPL_BACK);
      // back LED power depends on brake, not general luminosity level
      if (brake) {
        analogWrite(BACK_LED, HIGH_AMPL_BACK);
      } else {
        analogWrite(BACK_LED, LOW_AMPL_BACK);
      }
      break;
     case 2:
      analogWrite(FRONT_LED, HIGH_AMPL_FRONT);
      // back LED power depends on brake, not general luminosity level
      if (brake) {
        analogWrite(BACK_LED, HIGH_AMPL_BACK);
      } else {
        analogWrite(BACK_LED, LOW_AMPL_BACK);
      }
      break;
  }
}
