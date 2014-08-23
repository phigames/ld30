part of ld30;

abstract class GameState {
  
  String caption;
  String captionColor;
  num captionTime;
  num captionAlpha;
  
  void fireCaption(String text, String color, num time) {
    caption = text;
    captionColor = color;
    captionTime = time;
    captionAlpha = 0;
  }
  
  void updateCaption(num time) {
    captionTime -= time;
    if (captionAlpha < 1 && captionTime > 0) {
      captionAlpha += time * 0.001;
      if (captionAlpha > 1) {
        captionAlpha = 1;
      }
    } else if (captionTime < 0) {
      captionAlpha -= time * 0.001;
      if (captionAlpha <= 0) {
        caption = null;
        captionAlpha = 0;
      }
    }
  }
  
  void drawCaption() {
    bufferContext.fillStyle = captionColor;
    bufferContext.globalAlpha = captionAlpha;
    bufferContext.font = '20px coda';
    bufferContext.textAlign = 'center';
    bufferContext.fillText(caption, canvas.width / 2, canvas.height - 30);
    bufferContext.globalAlpha = 1;
  }
  
  void tick(num time) {
    update(time);
    if (caption != null) {
      updateCaption(time);
    }
  }
  
  void render() {
    bufferContext.clearRect(0, 0, canvas.width, canvas.height);
    draw();
    if (caption != null) {
      drawCaption();
    }
    canvasContext.clearRect(0, 0, canvas.width, canvas.height);
    canvasContext.drawImage(buffer, 0, 0);
  }
  
  void update(num time);
  
  void draw();
  
  void help();
  
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
  
  void help() {
    level.help();
  }
  
}