class Ball
{
  public float _x;
  public float _y;
  public float _vx = 0.0f, _vy = 0.0f;
  public float _ax = 0.0f, _ay = 0.0f;
  public color _c = color(0, 1, 1);
  
  public float m;
  public float r;
  public float rho;
  
  public void changeSize(float mass, float dens)
  {
    m = mass;
    rho = dens;
    r = pow(0.75/PI*m/rho, 0.333);
  }
  
  public void render()
  {
    noStroke();
    fill(_c);
    ellipse(_x*pix_per_met, height-_y*pix_per_met, r*pix_per_met, r*pix_per_met);
  }
  
  public void tick(float Fx, float Fy, float dt)
  {
    _ax = Fx/m;
    _ay = Fy/m;
    _x  += dt*_vx+0.5*dt*dt*_ax;
    _y  += dt*_vy+0.5*dt*dt*_ay;
    _vx += dt*_ax;
    _vy += dt*_ay;
  }
}

static class Util
{
  static boolean isBounded(float x, float y, float w, float h)
  {
    return x>=0 && x<w && y>=0 && y<h;
  }
}
