/*
* My final Computer Graphics Course Assignment
*/

//global variables
float cameraPos = 0;
int gridRow = 48, gridCol = 16;
Grid grid;
boolean frustum = false;
Vessel vessel;
PImage[] textures = new PImage[4];

void setup(){
  size(640,630,P3D);
  colorMode(RGB,1.0);
  resetMatrix();
  
  //loading textures
  textureMode(NORMAL);
  textures[0] = loadImage("/assets/tex1.jpg");
  textures[1] = loadImage("/assets/tex2.jpg");
  textures[2] = loadImage("/assets/tex3.jpg");
  textures[3] = loadImage("/assets/tex4.jpg");
 
 //setup initial grid
  setupGrid();
  
}
 
 /*
 * setup grid
 * 48*16 tile gird
 */
public void setupGrid(){
  PVector start = new PVector(0,0,0);
  ArrayList<Tile[]> tiles = new ArrayList();
  
  for(int i=0; i<gridRow ;i++){
    Tile[] tile_col = new Tile[gridCol];
    for(int j=0; j<gridCol; j++){
      Tile t = new Tile( new PVector(start.x+j*0.1, start.y, start.z));
      tile_col[j] = t;
    }
    tiles.add(tile_col);
    start = new PVector(start.x,start.y+0.1,start.z);
  }
  grid = new Grid(tiles);
  vessel = new Vessel(new PVector(tiles.get(8)[7].pos.x,tiles.get(8)[7].pos.y,tiles.get(8)[7].pos.z));
}

//global variables for animation
boolean t0 = true;
float t0time;
float t =0;
float lerpDir = 0;
float finalPos;
float startPos;
boolean move = true;

void draw(){
  background(0.8, 0.8, 0.8);
  strokeWeight(2.0f);
  stroke(1,1,1);
  
  if(!frustum){
    ortho(-1,1,1,-1,-2,2);
    scale(1.2); 
    rotateX(-radians(30));
    rotateZ(-radians(45)); 
    translate(0,-.3,0);
  }
  else{ 
    translate(cameraPos*4,0,0.2);
    frustum(-1,1,1,-1,2,8);
    translate(0,-0.6,-4);
    scale(4);
    rotateX(-radians(75));
  }
  
  translate(-0.75,-0.95,0);
  //drawGrid
  grid.drawGrid();
  
  if(move){
    //move grid
    grid.moveGrid();
  }
  //drawVessel
  vessel.drawVessel();
  
  //if collision dont move
  move = vessel.collision();
  resetMatrix();
}

/*
* draw a 3D 2*2 cube on origin, with texture applied to the front
*/

void drawCube(PImage texture) {
  beginShape(QUADS);
  texture(texture);
  vertex(-1,-1,1,0,0);
  vertex(-1,1,1,0,0.5);
  vertex(1,1,1,0.5,0.5);
  vertex(1,-1,1,0.5,0);
  endShape();

  beginShape(QUADS);
  vertex(1,-1,1);
  vertex(1,-1,-1);
  vertex(1,1,-1);
  vertex(1,1,1);
  endShape();

  beginShape(QUADS);
  vertex(1,-1,-1);
  vertex(-1,-1,-1);
  vertex(-1,1,-1);
  vertex(1,1,-1);
  endShape();

  beginShape(QUADS);
  vertex(-1,-1,-1);
  vertex(-1,-1,1);
  vertex(-1,1,1);
  vertex(-1,1,-1);
  endShape();

  beginShape(QUADS);
  vertex(-1,1,1);
  vertex(1,1,1);
  vertex(1,1,-1);
  vertex(-1,1,-1);
  endShape();

  beginShape(QUADS);
  vertex(1,-1,1);
  vertex(-1,-1,1);
  vertex(-1,-1,-1);
  vertex(1,-1,-1);
  endShape();
}

/*
* drawing a 3D polygon on origin
*/
void drawTriangle(){
  beginShape(POLYGON);
  vertex(-1,-1,-1);
  vertex(1,-1,-1);
  vertex(0,0,1);
  endShape();
  
  beginShape(POLYGON);
  vertex(1,-1,-1);
  vertex(1,1,-1);
  vertex(0,0,1);
  endShape();
  
  beginShape(POLYGON);
  vertex(1,1,-1);
  vertex(-1,1,-1);
  vertex(0,0,1);
  endShape();
  
  beginShape(POLYGON);
  vertex(-1,1,-1);
  vertex(-1,-1,-1);
  vertex( 0,0,1);
  endShape();
  
  beginShape(QUADS);
  vertex(-1,-1,-1);
  vertex(-1,1,-1);
  vertex(1,-1,-1);
  vertex(1,1,-1);
  endShape();
}

