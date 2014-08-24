part of ld30;

Level level;

class Level {
  
  num updateTime;
  num screenX, screenY;
  num screenScale;
  num screenScaleTarget;
  List<Planet> planets;
  List<Highlight> highlights;
  List<BackgroundPlanet> backgroundPlanets;
  int equilibriumTime;
  num equality;
  Planet connectPlanet;
  int connectMouseX, connectMouseY;
  Planet movePlanet;
  int stage;
  bool helped;
  bool won;
  List<String> successMessages;
  String successMessage;
  
  Level() {
    updateTime = 0;
    screenScale = 10;
    screenScaleTarget = 1;
    updateScreen();
    planets = new List<Planet>();
    planets.add(new Planet(-150, 0, '#880000', 50, 0.1));
    planets.add(new Planet(150, 0, '#000088', 150, 0.15));
    highlights = new List<Highlight>();
    backgroundPlanets = new List<BackgroundPlanet>();
    for (int i = 0; i < 20; i++) {
      backgroundPlanets.add(new BackgroundPlanet());
    }
    equilibriumTime = 0;
    equality = 0;
    connectPlanet = null;
    connectMouseX = 0;
    connectMouseY = 0;
    stage = 1;
    helped = false;
    won = false;
    successMessages = [ 'You did it.' , 'Success.' , 'Congratulations.' , 'You rule.' , 'You\'re the one.' , 'Good work.' , 'I admire you.' , 'This is too easy for you.' , 'Have a cookie.' ];
    successMessage = successMessages[0];
  }
  
  void updateScreen() {
    screenScale += (screenScaleTarget - screenScale) / 10;
    screenX = (-canvas.width / 2 - (canvas.width / 2 - mouseX) / 3) / screenScale;
    screenY = (-canvas.height / 2 - (canvas.height / 2 - mouseY) / 3) / screenScale;
  }
  
  void nextStage() {
    won = false;
    num x = (random.nextDouble() - 0.5) * 700 / screenScale;
    num y = (random.nextDouble() - 0.5) * 400 / screenScale;
    String c = '#' + (random.nextInt(0x88) + 0x10).toRadixString(16) + (random.nextInt(0x88) + 0x10).toRadixString(16) + (random.nextInt(0x88) + 0x10).toRadixString(16);
    num v = random.nextDouble() * 100 + 50;
    num r = (random.nextInt(stage * 5) + 5) / 100;
    while (r > 50) {
      r -= 30;
    }
    planets.add(new Planet(x, y, c, random.nextDouble() * 100 + 50, r));
    highlights.add(new Highlight(x, y, v / 3 + 30));
    stage++;
    screenScaleTarget = 1 / stage + 0.4;
    if (stage <= 4) {
      helped = false;
    }
    successMessage = successMessages[random.nextInt(min(stage + 2, successMessages.length))];
    soundDingHigh.currentTime = 0;
    soundDingHigh.play();
  }
  
  void clearConnections() {
    for (int i = 0; i < planets.length; i++) {
      planets[i].connections.clear();
    }
  }
  
  void help() {
    if (stage == 1) {
      gameState.fireCaption('Use your left mouse button to draw or remove arrows between planets.', '#000000', 5000);
    } else if (stage == 2) {
      gameState.fireCaption('The numbers indicate how fast population is transported.', '#000000', 5000);
    } else if (stage == 3) {
      gameState.fireCaption('Use your right mouse button to move planets.', '#000000', 5000);
    } else if (stage >= 4) {
      gameState.fireCaption('If you\'re stuck, try clearing all the connections and starting from scratch.', '#000000', 5000);
    }
    helped = true;
  }
  
