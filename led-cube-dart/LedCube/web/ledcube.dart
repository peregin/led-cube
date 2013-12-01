import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl' as WebGL;

void main() {
  final Element message = querySelector("#message_id");
  message.text = "Loading...";
  CanvasElement canvas = querySelector("#cube_canvas_id") as CanvasElement;
  if (canvas == null) {
    message.text = "Canvas not found";
  } else {
    WebGL.RenderingContext gl = canvas.getContext("experimental-webgl");
    if (gl == null) {
      message.text = "Web GL is not supported";
    } else {
      message.text = "Web GL context is ready";
      gl.viewport(0, 0, canvas.width, canvas.height);
      WebGL.Shader fragmentShader = gl.createShader(WebGL.RenderingContext.FRAGMENT_SHADER);
      WebGL.Shader vertexShader = gl.createShader(WebGL.RenderingContext.VERTEX_SHADER);
      
      var program = gl.createProgram();
      gl.attachShader(program, vertexShader);
      gl.attachShader(program, fragmentShader);
      gl.linkProgram(program);
      gl.useProgram(program);

      // look up where the vertex data needs to go.
      var positionLocation = gl.getAttribLocation(program, "a_position");

      // Create a buffer and put a single clipspace rectangle in it (2 triangles)
      var buffer = gl.createBuffer();
      gl.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, buffer);
      var vertices = [-1.0, -1.0,
                      1.0, -1.0,
                      -1.0,  1.0,
                      -1.0,  1.0,
                      1.0, -1.0,
                      1.0,  1.0];
      gl.bufferDataTyped(WebGL.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(vertices), WebGL.RenderingContext.STATIC_DRAW);
      gl.enableVertexAttribArray(positionLocation);
      gl.vertexAttribPointer(positionLocation, 2, WebGL.RenderingContext.FLOAT, false, 0, 0);

      // draw
      gl.drawArrays(WebGL.RenderingContext.TRIANGLES, 0, 6);
      
      message.text = "Done...";
    }
  }
}
