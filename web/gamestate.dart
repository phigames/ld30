part of ld30;

abstract class GameState {
  
  void update(num time);
  
  void draw();
  
}

class PlayingState extends GameState {
  
  PlayingState() {
    level = new Level();
  }
  
  void update(num time) {
    level.update(time);
  }
  
  void draw() {
    level.draw();
  }
  
}