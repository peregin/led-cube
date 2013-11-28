import 'dart:html';

void main() {
  CanvasElement canvas = querySelector("#cube_canvas_id");
  WebGLRenderingContext gl = canvas.getContext("experimental-webgl");
  if (gl == null) {
    querySelector('body').appendHtml("""<p>Your browser probably doesn\'t support WebGL.</p>""");;
  } else {
    gl.viewport(0, 0, canvas.width, canvas.height);
  }
}
