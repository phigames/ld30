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

class MenuState extends GameState {
  
  void update(num time) {
    
  }
  
  void draw() {
    
  }
  
  void help() {
    
  }
  
}

class IntroState extends GameState {
  
  int part;
  num partTime;
  List<String> captions;
  
  IntroState() {
    part = 0;
    partTime = 0;
    captions = [ 'All planets are created equal.' , 'But some planets are more equal than others.' , 'These planets are unequally populated.' , 'Reach the Equilibrium.' ];
    fireCaption(captions[0], '#FFFFFF', 4000);
    musicLucta.loop = true;
    musicLucta.play();
  }
  
  void update(num time) {
    partTime += time;
    if (partTime >= 5000) {
      part++;
      partTime -= 5000;
      if (part == 4) {
        gameState = new PlayingState();
      } else {
        fireCaption(captions[part], '#FFFFFF', 4000);
      }
    }
  }
  
  void draw() {
    num r1 = 40;
    num r2 = 100;
    bufferContext.fillStyle = '#000000';
    bufferContext.fillRect(0, 0, canvas.width, canvas.height);
    if (part == 0) {
      bufferContext.globalAlpha = min(partTime / 2000, 1);
    } else if (part == 3) {
      r1 = 40 + min(partTime / 2000, 1) * 30;
      r2 = 100 - min(partTime / 2000, 1) * 30;
    }
    bufferContext.fillStyle = '#880000';
    bufferContext.beginPath();
    bufferContext.arc(canvas.width / 2 - 150, canvas.height / 2, r1, 0, PI * 2);
    bufferContext.fill();
    bufferContext.globalAlpha = 1;
    if (part >= 1) {
      if (part == 1) {
        bufferContext.globalAlpha = min(partTime / 2000, 1);
      }
      bufferContext.fillStyle = '#000088';
      bufferContext.beginPath();
      bufferContext.arc(canvas.width / 2 + 150, canvas.height / 2, r2, 0, PI * 2);
      bufferContext.fill();
      bufferContext.globalAlpha = 1;
      if (part == 3) {
        bufferContext.globalAlpha = max((partTime - 3000) / 2000, 0);
        bufferContext.fillStyle = '#FFFFFF';
        bufferContext.fillRect(0, 0, canvas.width, canvas.height);
        bufferContext.globalAlpha = 1;
      }
    }
  }
  
  void help() { }
  
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