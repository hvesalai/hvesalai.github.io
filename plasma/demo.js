/**
 * Created by Heikki Vesalainen
 *
 * You are free to copy, modify and distribute this as you will.
 */

window.onload = function() {
  document.getElementsByTagName("body")[0].className = "js";
  new test2504afjd.Demo("canvas", "fps").start();
};

var test2504afjd = test2504afjd ? test2504afjd : {};

test2504afjd.MAX_FPS = 50;
test2504afjd.Demo = function(canvasId, fpsId) {

  var canvas = null;
  var context = null;
  var fps = null;
  var width, height; 
  var xscale = 1, yscale = 1;
  var xshift = 0, yshift = 0;
  var rscale = 1, gscale = 1, bscale = 1;
  var rshift = 0, gshift = 0, bshift = 0;
  var tscale = 0.02;
  var sinCache = [];
  var lastTick = 0;
  var targetFps = 1;
  var fpsDownDecrement = 10;
 
  var image;

  for (width = 0; width < 360; width++) {
    sinCache[width] = 127 + (127*Math.sin(width * Math.PI / 180));
  }

  function init() {
    targetFps = test2504afjd.MAX_FPS;
    fpsDownDecrement = targetFps / 3;

    canvas = canvasId ? document.getElementById(canvasId) : null;
    fps = fpsId ? document.getElementById(fpsId) : null;

    if (canvas && canvas.getContext) {
	    canvas.width = width = canvas.clientWidth / 8;
	    canvas.height = height = canvas.clientHeight / 8;
	    context = canvas.getContext("2d");

	    if (context.createImageData) {
        image = context.createImageData(canvas.width, canvas.height);
	    } else if (context.getImageData) {
        image = context.getImageData(0, 0, 
                                     canvas.width, canvas.height);
	    } else {
        // it's Opera
        image = {'width' : canvas.width, 'height' : canvas.height, 
                 'data' : new Array(canvas.width*canvas.height*4)}
	    }

	    for (i = 0; i < image.data.length; i++) {
        image.data[i] = 255;
	    }
	    return true;
    } else {
	    return false;
    }
  }

  function updateValues(time) {
    // magic values found by a mystic artistic process

    time *= tscale;
    rscale = sin(time*1.3) / canvas.height * 1.1;
    gscale = sin(time*1.4) / canvas.height * 1.2;
    bscale = sin(time*1.5) / canvas.height * 1.3;

    xshift = time / Math.PI / 100000000;
    yshift = time / Math.E / 200000000;
    rshift = sin(time+27);
    gshift = sin(time+127);
    bshift = sin(time+189);
  }

  function sin(r) {
    r = Math.round(r);
    return sinCache[r % 360];
  }

  function draw() {
    // magical algorithm found by a mystic artistic process

    if (!image) {
	    return;
    }

    var x, y, i, j, p = 0;
    var yr, yg, yb;
    var xr = [], xg = [], xb = [];
    var pixels, pixel;

    // precalculate X values, since they are the same for each Y
    for (i = 0; i < canvas.width; i+=1) {
	    // 0=R, 1=G, 2=B, 3=A
	    x = i + xshift;
	    
	    xr[i] = sin(x*rscale);
	    xg[i] = sin(x*gscale);
	    xb[i] = sin(x*bscale);
    }

    pixels = image.data;

    for (j = 0; j < canvas.height; j+=1) {
	    y = j + yshift;
	    // calculate Y values
	    yr = sin(y*rscale);
	    yg = sin(y*gscale);
	    yb = sin(y*bscale);

	    for (i = 0; i < canvas.width; i+=1) {
        // calculate pixel values based on X and Y
        pixels[p++] = sin((xr[i] * yg) / 128 + rshift + 100);
        pixels[p++] = sin((xb[i] + yr) / 2 + gshift + 200);
        pixels[p++] = sin((xg[i] * yb) / 256 + bshift + 300);
        p++;
	    }
    }

    context.putImageData(image, 0, 0);
  }

  function tick() {
    var start, elapsed, sleep, target;
    start = new Date().getTime();

    fps.innerHTML = Math.round(targetFps) + " FPS (target)";
    
    // check if the canvas has been resized
    if ((canvas.clientWidth / 8) != width ||
        (canvas.clientHeight / 8) != height) {
      init();
    }

    // do the magic
    updateValues(start);
    draw();

    // calculate stable FPS 
    elapsed = new Date().getTime() - start;
	
    target = 1000 / targetFps;

    if (start - lastTick > (target * 1.2)) {
	    // slow down, we are more than 20% behind
	    targetFps -= fpsDownDecrement;
	    if (targetFps < 2) {
        targetFps = 2;
	    }
    } else {
	    // speed up
	    if (targetFps < test2504afjd.MAX_FPS - 0.05) {
        targetFps += 0.05;
	    }
    }

    if (fpsDownDecrement >= 1) {
	    fpsDownDecrement /= 1.2;
    }

    target = 1000 / targetFps;

    // calculate sleep and schedule next tick
    sleep = target - elapsed;
    if (sleep < 1) {
	    sleep = 1;
    } else if (sleep > 1000) {
	    sleep = 1000;
    }

    lastTick = start;
    setTimeout(tick, sleep);
  }

  this.start = function() {
    lastTick = new Date().getTime();
    if(init()) tick();
  }
}
