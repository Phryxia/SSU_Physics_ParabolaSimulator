final float[] BUTTON = {0, 0};
Ball myBall;

/*
  Experiment Condition
*/
float wind_v    = 0;  // m/s
float wind_dir  = 0; // rad
final float g = 9.81;

float x_ini;
float y_ini;
boolean isFlying = false;
boolean isDrag = false;

float pix_per_met = 100;
float[] x_pos = new float[1024];
float[] y_pos = new float[1024];
int     pos_size = 0;
int T_RES = 1000;

int mode = 0; // 0 = No Resistance, 1 = Air, 2 = Water

boolean pressedControl = false;

void setup()
{
  size(800, 600);
  colorMode(HSB, 1.0);
  background(0);
  
  x_ini = width/8;
  y_ini = height/2;
  
  myBall = new Ball();
  myBall.changeSize(1, 7860);
  reset();
  
  frameRate(120);
}

float F, D, Theta;
int t = 0;

void draw()
{
  /*
    Graphic Output
  */
  background(0);
  if(mode > 0)
  {
    drawWind();
  }
  
  // Text
  textSize(14);
  text("Fluid  Speed : "+int(100*wind_v)/100.0+"m/s", 20, 20);
  text("Object Speed : "+int(100*dist(0, 0, myBall._vx, myBall._vy))/100.0+"m/s", 20+width/4, 20);
  text("Object Mass  : "+int(100*myBall.m)/100.0+"kg", 20, 40);
  text("Object Size  : "+int(100*myBall.r)/100.0+"m", 20+width/4, 40);
  text("Object Dens  : "+int(100*myBall.rho)/100.0+"kg/m^3", 20+width/2, 40);
  textSize(12);
  text("[m] : Mode Change        [SPACE] : RESET", 20, height-40); 
  text("[LEFT, RIGHT] Fluid Direction   [UP, DOWN] Fluid Speed   [Wheel] Object Mass   [CTRL+Wheel] Object Density", 20, height-20);
  String temp = "";
  switch(mode)
  {
    case 0:
      temp = "Mode : No Resistance";
      break;
    case 1:
      temp = "Mode : Air @ 25 C";
      break;
    case 2:
      temp = "Mode : Water @ 25 C";
      break;
  }
  text(temp, width-textWidth(temp)-20, 20);
  
  // Previous Ball
  noStroke();
  fill(0, 1, 0.5);
  for(int i=0; i<pos_size; ++i)
  {
    ellipse(x_pos[i]*pix_per_met, height - y_pos[i]*pix_per_met, 4, 4);
  }
  
  // Current Ball
  myBall.render();
  
  if(isFlying)
  {
    // Calculation & Assign New Value
    for(int d=0; d<T_RES; ++d) // Enhancing Time Resolution
    {
      // Fluid Resistance
      float fluid_S = 4*myBall.r*myBall.r*PI;
      float fluid_rho = 0.0f; // Density
      float fluid_cd  = 0.7f; // Sphere Type Constant
      switch(mode)
      {
        case 0: // NONE
          fluid_rho = 0.0f;
          break;
        case 1:
          fluid_rho = 1.184f; // Air Resistance
          break;
        case 2:
          fluid_rho = 997.0479; // Water Resistance
          break;
      }
      
      float x_resist = 0.5*fluid_rho*fluid_S*pow(abs(myBall._vx - wind_v*cos(wind_dir)), 2);
      float y_resist = 0.5*fluid_rho*fluid_S*pow(abs(myBall._vy - wind_v*sin(wind_dir)), 2);
      
      // Resistance Direction
      if(myBall._vx - wind_v*cos(wind_dir) > 0)
      {
        x_resist *= -1;
      }
      if(myBall._vy - wind_v*sin(wind_dir) > 0)
      {
        y_resist *= -1;
      }
      
      // Fluid Buoyancy
      float buoyancy = g*(fluid_rho*4/3*PI*pow(myBall.r, 3));
      
      // Final Calculation
      myBall.tick(x_resist, -g*myBall.m+y_resist+buoyancy, 1.0/frameRate/T_RES);
    }
    if(pos_size < x_pos.length-1 && t%10 == 0)
    {
      x_pos[pos_size] = myBall._x;
      y_pos[pos_size] = myBall._y;
      ++pos_size;
    }
  }
  else
  {
    textSize(40);
    text("Drag the Object!", width/2 - textWidth("Drag the Object!")/2, height/2);
    
    // Drag Motion : Determine Default Speed
    if(isDrag)
    {
      strokeWeight(2);
      stroke(0, 1, 0.5);
      
      D = dist(x_ini, y_ini, mouseX, mouseY);
      Theta = atan2(y_ini-mouseY, x_ini-mouseX);
      
      float v_temp = 0.1*D*sqrt(1.0/myBall.m);
      
      drawArrow(x_ini, y_ini, D, -Theta);
      textSize(10);
      text(int(v_temp*100)/100.0+"m/s", mouseX - 20, mouseY - 20);
      
      //line(x_ini, y_ini, mouseX, mouseY);
      strokeWeight(1);
    }
  }
  
  ++t;
}

