part of ld30;

bool mouseLeftDown, mouseRightDown;
int mouseX, mouseY;

void onMouseDown(MouseEvent event) {
  if (event.button == 0) {
    mouseLeftDown = true;
  } else if (event.button == 1) {
    mouseRightDown = true;
  }
}

void onMouseUp(MouseEvent event) {
  if (event.button == 0) {
    mouseLeftDown = false;
  } else if (event.button == 1) {
    mouseRightDown = false;
  }
}

void onMouseMove(MouseEvent event) {
  mouseX = event.layer.x;
  mouseY = event.layer.y;
}