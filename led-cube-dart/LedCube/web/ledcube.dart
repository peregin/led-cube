import 'dart:html';

void main() {
  CanvasElement canvas = querySelector("cube_canvas_id");
  WebGLRenderingContext gl = canvas.getContext("experimental-webgl");
  
  gl.viewport(0, 0, canvas.width, canvas.height);
  
  // Create fragment shader
  WebGLShader fragShader = gl.createShader(WebGLRenderingContext.FRAGMENT_SHADER);
}
