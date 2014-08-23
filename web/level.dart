part of ld30;

Level level;

class Level {
  
  num updateTime;
  num screenX, screenY;
  num screenWidth, screenHeight;
  num screenScale;
  List<Planet> planets;
  bool equilibrium;
  int equilibriumTime;
  bool equality;
  int equalityTime;
  Planet connectPlanet;
  int connectMouseX, connectMouseY;
  
  Level() {
    updateTime = 0;
    updateScreen();
    screenScale = 1;
    equilibrium = false;
    equilibriumTime = 0;
    equality = false;
    equalityTime = 0;
    planets = new List<Planet>();
    planets.add(new Planet(-200, 0, '#880000', 100, 0.1));
    planets.add(new Planet(200, 0, '#000088', 100, 0.1));
    connectPlanet = null;
    connectMouseX = 0;
    connectMouseY = 0;
  }
  
  void updateScreen() {
    screenX = -canvas.width / 2;
    screenY = -canvas.height / 2;
    screenWidth = canvas.width;
    screenHeight = canvas.height;
  }
  
  void update(num time) {
    updateTime += time;
    if (connectPlanet != null) {
      if (mouseDown) {
        connectMouseX = mouseX;
        connectMouseY = mouseY;
      } else {
        num mx = connectMouseX + screenX;
        num my = connectMouseY + screenY;
        for (int i = 0; i < planets.length; i++) {
          if (planets[i].contains(mx, my)) {
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
      if (mouseDown) {
        num mx = mouseX + screenX;
        num my = mouseY + screenY;
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
        planets[i].updatePosition();
      }
      if (equilibriumTime > 0) {
        equilibriumTime++;
        equilibrium = equilibriumTime > 4;
      } else {
        equilibrium = false;
      }
      if (max - min < 30) {
        equalityTime++;
        equality = equalityTime > 4;
      } else {
        equalityTime = 0;
        equality = false;
      }
      if (equilibrium && equality) {
        // won
      }
      updateTime -= 50;
    }
  }
  
  void draw() {
    for (int i = 0; i < planets.length; i++) {
      planets[i].drawConnections();
    }
    if (connectPlanet != null) {
      connectPlanet.drawArrow(connectMouseX + screenX, connectMouseY + screenY);
    }
    for (int i = 0; i < planets.length; i++) {
      planets[i].draw();
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
    radius = value / 2 + 30;
  }
  
  void updatePosition() {
    
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
    num xx = x - level.screenX;
    num yy = y - level.screenY;
    for (int i = 0; i < connections.length; i++) {
      drawArrow(connections[i].x, connections[i].y);
    }
  }
  
  void drawArrow(num headX, num headY) {
    num b = 10;
    num xx = x - level.screenX;
    num yy = y - level.screenY;
    num hx = headX - level.screenX;
    num hy = headY - level.screenY;
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
    num xx = x - level.screenX;
    num yy = y - level.screenY;
    bufferContext.beginPath();
    bufferContext.arc(xx, yy, radius, 0, 2 * PI);
    bufferContext.fillStyle = color;
    bufferContext.fill();
    if (contains(mouseX + level.screenX, mouseY + level.screenY)) {
      bufferContext.fillStyle = '#FFFFFF';
    } else {
      bufferContext.fillStyle = '#AAAAAA';
    }
    bufferContext.textAlign = 'center';
    bufferContext.font = 'bold 20px coda';
    bufferContext.fillText((rate * 100).round().toString() + '%', xx, yy + 8);
  }
  
}