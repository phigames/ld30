library ld30;

import 'dart:html';
import 'dart:math';

part 'gamestate.dart';
part 'level.dart';
part 'input.dart';
part 'resources.dart';

CanvasElement canvas, buffer;
CanvasRenderingContext2D canvasContext, bufferContext;
num lastUpdate;
Random random;
GameState gameState;

void main() {
  loadAudio();
  canvas = querySelector('#canvas');
  buffer = new CanvasElement(width: canvas.width, height: canvas.height);
  canvasContext = canvas.context2D;
  bufferContext = buffer.context2D;
  mouseX = (canvas.width / 2).round();
  mouseY = (canvas.height / 2).round();
  mouseLeftDown = false;
  mouseRightDown = false;
  canvas.onMouseDown.listen(onMouseDown);
  canvas.onMouseUp.listen(onMouseUp);
  canvas.onMouseMove.listen(onMouseMove);
  canvas.onFullscreenChange.listen(onFullScreenChange);
  InputElement f = querySelector('#fullscreen');
  f.onClick.listen((_) => goFullscreen());
  InputElement c = querySelector('#clear');
  c.onClick.listen((_) => level.clearConnections());
  InputElement h = querySelector('#help');
  h.onClick.listen((_) => gameState.help());
  lastUpdate = 0;
  random = new Random();
  gameState = new IntroState();
  window.animationFrame.then(frame);
}

void goFullscreen() {
  if (document.fullscreenEnabled) {
    canvas.requestFullscreen();
  }
}

void onFullScreenChange(Event event) {
  if (document.fullscreenElement != null) {
    canvas.width = buffer.width = window.screen.width;
    canvas.height = buffer.height = window.screen.height;
  } else {
    canvas.width = 800;
    canvas.height = 450;
  }
  level.updateScreen();
}

void frame(num time) {
  if (lastUpdate == 0) {
    lastUpdate = time;
  } else {
    gameState.tick(time - lastUpdate);
    lastUpdate = time;
  }
  gameState.render();
  window.animationFrame.then(frame);
}