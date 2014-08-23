part of ld30;

bool mouseDown = false;
int mouseX = 0, mouseY = 0;

void onMouseDown(MouseEvent event) {
  mouseDown = true;
}

void onMouseUp(MouseEvent event) {
  mouseDown = false;
}

void onMouseMove(MouseEvent event) {
  mouseX = event.layer.x;
  mouseY = event.layer.y;
}