part of ld30;

AudioElement musicFlemina;
AudioElement musicLucta;
AudioElement soundDingHigh;
AudioElement soundDingLow;

void loadAudio() {
  musicFlemina = new AudioElement('audio/flemina.wav');
  musicLucta = new AudioElement('audio/lucta.wav');
  soundDingHigh = new AudioElement('audio/ding_high.wav');
  soundDingLow = new AudioElement('audio/ding_low.wav');
}