//3D Grid of tiles
class Grid{
  ArrayList<Tile[]> tiles ;
  public Grid( ArrayList<Tile[]> tiles ){
    this.tiles = tiles;
  }
  
  public void drawGrid(){
    for(int i=0; i< tiles.size(); i++){
      for( int j=0 ; j< gridCol; j++){
        tiles.get(i)[j].drawTile();
      }
    }
  }
  
  //move the grid
  public void moveGrid(){
    if(tiles.get(0)[0].pos.y <= -1 ){
      addTilesAtEnd(); //add tiles to end
    }
    for(int i=0; i< tiles.size(); i++){
      for( int j=0 ; j< gridCol; j++){
        tiles.get(i)[j].moveTile();
      }
    }
  }
  
  //addTilesAtEnd
  public void addTilesAtEnd(){
    tiles.remove(0); //removing the first element to not make grid too big
    Tile[] lastTile = tiles.get(tiles.size()-1);
    PVector start = new PVector(lastTile[0].pos.x,lastTile[0].pos.y,lastTile[0].pos.z);
    start.y+=0.1;
    Tile[] tile_10 = new Tile[gridCol];
    for(int j=0; j<gridCol; j++){
      Tile t = new Tile( new PVector(start.x+j*0.1, start.y, start.z));
      tile_10[j] = t;
    }
    tiles.add(tile_10);
  }
}


//Tile Objects
class Tile{
  
  PVector pos;
  float h;
  boolean raised;
  PImage texture;
  boolean isPyramid = false;
  boolean isMine = false;
  
  float angle = 0.0;
  public Tile( PVector pos){
    
    this.pos = pos;
    int shouldRaise = (int)random(0,100);
    //is raised
    if(shouldRaise<12){
      this.h = random(0.01,0.08);
      raised = true;
      this.texture = textures[(int)random(2,4)];
    }
    
    else{
      int pyramid = (int)random(0,100);
      //turns into a pyramid
      if(pyramid<8){
        this.h = 0.01;
        raised = true;
        isPyramid = true;
        this.texture = textures[(int)random(2,4)];
      }
      else{
        int another = (int)random(0,100);
        //tile is a mine
        if(another<8){
          this.h = 0.01;
          raised = true;
          this.texture = textures[(int)random(2,4)];
          isMine = true;
        }
        else{
          //normal tile
          raised = false;
          this.h = 0.01;
          this.texture = textures[(int)random(0,2)];
        }
      }
    }  
  }
  
  public void drawTile(){
    //normal tile or a tile with height
    pushMatrix();
    stroke(0);
    strokeWeight(2);
    fill(0.5,0.5,0.5);
    if(raised){
      fill(0.3);
    }
    translate(pos.x, pos.y, pos.z);
    scale(0.05,0.05,h);
    drawCube(texture);
    popMatrix();
    
    //pyramid tile
    if(isPyramid){
      pushMatrix();
      translate(pos.x,pos.y,pos.z);
      rotate(angle);
      translate(-pos.x,-pos.y,-pos.z);
      
      fill(1,0.87,0.3);
      translate(pos.x, pos.y, pos.z+0.06);
      scale(0.03,0.03,0.03);
      stroke(0);
      strokeWeight(4);
      drawTriangle();
      popMatrix();
      angle+=0.01;
    }
    
    //mine tile
    if(isMine){
      pushMatrix();
      translate(pos.x,pos.y,pos.z);
      rotate(angle);
      translate(-pos.x,-pos.y,-pos.z);
      
      fill(0.1,0.1,0.4);
      translate(pos.x, pos.y, pos.z+0.06);
      scale(0.015,0.015,0.015);
      stroke(0);
      strokeWeight(4);
      
      pushMatrix();
      translate(0,0,1);
      drawTriangle();
      popMatrix();
      
      pushMatrix();
      translate(0,0,-1);
      rotateY(radians(180));
      drawTriangle();
      popMatrix();
      
      
      pushMatrix();
      translate(1.5,0,0);
      rotateY(radians(90));
      drawTriangle();
      popMatrix();
      
      pushMatrix();
      translate(-1.5,0,0);
      rotateY(-radians(90));
      drawTriangle();
      popMatrix();
      
      
      popMatrix();
      angle+=0.01;
    
    }
  }
  