void mousePressed()
{
  isDrag = true;
}

void mouseReleased()
{
  isDrag = false;
  
  if(!isFlying)
  {
    float v_temp = 0.1*D*sqrt(1.0/myBall.m);
    myBall._vx = v_temp*cos(Theta);
    myBall._vy = v_temp*sin(Theta+PI);
    isFlying = true;
  }
}

void mouseWheel(MouseEvent event)
{
  float delta = event.getCount();
  
  if(!pressedControl)
  {
    // Mass Control{
    if(myBall.m + delta > 0)
    {
      myBall.m += delta;
    }
  }
  else
  {
    // Rho Control
    if(myBall.rho*exp(-delta*0.5) > 0.01)
    {
      myBall.rho *= exp(-delta*0.5);
    }
  }
  myBall.changeSize(myBall.m, myBall.rho);
}

void keyPressed()
{
  if(key != CODED)
  {
    if(key == ' ')
    {
      // Reset
      reset();
    }
    else if(key == 'm')
    {
      // Mode Change
      switch(mode)
      {
        case 0:
          println("Mode has been changed into AIR");
          break;
        case 1:
          println("Mode has been changed into WATER");
          break;
        case 2:
          println("Mode has been changed into NO RESISTANCE");
          break;
      }
      mode = (mode+1)%3;
    }
  }
  else
  {
    // Wind Direction Change
    if(keyCode == LEFT)
    {
      wind_dir += PI/90;
    }
    if(keyCode == RIGHT)
    {
      wind_dir -= PI/90;
    }
    if(keyCode == DOWN)
    {
      if(wind_v > 0)
      {
        wind_v -= 0.1;
      }
    }
    if(keyCode == UP)
    {
      wind_v += 0.1;
    }
    if(keyCode == CONTROL)
    {
      pressedControl = true;
    }
  }
}

void keyReleased()
{
  pressedControl = false;
}

void reset()
{
  myBall._x = x_ini/pix_per_met;
  myBall._y = y_ini/pix_per_met;
  myBall._vx = 0.0;
  myBall._vy = 0.0;
  myBall._ax = 0.0;
  myBall._ay = 0.0;
  
  isFlying = false;
  pos_size = 0;
}

void drawWind()
{
  stroke(0.6, 1, 1);
  for(int y=0; y<10; ++y)
  {
    for(int x=0; x<10; ++x)
    {
      int wind_x = int(x/10.0*width);
      int wind_y = int(y/10.0*height);
      
      drawArrow(wind_x, wind_y, 10.0*wind_v, wind_dir);
    }
  }
}

void drawArrow(float _x, float _y, float _length, float theta)
{
  pushMatrix();
  translate(_x, _y);
  rotate(-theta);
  line(0, 0, -_length, 0);
  line(0, 0, -5*cos(PI/4), -5*sin(PI/4));
  line(0, 0, -5*cos(PI/4),  5*sin(PI/4));
  popMatrix();
}
