//Basado en el ejemplo de Minim CreateAnInstrument
import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput out;

//Notas musicales en notación anglosajona
String [] notesS={"A3", "B3", "C4", "D4", "E4", "F4", "G4", "A4", "A#4"};
boolean [] keys = {false,false,false,false,false,false,false,false,false,false};

//canción piratas del caribe
int[] song = {0,2,3,3,3,4,5,5,5,6,4,4,3,2,2,3};
int[] notesDuration = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};

int framesPerBeat = 50;
int frame = 0;
int framesPerStep = 30;
float originNotePos = -500;
int step = -5;
int posy = 0;
int distancePerStep = 5;
int distancePerBeat = 10;

int currentDuration = 0;

class Note{
  float posx;
  float posy;
  float sizex;
  float sizey;
  int beats;
  Note(float posx, float posy, float sizex, int beats){
    this.posx = posx;
    this.posy = posy;
    this.sizex = sizex;
    this.beats = beats;
    this.sizey = beats*100;
  }
  
  void move(float distance){
    posy+=distance;
  }
}

//notas en pantalla
ArrayList<Note> notes = new ArrayList<Note>();

// Clase que describe la interfaz del instrumento, idéntica al ejemplo
//Modifcar para nuevos instrumentos
class SineInstrument implements Instrument
{
  Oscil wave;
  Line  ampEnv;
  
  SineInstrument( float frequency )
  {
    // Oscilador sinusoidal con envolvente
    wave   = new Oscil( frequency, 0, Waves.SINE );
    ampEnv = new Line();
    ampEnv.patch( wave.amplitude );
  }
  
  // Secuenciador de notas
  void noteOn( float duration )
  {
    // Amplitud de la envolvente
    ampEnv.activate( duration, 0.5f, 0 );
    // asocia el oscilador a la salida
    wave.patch( out );
  }
  
  // Final de la nota
  void noteOff()
  {
    wave.unpatch( out );
  }
}

void setup()
{
  size(450, 800);
  
  minim = new Minim(this);
  
  // Línea de salida
  out = minim.getLineOut();
  
  //notes.add(new Note(song[0]*50.,originNotePos,50.,notesDuration[0]));
}

void draw() {
  background(100);
  posy++;
  
  //Dibujamos las celdas/teclas
  for (int i=0;i<9;i++){
    if(keys[i] == true){
      fill(150);
    } else {
      fill(250);
    }
    rect(i*50,height-100,50,100);
  }
  
  if(frame%framesPerBeat > -3 && frame%framesPerBeat < 3){
    circle(30,30,80);
  } else {
    circle(30,30,40);
  }
  
  //dibujamos las notas en pantalla
  for (Note note : notes){
      rect(note.posx,note.posy,note.sizex,note.sizey);
      note.move(1300/framesPerBeat);
  }
  if(step < 1){
    text(""+abs(step),width/2,height/2);
  }
  //antes de empezar la canción
  if(step < -1){
    //text(""+abs(step),width/2,height/2);
      if(frame%framesPerBeat == 0){
        step++;
      }
  } else {
    //durante la canción
    if(step < song.length-1){      
      if(frame%framesPerBeat == 0){
        currentDuration++;
        if(step == -1){
          step++;
          notes.add(new Note(song[step]*50.,originNotePos,50.,notesDuration[step]));
        } else{
          if(currentDuration >= notes.get(step).beats){
            step++;
            notes.add(new Note(song[step]*50.,originNotePos,50.,notesDuration[step]));
            currentDuration = 0;
          }
        }
      }
    }
  }
  frame++;
}

void mousePressed() {
  //Nota en función del valor de mouseX
  int tecla=(int)(mouseX/50);
  println(tecla);
  
  //Primeros dos parámetros, tiempo y duración
  out.playNote( 0.0, 0.9, new SineInstrument( Frequency.ofPitch( notesS[tecla] ).asHz() ) );  
}

void keyPressed(){
  int tecla = -1;
  switch(key){
    case 'a':
      tecla = 0;
      break;
    case 's':
      tecla = 1;
      break;
    case 'd':
      tecla = 2;
      break;
    case 'f':
      tecla = 3;
      break;
    case 'g':
      tecla = 4;
      break;
    case 'h':
      tecla = 5;
      break;
    case 'j':
      tecla = 6;
      break;
    case 'k':
      tecla = 7;
      break;
    case 'l':
      tecla = 8;
      break;
    case 'r':
      resetSong();
      break;
  }
  if (keyCode == UP) {
    framesPerBeat+=10;
  }
  if (keyCode == DOWN) {
    if(framesPerBeat >10){
      framesPerBeat-=10;
    }
  }
    
  if (tecla >= 0 && tecla < 9){
    keys[tecla]= true;
    out.playNote( 0.0, 0.9, new SineInstrument( Frequency.ofPitch( notesS[tecla] ).asHz() ) );  
  }
}

void keyReleased(){
  for(int i = 0; i < keys.length; i++){
    keys[i] = false;
  }
}

void resetSong(){
  frame = 0;
  step = -5;
  notes.clear();
  //notes.add(new Note(song[0]*50.,originNotePos,50.,notesDuration[0]));
}