  //moving tiles in the grid
  public void moveTile(){
    pos.y+=-0.003;
  }
}

//global variables for camera animation
float cameraStartPos;
float cameraFinalPos;
float angle = 0.0;

//vessel object
class Vessel{
  PVector pos;
  int currTile = 7;
  ParticleSystem p; //particle system
  
  public Vessel( PVector pos){
    this.pos = pos.copy();
    this.pos.z+=0.03;
    this.p = new ParticleSystem(this.pos);
  }
  
  //drawVessel
  public void drawVessel(){    
    
    //lerping
    if(lerpDir == 0.1||lerpDir == -0.1){
      if (t0) {
        t0time = millis();
        t= 0;
        if(!z){
          startPos= pos.x;
          
          finalPos = grid.tiles.get(0)[currTile].pos.x;
          cameraStartPos = cameraPos;
          cameraFinalPos = cameraPos-lerpDir;
        }
        else{
          startPos= pos.z;
          finalPos = pos.z+lerpDir*0.25;
          cameraStartPos = cameraPos;
          cameraFinalPos = cameraPos;
        }    
      }
    
      //animation
      if(!z){
        pos.x = mylerp(t,startPos,finalPos);
      }
      else{
        pos.z = mylerp(t,startPos,finalPos); 
      }
      
      cameraPos = mylerp(t, cameraStartPos, cameraFinalPos);
      
      if(t<=0.5){
        if(lerpDir == 0.1){
            angle = mylerp(t,0.0,90);
        }
        else{
          angle = mylerp(t,0.0,-90);
        }
      }
      else{
        if(lerpDir == 0.1){
            angle = mylerp(t,90,0);
        }
        else{
          angle = mylerp(t,-90,0);
        }
      }
      
      //pitching or rolling
      translate(pos.x,pos.y,pos.z);
      if(!z){
        rotateY(radians(angle));
      }
      else{
        rotateX(radians(angle));
      }
      translate(-pos.x,-pos.y,-pos.z);
      
      t = (millis() - t0time) / 1000.0 / 0.20;
      if (t > 1) {
        t0 = true;
        t = 0;
        lerpDir = 0.0;
        if(z){
          z = !z;
        }
      } else {
        t0 = false;   
      }
      
    } //<>//
    
    //drawing the ship starts here!
    stroke(0);
    fill(1,1,0);
    
    pushMatrix();
    
    translate(pos.x, pos.y, pos.z);
    scale(0.02,0.02,0.008);
    
    translate(1,-1.5,1);
    rotate(-radians(45));
    
    drawTriangle();   
    popMatrix();
    
    pushMatrix();
    
    translate(pos.x, pos.y, pos.z);
    scale(0.02,0.02,0.008);
    
    translate(-1,-1.5,1);
    rotate(radians(45));
    
    drawTriangle(); 
    popMatrix();
    
    stroke(0);
    fill(1,0,0);
    
    pushMatrix();
    
    translate(pos.x, pos.y, pos.z);
    scale(0.025,0.05,0.01);
    rotateX(-radians(90));
    rotate(-radians(45));
    
    drawTriangle();
    
    popMatrix();
    
    //Run the particle system
    p.addParticle(5);
    p.run(); 
  }
  
  //moveVessel //<>//
  public void moveVessel(float dir){
    
    if(!z){
      if(currTile == 15 && dir>0){
      }
      else if(currTile == 0 && dir<0){
      }
      else{
        if(lerpDir==0.0){
            lerpDir += dir; 
          if(dir>0){
            currTile++;
          }
          else{
            currTile--;
          }
          
          /**
          * Doesnot work, has some bugs in it
          * so commented it out
          */
          //boolean crash = collisionSide(dir);
          //if(! crash ){
          //  lerpDir = 0.0;
          //  if(dir>0){
          //    currTile--;
          //  }
          //  else{
          //    currTile++;
          //  }
          //}
        }
        else{
          z = false;
        }
      }
    }
    else{
      if(lerpDir==0.0){
        lerpDir += dir;
        if(dir==-0.1){ //<>//
          if(pos.z <= 0.04){//ground height
            lerpDir = 0.0;  
          }
        }
      }
      else{
        z = true;
      }
    }
    
  }
  