  void update(num time) {
    updateTime += time;
    updateScreen();
    if (connectPlanet != null) {
      if (mouseLeftDown) {
        connectMouseX = mouseX;
        connectMouseY = mouseY;
      } else {
        num mx = connectMouseX / screenScale + screenX;
        num my = connectMouseY / screenScale + screenY;
        for (int i = 0; i < planets.length; i++) {
          if (planets[i] != connectPlanet && planets[i].contains(mx, my)) {
            if (!connectPlanet.connections.contains(planets[i])) {
              connectPlanet.connections.add(planets[i]);
              soundDingLow.currentTime = 0;
              soundDingLow.play();
            } else {
              connectPlanet.connections.remove(planets[i]);
            }
            break;
          }
        }
        connectPlanet = null;
      }
    } else {
      if (mouseLeftDown) {
        num mx = mouseX / screenScale + screenX;
        num my = mouseY / screenScale + screenY;
        for (int i = 0; i < planets.length; i++) {
          if (planets[i].contains(mx, my)) {
            connectPlanet = planets[i];
            connectMouseX = mouseX;
            connectMouseY = mouseY;
            break;
          }
        }
      }
    }
    if (movePlanet != null) {
      if (mouseRightDown) {
        movePlanet.x = mouseX / screenScale + screenX;
        movePlanet.y = mouseY / screenScale + screenY;
      } else {
        movePlanet = null;
      }
    } else {
      if (mouseRightDown) {
        num mx = mouseX / screenScale + screenX;
        num my = mouseY / screenScale + screenY;
        for (int i = 0; i < planets.length; i++) {
          if (planets[i].contains(mx, my)) {
            movePlanet = planets[i];
            break;
          }
        }
      }
    }
    if (updateTime >= 50) {
      if (equilibriumTime == 0) {
        equilibriumTime = 1;
      }
      num max = planets[0].value;
      num min = planets[0].value;
      for (int i = 0; i < planets.length; i++) {
        planets[i].give();
      }
      for (int i = 0; i < planets.length; i++) {
        planets[i].take();
        if (!planets[i].equilibrium) {
          equilibriumTime = 0;
        }
        if (planets[i].value > max) {
          max = planets[i].value;
        } else if (planets[i].value < min) {
          min = planets[i].value;
        }
      }
      if (equilibriumTime > 0) {
        equilibriumTime++;
      }
      equality = max - min;
      if (equilibriumTime > 10 && equality < 50) {
        won = true;
        for (int i = 0; i < planets.length; i++) {
          if (planets[i].connections.length == 0) {
            equilibriumTime = 0;
            won = false;
          }
        }
      }
      updateTime -= 50;
    }
    for (int i = 0; i < highlights.length; i++) {
      highlights[i].update(time);
      if (highlights[i].done) {
        highlights.removeAt(i);
        i--;
      }
    }
    for (int i = 0; i < backgroundPlanets.length; i++) {
      backgroundPlanets[i].update(time);
    }
    if (won && mouseLeftDown) {
      nextStage();
    }
    if (!helped) {
      help();
    }
  }
  
