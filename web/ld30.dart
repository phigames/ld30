library ld30;

import 'dart:html';
import 'dart:math';

part 'gamestate.dart';
part 'level.dart';
part 'input.dart';

CanvasElement canvas, buffer;
CanvasRenderingContext2D canvasContext, bufferContext;
num lastUpdate;
Random random;
GameState gameState;

void main() {
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
  InputElement fullscreenButton = querySelector('#fullscreen');
  fullscreenButton.onClick.listen((_) => goFullscreen());
  lastUpdate = 0;
  random = new Random();
  gameState = new PlayingState();
  window.animationFrame.then(frame);
}

void goFullscreen() {
  canvas.requestFullscreen();
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
    gameState.update(time - lastUpdate);
    lastUpdate = time;
  }
  bufferContext.clearRect(0, 0, canvas.width, canvas.height);
  gameState.draw();
  canvasContext.clearRect(0, 0, canvas.width, canvas.height);
  canvasContext.drawImage(buffer, 0, 0);
  window.animationFrame.then(frame);
}