  //check collision head on
  public boolean collision(){
    float maxh = 0.0;
    boolean nohit = true;
    for(int i=0; i< grid.tiles.size(); i++){
        if((pos.y+0.05>grid.tiles.get(i)[currTile].pos.y-0.05&&pos.y+0.05<=grid.tiles.get(i)[currTile].pos.y+0.05)&&
        grid.tiles.get(i)[currTile].raised){  
          if(grid.tiles.get(i)[currTile].isPyramid||grid.tiles.get(i)[currTile].isMine){
            maxh = grid.tiles.get(i)[currTile].h+0.09;
            if((pos.z-0.01<=maxh)){  
            nohit = false;
            break;
            } 
          }
          else if((pos.z-0.01<=grid.tiles.get(i)[currTile].h)){  
            nohit = false;
            break;
          }
      }
    }
    return nohit;
  }
  
  //check collision on the side
  public boolean collisionSide(float dir){
    int toCheck = currTile;
    if(dir>0){
      toCheck++;
    }
    else{
      toCheck--;
    }
    float maxh = 0.0;
    boolean nohit = true;
    for(int i=0; i< grid.tiles.size(); i++){
      if(dir>0){
        if((pos.x+0.05>=grid.tiles.get(i)[toCheck].pos.x-0.05)&&
        grid.tiles.get(i)[toCheck].raised){  
          if(grid.tiles.get(i)[toCheck].isPyramid||grid.tiles.get(i)[toCheck].isMine){
            maxh = grid.tiles.get(i)[toCheck].h+0.09;
            if((pos.z-0.01<=maxh)){  
            nohit = false;
            break;
            } 
          }
          else if((pos.z-0.01<=grid.tiles.get(i)[toCheck].h)){  
            nohit = false;
            break;
          }
      }
      }
      else{
        if((pos.x-0.05<=grid.tiles.get(i)[toCheck].pos.x+0.05)&&
        grid.tiles.get(i)[toCheck].raised){  
          if(grid.tiles.get(i)[toCheck].isPyramid||grid.tiles.get(i)[toCheck].isMine){
            maxh = grid.tiles.get(i)[toCheck].h+0.09;
            if((pos.z-0.01<=maxh)){  
            nohit = false;
            break;
            } 
          }
          else if((pos.z-0.01<=grid.tiles.get(i)[toCheck].h)){  
            nohit = false;
            break;
          }
      }
     }
        
    }
    return nohit;
  }
  
}

boolean z = false;

void keyPressed(){
  if(key == ' '){
    frustum = !frustum;
  }
  if(key == 'w'){
    z=true;
    vessel.moveVessel(0.1);
    
  }
  if(key == 'a'){
    
    vessel.moveVessel(-0.1);
  }
  if(key == 's'){
    z=true;
    vessel.moveVessel(-0.1);
    
  }
  if(key == 'd'){
    vessel.moveVessel(0.1);
  }
}

float mylerp(float t, float a, float b) {
  return (1 - t) * a + t * b;
}

//particle System for vehicle exhaust
class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  ParticleSystem(PVector position) {
    origin = position;
    particles = new ArrayList<Particle>();
  }

  void addParticle(int num) {
      for(int i =0;i<num;i++){
        particles.add(new Particle(origin));
      }
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}

//Cube Particles
class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  float r,g,b;
  Particle(PVector l) {
    acceleration = new PVector(0,-0.002,-0.001);
    velocity = new PVector(random(-0.005, 0.005), random(-0.007, 0.007),random(-0.005, 0.005));
    position = l.copy();
    position.y-=0.05;
    lifespan = 10;
    r = 1;
    g = 0.8;
    b = 0;
  }
  void run() {
    update();
    display();
  }

  
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 1.0;
  }


  void display() {
    noStroke();
    fill(r,g,b,lifespan/10);
    
    pushMatrix();
    translate(position.x,position.y,position.z);
    scale(0.004,0.004,0.004);
    drawCube(null);
    popMatrix();
  }

  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
