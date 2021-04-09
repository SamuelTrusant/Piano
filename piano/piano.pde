//Basado en el ejemplo de Minim CreateAnInstrument
import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput out;

//Notas musicales en notación anglosajona
String [] notesS={"G3", "A3", "B3", "C4", "D4", "E4", "F4", "G4", "A4", "F#3", "G#3", "A#3", "", "C#4", "D#4", "", "F#4", "G#4", "A#4"};
char[] keysChars = {'a','s','d','f','g','h','j','k','l','q','w','e','r','t','y','u','i','o','p'};

boolean [] keys = new boolean[notesS.length];

//canción oda a la alegría
int[] song = {5,6,7,7,6,5,4,3,3,4,5,5,4,4,5,6,7,7,6,5,4,3,3,4,5,4,3,3,4,5,3,4,5,6,5,3,4,5,6,5,4,3,4,0,5,5,6,7,7,6,5,4,3,3,4,5,4,3,3,3};
//canción piratas del caribe
//int[] song =   {1,3,4,4,4,5,6,6,6,7,5,5,4,3,3,4,1,3,4,4,4,5,6,6,6,7,5,5,4,3,4,1,3,4,4,4,6,7,7,7,8,18,18,8,7,8,4,4,5,6,6,7,8,4,5,6,5,5,4,3,4,5,6,8,18,8,18,8,8,8,8,18,8,7,7,7,7,8,8,8,8,18,8,7,6,5,4,4,5,6,7,8,7,6,5,6,7,8,7,6,7,8,7,6,5,6,5,4,4,5,3,4,4,5,6,5,6,7,6,7,8,7,6,4,4,3,6,7,8,18,4,5,6,5,5,4,3,4,5,6,8,18,8,8,8,8,7,7,6,5,6,5,4,8,18,8,8,8,8,7,7,6,5,6,5,4,1,1};

boolean waiting = false;
int currentKey = song[0];

int framesPerBeat = 50;
int frame = 0;
int framesPerStep = 30;
float originNotePos = -500;
int step = -5;
int posy = 0;
int distancePerStep = 5;
int distancePerBeat = 10;

int currentDuration = 0;

boolean freeMode = false;

PImage background;

class Note{
  float posx;
  float posy;
  float sizex;
  float sizey;
  int beats;
  boolean white;
  Note(float posx, float posy, float sizex, int beats, boolean white){
    this.posx = posx;
    this.posy = posy;
    this.sizex = sizex;
    this.beats = beats;
    this.sizey = beats*100;
    this.white = white;
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
  size(450, 700);
  background = loadImage("mar.jpg");
  
  minim = new Minim(this);
  
  // Línea de salida
  out = minim.getLineOut();
  
  for(int i = 0; i < keys.length; i++){
     keys[i] = false;
  }
}

void draw() {
  background(100);
  image(background,0,0);
  posy++;
  textAlign(LEFT);
  text("[x] -> modo libre / canción\n[b] -> reiniciar la canción\nflechas arriba y abajo -> cambiar velocidad canción",10,20);
  
  //Dibujamos las celdas/teclas blancas
  for (int i=0;i<9;i++){
    if(keys[i] == true){
      fill(150);
    } else {
      fill(250);
    }
    rect(i*50,height-100,50,100);
    textAlign(CENTER);
    fill(0);
    text(notesS[i],i*50+25, height - 25);
    text("["+keysChars[i]+"]",i*50+25, height - 10);
    fill(250);
  }
  
  //Dibujamos las celdas/teclas negras
  for (int i=9;i<notesS.length;i++){
    if(keys[i] == true){
      fill(150);
    } else {
      fill(0);
    }
    if(i != 12 && i!= 15 && i!=18){
      rect((i%9)*50-15,height-100,30,60);
      textAlign(CENTER);
      fill(250);
      text(notesS[i],(i%9)*50, height - 65);
      text("["+keysChars[i]+"]",(i%9)*50, height - 50);
    }
    if(i==18){
      rect(width-15,height-100,30,60);
      textAlign(CENTER);
      fill(250);
      text(notesS[i],width, height - 65);
      text("["+keysChars[i]+"]",(i%9)*50, height - 50);
    }
    fill(250);
  }
  
  //beat de referencia
  /*
  if(frame%framesPerBeat > -3 && frame%framesPerBeat < 3){
    circle(30,30,80);
  } else {
    circle(30,30,40);
  }*/
  
  if(freeMode == true)return;
  //dibujamos las notas en pantalla
  for(Note note : notes){
      rect(note.posx,note.posy,note.sizex,note.sizey);
      if(waiting == false)  note.move((height-originNotePos-200)/framesPerBeat);
  }
  if(waiting == false){  
    //cuenta atrás para que empieze la canción
    if(step < 1){
      textSize(60);
      text(""+abs(step),width/2,height/2);
      textSize(14);
    }
    //antes de empezar la canción
    if(step < -1){
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
            notes.add(new Note(song[step]*50.,originNotePos,50.,1,true));
          } else{
            if(currentDuration >= notes.get(step).beats){
              step++;
              if(song[step] >= 9){
                if(song[step] == 18){
                  notes.add(new Note(width-15,originNotePos,30.,1,false));
                } else {
                  notes.add(new Note((song[step]%9)*50.-15,originNotePos,30.,1,false));
                }
              } else {
                notes.add(new Note(song[step]*50.,originNotePos,50.,1,true));
              }
              currentDuration = 0;
              currentKey = song[step-1];
              waiting = true;
            }
          }
        }
      }
    }
    frame++;
  }
}

