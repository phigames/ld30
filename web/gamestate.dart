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
  
  List<String> quotes;
  num quoteTime;
  num blackTime;
  
  MenuState() {
    quotes = [ '"Eppur si muove." - Galileo' ,
               '"Denn nur vom Nutzen wird die Welt regiert." - Friedrich Schiller' ,
               '"They most the world enjoy who least admire." - Edward Young' ,
               '"L\'universe est une machine à faire des dieux." - Henri Bergson' ,
               '"Equilibrium is a figment of the human imagination." - Kenneth Boulding' ,
               '"Do ut des" - Some Roman guy' ,
               '"Games lubricate the body and the mind." - Benjamin Franklin' ,
               '"This game is awesome!" - A candid critic' ];
    quoteTime = 5000;
    blackTime = -1;
  }
  
  void update(num time) {
    quoteTime += time;
    if (quoteTime >= 5000) {
      fireCaption(quotes[random.nextInt(quotes.length)], '#000000', 3000);
      quoteTime -= 5000;
    }
    if (blackTime >= 0) {
      blackTime += time;
    }
    num dx = mouseX - (canvas.width / 2 + (canvas.width / 2 - mouseX) / 3);
    num dy = mouseY - (canvas.height / 3 + (canvas.height / 2 - mouseY) / 3);
    if (mouseLeftDown && dx * dx + dy * dy <= 6400) {
      blackTime = 0;
    }
    dx = mouseX - (canvas.width / 3 + (canvas.width / 2 - mouseX) / 3);
    dy = mouseY - (canvas.height / 2 + (canvas.height / 2 - mouseY) / 3);
    if (mouseLeftDown && dx * dx + dy * dy <= 900) {
      window.location.assign('http://www.ludumdare.com/');
    }
    dx = mouseX - (canvas.width * 2 / 3 + (canvas.width / 2 - mouseX) / 3);
    dy = mouseY - (canvas.height * 2 / 3 + (canvas.height / 2 - mouseY) / 3);
    if (mouseLeftDown && dx * dx + dy * dy <= 900) {
      window.location.assign('http://www.ludumdare.com/compo/author/phi/');
    }
  }
  
  void draw() {
    num x, y, dx, dy;
    // --- Play --- \\
    x = canvas.width / 2 + (canvas.width / 2 - mouseX) / 3;
    y = canvas.height / 3 + (canvas.height / 2 - mouseY) / 3;
    dx = mouseX - x;
    dy = mouseY - y;
    bufferContext.fillStyle = '#000088';
    bufferContext.beginPath();
    bufferContext.arc(x, y, 80, 0, PI * 2);
    bufferContext.fill();
    if (dx * dx + dy * dy <= 6400) {
      bufferContext.fillStyle = '#FFFFFF';
      bufferContext.font = 'bold 22px coda';
    } else {
      bufferContext.fillStyle = '#AAAAAA';
      bufferContext.font = 'bold 20px coda';
    }
    bufferContext.textAlign = 'center';
    bufferContext.fillText('Play', x, y + 8);
    // ---- LD ---- \\
    x = canvas.width / 3 + (canvas.width / 2 - mouseX) / 3;
    y = canvas.height / 2 + (canvas.height / 2 - mouseY) / 3;
    dx = mouseX - x;
    dy = mouseY - y;
    bufferContext.fillStyle = '#880000';
    bufferContext.beginPath();
    bufferContext.arc(x, y, 30, 0, PI * 2);
    bufferContext.fill();
    if (dx * dx + dy * dy <= 900) {
      bufferContext.fillStyle = '#FFFFFF';
      bufferContext.font = 'bold 22px coda';
    } else {
      bufferContext.fillStyle = '#AAAAAA';
      bufferContext.font = 'bold 20px coda';
    }
    bufferContext.textAlign = 'center';
    bufferContext.fillText('LD', x, y + 8);
    // --- phi --- \\
    x = canvas.width * 2 / 3 + (canvas.width / 2 - mouseX) / 3;
    y = canvas.height * 2 / 3 + (canvas.height / 2 - mouseY) / 3;
    dx = mouseX - x;
    dy = mouseY - y;
    bufferContext.fillStyle = '#008800';
    bufferContext.beginPath();
    bufferContext.arc(x, y, 20, 0, PI * 2);
    bufferContext.fill();
    if (dx * dx + dy * dy <= 400) {
      bufferContext.fillStyle = '#FFFFFF';
      bufferContext.font = 'bold 22px coda';
    } else {
      bufferContext.fillStyle = '#AAAAAA';
      bufferContext.font = 'bold 20px coda';
    }
    bufferContext.textAlign = 'center';
    bufferContext.fillText('phi', x, y + 8);
    if (blackTime >= 0) {
      bufferContext.fillStyle = '#000000';
      bufferContext.globalAlpha = min(blackTime / 2000, 1);
      bufferContext.fillRect(0, 0, canvas.width, canvas.height);
      bufferContext.globalAlpha = 1;
      if (blackTime >= 2000) {
        gameState = new IntroState();
      }
    }
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
    captions = [ '"All planets are created equal.' , 'But some planets are more equal than others."' , 'These planets are unequally populated.' , 'Reach the Equilibrium.' ];
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
    bufferContext.fillStyle = '#000000';
    bufferContext.fillRect(0, 0, canvas.width, canvas.height);
    num r1 = 40;
    num r2 = 100;
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