  void draw() {
    for (int i = 0; i < backgroundPlanets.length; i++) {
      backgroundPlanets[i].draw();
    }
    for (int i = 0; i < planets.length; i++) {
      planets[i].drawConnections();
    }
    if (connectPlanet != null) {
      connectPlanet.drawArrow(connectMouseX / screenScale + screenX, connectMouseY / screenScale + screenY, 0);
    }
    for (int i = 0; i < planets.length; i++) {
      planets[i].draw();
    }
    for (int i = 0; i < highlights.length; i++) {
      highlights[i].draw();
    }
    // --- stage --- \\
    bufferContext.fillStyle = '#000000';
    bufferContext.font = '50px coda';
    bufferContext.textAlign = 'left';
    bufferContext.fillText('Stage ' + stage.toString(), 20, 60);
    // --- equality --- \\
    bufferContext.beginPath();
    bufferContext.rect(canvas.width - 70, 20, 50, canvas.height - 40);
    bufferContext.fillStyle = '#DDDDDD';
    bufferContext.strokeStyle = '#444444';
    bufferContext.lineWidth = 4;
    bufferContext.lineJoin = 'round';
    bufferContext.fill();
    bufferContext.stroke();
    bufferContext.beginPath();
    num h = (-equality / 200 + 1) * (canvas.height - 44);
    if (h < 0) {
      h = 0;
    }
    bufferContext.rect(canvas.width - 68, canvas.height - 22 - h, 46, h);
    bufferContext.fillStyle = '#00AA00';
    bufferContext.strokeStyle = '#444444';
    bufferContext.lineWidth = 4;
    bufferContext.lineJoin = 'round';
    bufferContext.fill();
    // --- threshold --- \\
    bufferContext.beginPath();
    num l = 22 + (canvas.height - 44) / 4;
    bufferContext.moveTo(canvas.width - 80, l);
    bufferContext.lineTo(canvas.width - 10, l);
    bufferContext.strokeStyle = '#888888';
    bufferContext.lineWidth = 4;
    bufferContext.stroke();
    if (won) {
      num mx = mouseX - canvas.width / 2;
      num my = mouseY - canvas.height / 2;
      bufferContext.fillStyle = '#AAAAAA';
      bufferContext.globalAlpha = 0.5;
      bufferContext.font = 'bold 55px coda';
      bufferContext.textAlign = 'center';
      bufferContext.fillText(successMessage, canvas.width / 2 + mx / 100, canvas.height / 3 + my / 100 + 3, 410);
      bufferContext.fillStyle = '#000000';
      bufferContext.globalAlpha = 1;
      bufferContext.font = 'bold 50px coda';
      bufferContext.fillText(successMessage, canvas.width / 2 - mx / 100, canvas.height / 3 - my / 100, 400);
      bufferContext.fillStyle = '#000000';
      bufferContext.globalAlpha = 1;
      bufferContext.font = '20px coda';
      bufferContext.fillText('Click to continue.', canvas.width / 2, canvas.height / 3 + 30);
    }
  }
  
}

class Planet {
  
  num x, y;
  num radius;
  String color;
  num value;
  num rate;
  num giving;
  num taking;
  bool equilibrium;
  List<Planet> connections;
  
  Planet(this.x, this.y, this.color, this.value, this.rate) {
    updateRadius();
    taking = 0;
    giving = 0;
    equilibrium = false;
    connections = new List<Planet>();
  }
  
  bool contains(num pointX, num pointY) {
    num dx = pointX - x;
    num dy = pointY - y;
    return dx * dx + dy * dy <= radius * radius;
  }
  
  void updateRadius() {
    radius = value / 3 + 30;
  }
  
  void give() {
    num g = value * rate;
    if (g * connections.length > value) {
      g = value / connections.length;
    }
    for (int i = 0; i < connections.length; i++) {
      connections[i].taking += g;
      value -= g;
    }
    giving = g * connections.length;
  }
  
  void take() {
    value += taking;
    updateRadius();
    equilibrium = (giving * 5).round() == (taking * 5).round();
    taking = 0;
  }
  
  void drawConnections() {
    num xx = (x - level.screenX) * level.screenScale;
    num yy = (y - level.screenY) * level.screenScale;
    for (int i = 0; i < connections.length; i++) {
      if (connections[i].connections.contains(this)) {
        drawArrow(connections[i].x, connections[i].y, 1);
      } else {
        drawArrow(connections[i].x, connections[i].y, 0);
      }
    }
  }
  
  void drawArrow(num headX, num headY, num offset) {
    num b = rate * 30 + 2;
    num xx = (x - level.screenX) * level.screenScale;
    num yy = (y - level.screenY) * level.screenScale;
    num hx = (headX - level.screenX) * level.screenScale;
    num hy = (headY - level.screenY) * level.screenScale;
    num m = -1 / ((hy - yy) / (hx - xx));
    num h = sqrt(b * b / (m * m + 1));
    num v = h * m;
    if (h == 0) {
      v = b;
    }
    if (hy - yy > 0) {
      bufferContext.beginPath();
      bufferContext.moveTo(xx - h + h * offset, yy - v + v * offset);
      bufferContext.lineTo(hx, hy);
      bufferContext.lineTo(xx + h + h * offset, yy + v + v * offset);
      bufferContext.fillStyle = color;
      bufferContext.fill();
    } else {
      if (hy - yy == 0 && hx - xx < 0) {
        bufferContext.beginPath();
        bufferContext.moveTo(xx - h + h * offset, yy - v + v * offset);
        bufferContext.lineTo(hx, hy);
        bufferContext.lineTo(xx + h + h * offset, yy + v + v * offset);
        bufferContext.fillStyle = color;
        bufferContext.fill();
      } else {
        bufferContext.beginPath();
        bufferContext.moveTo(xx - h + h * -offset, yy - v + v * -offset);
        bufferContext.lineTo(hx, hy);
        bufferContext.lineTo(xx + h + h * -offset, yy + v + v * -offset);
        bufferContext.fillStyle = color;
        bufferContext.fill();
      }
    }
  }
  