/*
void mousePressed() {
  //Nota en función del valor de mouseX
  int tecla=(int)(mouseX/50);
  println(tecla);
  
  //Primeros dos parámetros, tiempo y duración
  out.playNote( 0.0, 0.9, new SineInstrument( Frequency.ofPitch( notesS[tecla] ).asHz() ) );  
}*/

void keyPressed(){
  int keyPresed = -1;
  switch(key){
    /*
    case 'a':
      keyPresed = 0;
      break;
    case 's':
      keyPresed = 1;
      break;
    case 'd':
      keyPresed = 2;
      break;
    case 'f':
      keyPresed = 3;
      break;
    case 'g':
      keyPresed = 4;
      break;
    case 'h':
      keyPresed = 5;
      break;
    case 'j':
      keyPresed = 6;
      break;
    case 'k':
      keyPresed = 7;
      break;
    case 'l':
      keyPresed = 8;
      break;
    case 'q':
      keyPresed = 9;
      break;
    case 'w':
      keyPresed = 10;
      break;
    case 'e':
      keyPresed = 11;
      break;
    case 't':
      keyPresed = 13;
      break;
    case 'y':
      keyPresed = 14;
      break;
    case 'i':
      keyPresed = 16;
      break;
    case 'o':
      keyPresed = 17;
      break;
    case 'p':
      keyPresed = 18;
      break;
      */
    case 'b':
      resetSong();
      break;
    case 'x':
      freeMode = !freeMode;
      resetSong();
      
  }
  
  for(int i = 0; i < keysChars.length;i++){
    if(i != 12 && i!= 15){
      if(keysChars[i] == key){
        keys[i]= true;
        out.playNote( 0.0, 0.9, new SineInstrument( Frequency.ofPitch( notesS[i] ).asHz() ) );
        if(i == currentKey) waiting = false;
      }
    }
  }
  if (keyCode == UP) {
    framesPerBeat+=5;
  }
  if (keyCode == DOWN) {
    if(framesPerBeat >5){
      framesPerBeat-=5;
    }
  }
    /*
  if (keyPresed >= 0 && keyPresed < notesS.length){
    keys[keyPresed]= true;
    out.playNote( 0.0, 0.9, new SineInstrument( Frequency.ofPitch( notesS[keyPresed] ).asHz() ) );
    if(keyPresed == currentKey) waiting = false;
  }*/
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
  waiting = false;
  //notes.add(new Note(song[0]*50.,originNotePos,50.,notesDuration[0]));
}
