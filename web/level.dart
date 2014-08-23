part of ld30;

Level level;

class Level {
  
  num updateTime;
  num screenX, screenY;
  num screenScale;
  List<Planet> planets;
  int equilibriumTime;
  num equality;
  Planet connectPlanet;
  int connectMouseX, connectMouseY;
  Planet movePlanet;
  int stage;
  bool won;
  
  Level() {
    updateTime = 0;
    screenScale = 1;
    updateScreen();
    equilibriumTime = 0;
    equality = 0;
    planets = new List<Planet>();
    planets.add(new Planet(-150, 0, '#880000', 100, 0.1));
    planets.add(new Planet(150, 0, '#000088', 100, 0.15));
    connectPlanet = null;
    connectMouseX = 0;
    connectMouseY = 0;
    stage = 1;
    won = false;
  }
  
  void updateScreen() {
    screenX = (-canvas.width / 2 - (canvas.width / 2 - mouseX) / 3) / screenScale;
    screenY = (-canvas.height / 2 - (canvas.height / 2 - mouseY) / 3) / screenScale;
  }
  
  void nextStage() {
    won = false;
    screenScale *= 0.9;
    updateScreen();
    String c = '#' + (random.nextInt(0x88) + 0x10).toRadixString(16) + (random.nextInt(0x88) + 0x10).toRadixString(16) + (random.nextInt(0x88) + 0x10).toRadixString(16);
    print(c);
    planets.add(new Planet((random.nextDouble() - 0.5) * 700 / screenScale, (random.nextDouble() - 0.5) * 400 / screenScale, c, random.nextDouble() * 100 + 50, (random.nextInt(stage * 5) + 5) / 100));
    stage++;
  }
  
  void clearConnections() {
    for (int i = 0; i < planets.length; i++) {
      planets[i].connections.clear();
    }
  }
  
  void help() {
    if (stage == 1) {
      gameState.fireCaption('Use your mouse to draw or remove arrows between planets.', '#000000', 5000);
    } else if (stage == 2) {
      gameState.fireCaption('The numbers indicate how fast population is transported.', '#000000', 5000);
    } else if (stage == 3) {
      gameState.fireCaption('Use your right mouse button to move planets.', '#000000', 5000);
    } else if (stage == 4) {
      gameState.fireCaption('If you\'re stuck, try clearing all the connections and starting from scratch.', '#000000', 5000);
    }
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
    if (won && mouseLeftDown) {
      print(equality);
      nextStage();
    }
  }
  
  void draw() {
    for (int i = 0; i < planets.length; i++) {
      planets[i].drawConnections();
    }
    if (connectPlanet != null) {
      connectPlanet.drawArrow(connectMouseX / screenScale + screenX, connectMouseY / screenScale + screenY);
    }
    for (int i = 0; i < planets.length; i++) {
      planets[i].draw();
    }
    // --- stage --- \\
    bufferContext.fillStyle = '#000000';
    bufferContext.font = '50px coda';
    bufferContext.textAlign = 'left';
    bufferContext.fillText('Stage ' + stage.toString(), 20, 70);
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
    // --- shreshold --- \\
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
      bufferContext.font = 'bold 60px coda';
      bufferContext.textAlign = 'center';
      bufferContext.fillText('You\'ve did it.', canvas.width / 2 + mx / 100, canvas.height / 3 + my / 100 + 3, 210);
      bufferContext.fillStyle = '#000000';
      bufferContext.globalAlpha = 1;
      bufferContext.font = 'bold 50px coda';
      bufferContext.fillText('You\'ve did it.', canvas.width / 2 - mx / 100, canvas.height / 3 - my / 100, 200);
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
    for (int i = 0; i < connections.length; i++) {
      connections[i].taking += g;
      value -= g;
    }
    giving = g * connections.length;
  }
  
  void take() {
    value += taking;
    updateRadius();
    equilibrium = giving.round() == taking.round();
    taking = 0;
  }
  
  void drawConnections() {
    num xx = (x - level.screenX) * level.screenScale;
    num yy = (y - level.screenY) * level.screenScale;
    for (int i = 0; i < connections.length; i++) {
      drawArrow(connections[i].x, connections[i].y);
    }
  }
  
  void drawArrow(num headX, num headY) {
    num b = rate * 50;
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
    bufferContext.beginPath();
    bufferContext.moveTo(xx - h, yy - v);
    bufferContext.lineTo(hx, hy);
    bufferContext.lineTo(xx + h, yy + v);
    bufferContext.fillStyle = color;
    bufferContext.fill();
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