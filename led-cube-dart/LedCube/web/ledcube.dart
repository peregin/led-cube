import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl' as WebGL;

void main() {
  // setup part
  final Element message = querySelector("#message_id");
  message.text = "Loading...";
  CanvasElement canvas = querySelector("#cube_canvas_id") as CanvasElement;
  if (canvas == null) {
    message.text = "Canvas not found";
    return;
  } 
  WebGL.RenderingContext gl = canvas.getContext("experimental-webgl");
  if (gl == null) {
    message.text = "Web GL is not supported";
    return;
  } 
  message.text = "Web GL context is ready";
  
  gl.viewport(0, 0, canvas.width, canvas.height); 
  
  Experiment exp = new Experiment(gl);
  exp.init();
  exp.run();
}

class Experiment {
  
  WebGL.RenderingContext gl;
  WebGL.Program program;
  CanvasElement canvas;
  double aspect = 1.2;
  bool running = false;
  
  double foobar = 0.5;
  int itemSize = 2; // 2D space
  bool adding = true;
  
  Experiment(WebGL.RenderingContext gl) {
    this.gl = gl;
  }
  
  bool init() {
    // vertex shader source code. uPosition is our variable that we'll
    // use to create animation
    String vsSource = """
    attribute vec2 aPosition;
    void main() {
      gl_Position = vec4(aPosition, 0, 1);
    }
    """;
    
    // fragment shader source code. uColor is our variable that we'll
    // use to animate color
    String fsSource = """
    precision mediump float;
    uniform vec4 uColor;
    void main() {
      gl_FragColor = uColor;
    }""";
    
    // vertex shader compilation
    WebGL.Shader vs = this.gl.createShader(WebGL.RenderingContext.VERTEX_SHADER);
    this.gl.shaderSource(vs, vsSource);
    this.gl.compileShader(vs);
    
    // fragment shader compilation
    WebGL.Shader fs = this.gl.createShader(WebGL.RenderingContext.FRAGMENT_SHADER);
    this.gl.shaderSource(fs, fsSource);
    this.gl.compileShader(fs);
    
    // attach shaders to a WebGL program
    WebGL.Program p = this.gl.createProgram();
    this.gl.attachShader(p, vs);
    this.gl.attachShader(p, fs);
    this.gl.linkProgram(p);
    this.gl.useProgram(p);
    
    /**
     * Check if shaders were compiled properly. This is probably the most painful part
     * since there's no way to "debug" shader compilation
     */
    if (!this.gl.getShaderParameter(vs, WebGL.RenderingContext.COMPILE_STATUS)) { 
      print(this.gl.getShaderInfoLog(vs));
    }
    
    if (!this.gl.getShaderParameter(fs, WebGL.RenderingContext.COMPILE_STATUS)) { 
      print(this.gl.getShaderInfoLog(fs));
    }
    
    if (!this.gl.getProgramParameter(p, WebGL.RenderingContext.LINK_STATUS)) { 
      print(this.gl.getProgramInfoLog(p));
    }
        
    this.program = p;
  }
  
  /**
   * Rendering loop
   */
  void update() {
    // genereate 3 points (that's 6 items in 2D space) = 1 polygon
    Float32List vertices = new Float32List.fromList([
      -this.foobar, this.foobar * aspect,
      this.foobar,  this.foobar * aspect,
      this.foobar, -this.foobar * aspect
    ]);
 
    this.gl.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, this.gl.createBuffer());
    this.gl.bufferData(WebGL.RenderingContext.ARRAY_BUFFER,
                       vertices, WebGL.RenderingContext.STATIC_DRAW);
 
    int numItems = vertices.length ~/ this.itemSize;
 
    this.gl.clearColor(0.9, 0.9, 0.9, 1);
    this.gl.clear(WebGL.RenderingContext.COLOR_BUFFER_BIT);
    
    // set color
    WebGL.UniformLocation uColor = gl.getUniformLocation(program, "uColor");
    // as defined in fragment shader source code, color is vector of 4 items
    this.gl.uniform4fv(uColor, new Float32List.fromList([this.foobar, this.foobar, 0.0, 1.0]));
 
    // set position
    // WebGL knows we want to use 'vertices' for this because
    // we called bindBuffer above (it's maybe a bit unclear but)
    // For more info: http://www.netmagazine.com/tutorials/get-started-webgl-draw-square
    int aPosition = this.gl.getAttribLocation(program, "aPosition");
    this.gl.enableVertexAttribArray(aPosition);
    this.gl.vertexAttribPointer(aPosition, this.itemSize,
                                WebGL.RenderingContext.FLOAT, false, 0, 0);
    
    // draw it!
    this.gl.drawArrays(WebGL.RenderingContext.TRIANGLES, 0, numItems);
    
    
    // change color and move the triangle a little bit
    this.foobar += (this.adding ? 1 : -1) * this.foobar / 100;
    
    if (this.foobar > 0.9) {
      this.adding = false;
    } else if (this.foobar < 0.2) {
      this.adding = true;
    }
    
    window.requestAnimationFrame((num time) { this.update(); });
  }  
  
  void run() {
    window.requestAnimationFrame((num time) { this.update(); });
//    window.setInterval(() => this.update(), 50); // that's 20 fps
    this.running = true;
  }
}