  void draw() {
    num xx = (x - level.screenX) * level.screenScale;
    num yy = (y - level.screenY) * level.screenScale;
    bufferContext.beginPath();
    bufferContext.arc(xx, yy, radius * level.screenScale, 0, 2 * PI);
    bufferContext.fillStyle = color;
    bufferContext.fill();
    if (contains(mouseX / level.screenScale + level.screenX, mouseY / level.screenScale + level.screenY)) {
      bufferContext.fillStyle = '#FFFFFF';
      bufferContext.font = 'bold 22px coda';
    } else {
      bufferContext.fillStyle = '#AAAAAA';
      bufferContext.font = 'bold 20px coda';
    }
    bufferContext.textAlign = 'center';
    bufferContext.fillText((rate * 100).round().toString(), xx, yy + 8);
  }
  
}

class Highlight {
  
  num x, y;
  num radius;
  num alpha;
  bool done;
  
  Highlight(this.x, this.y, [this.radius = 0]) {
    alpha = 1;
    done = false;
  }
  
  void update(num time) {
    radius += time / 5;
    alpha -= time / 1000;
    if (alpha <= 0) {
      alpha = 0;
      done = true;
    }
  }
  
  void draw() {
    bufferContext.beginPath();
    bufferContext.arc((x - level.screenX) * level.screenScale, (y - level.screenY) * level.screenScale, radius * level.screenScale, 0, PI * 2);
    bufferContext.strokeStyle = '#888888';
    //bufferContext.globalCompositeOperation = 'lighter';
    bufferContext.globalAlpha = alpha;
    bufferContext.lineWidth = 5;
    bufferContext.stroke();
    bufferContext.globalCompositeOperation = 'source-over';
    bufferContext.globalAlpha = 1;
  }
  
}

class BackgroundPlanet {
  
  num x, y;
  num radius;
  String color;
  num speedX, speedY;
  
  BackgroundPlanet() {
    x = (random.nextDouble() * 2 - 1) * canvas.width;
    y = (random.nextDouble() * 2 - 1) * canvas.height;
    radius = random.nextDouble() * 30 + 20;
    color = '#' + (random.nextInt(0x44) + 0xBB).toRadixString(16) + (random.nextInt(0x44) + 0xBB).toRadixString(16) + (random.nextInt(0x44) + 0xBB).toRadixString(16);
    speedX = (random.nextDouble() - 0.5) / 70;
    speedY = (random.nextDouble() - 0.5) / 70;
  }
  
  void update(num time) {
    if (x < -canvas.width) {
      speedX = speedX.abs();
    } else if (x > canvas.width) {
      speedX = -speedX.abs();
    }
    if (y < -canvas.height) {
      speedY = speedY.abs();
    } else if (y > canvas.height) {
      speedY = -speedY.abs();
    }
    x += speedX * time;
    y += speedY * time;
  }
  
  void draw() {
    num xx = (x - level.screenX - (canvas.width / 2 - mouseX) / 4) * level.screenScale;
    num yy = (y - level.screenY - (canvas.height / 2 - mouseY) / 4) * level.screenScale;
    bufferContext.beginPath();
    bufferContext.arc(xx, yy, radius * level.screenScale, 0, 2 * PI);
    bufferContext.fillStyle = color;
    bufferContext.fill();
  }
  
}