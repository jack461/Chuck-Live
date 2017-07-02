/**
 * Drawing OSC informations
 
 Jean-Jacques Girardot - June 29/30 2017
 
 License : WTFPL
 http://www.wtfpl.net
 
 A quick written application to trace information arriving
 on port 8642. 
 
 */

OscP5 oscP5;
int portList=8642;
Console c1;

PFont f0;
PFont f1;
PFont f2;
PFont f3;
PFont typo;
int bgColor; // back ground color
int bxColor; // Box color
int [] xLPos;
int [] yLPos;
int [] wLPos;
int [] hLPos;
int [] xVPos;
int [] yVPos;
int [] wVPos;
int [] hVPos;
int [] eUsed;
int [] eMod;
int [] eType;
int [] bForm;
int [] fSize;
int [] valInt;
float [] valFlt;
String [] valStr;
String [] vName;
int fCount;
boolean flagMod, flagRedraw;
boolean flagShowConsole;
boolean flagShowVols;

int avSize;
float [] allVols;
int fsDec;
int hpCircl;

int lMarg, tMarg;
int xFact, yFact;
int dx, dy;

int xCsl, yCsl, wCsl, hCsl;

int prvWidth, prvHeight;
int [] hpXPos;
int [] hpYPos;

void setColor(int cnum) {
  cnum = cnum & 0xf;
  // println("setColor " + cnum);
  switch (cnum) {
  default :fill(0xFF, 0xCC, 0x00); break; // Tangerine
  case 1:  fill(0x7F, 0xFF, 0xD4); break; // Aquamarine
  case 2:  fill(0xFF, 0xB8, 0x41); break;  // Brilliant Orange
  case 3:  fill(0x00, 0xCC, 0x99); break;  // Caribbean Green
  case 4:  fill(0xFF, 0x7F, 0x50); break;  // Coral
  case 5:  fill(0xFA, 0x08, 0xA1); break;  // ?
  case 6:  fill(0xCD, 0x5C, 0x5C); break;  // Indian Red
  case 7:  fill(0x20, 0xB2, 0xAA); break;  // Light Sea Green
  case 8:  fill(0x32, 0xCD, 0x32); break;  // Limegreen
  case 9:  fill(0x8E, 0x23, 0x23); break;  // Mandarian Orange
  case 10: fill(0xFC, 0xC4, 0x30); break;  // Saffron
  case 11: fill(0x66, 0xFF, 0x66); break;  // Ultra Green
  case 12: fill(0xFF, 0xBF, 0x00); break;  // Amber
  case 13: fill(0xBB, 0xBD, 0xD7); break;  // Lavender Grey
  case 14: fill(0xF5, 0xF5, 0xF5); break;  // White Smoke
  case 15: fill(0x00, 0x2F, 0xA7); break;  // International Klein Blue
  }
}

void setConsolePos() {
  xCsl = 10;
  yCsl = height - 210;
  wCsl = width - 10;
  hCsl = 190;
}

void setup() {
  // fullScreen();
  size(1640, 760);
  colorMode(RGB, 255, 255, 255);
  surface.setResizable(true);
  oscP5 = new OscP5(this, portList);
  c1 = new Console();
  frameRate(5); // Some slow updating is perfect
  smooth();
  prvWidth = prvHeight = 0;
  // 10,ha,width-20,height-20-ha

  setConsolePos();
  // background(0);
  // bgColor = 102;
  bgColor = 0;  // background color
  bxColor = 0; // Box color (for trace)
  background(bgColor);
  rectMode(CORNER);
  // int ftSize;
  // String fontName = "SourceCodePro-Regular.ttf";
  // Create the font
  // printArray(PFont.list());
  // ftSize = 20;
  // f = createFont(fontName, ftSize);
  // if (f == null) {
  //   println("Can'open font", fontName);
  // }
  f0 = createFont("Geneva", 20);
  f1 = createFont("Geneva", 36);
  f2 = createFont("Geneva", 58);
  f3 = createFont("Geneva", 80);
  typo = createFont("Geneva", 10);
  textFont(f0);
  // strokeWeight(1);

  // Positionning values
  xFact = 62; // width unit
  yFact = 18;  // height unit
  lMarg = 10; // left margin
  tMarg = 26; // top margin
  dx = 3;
  dy = 3;
  fsDec = 22; // full screen offset
  //
  // Creating the fields
  fCount = 96;
  xLPos = new int[fCount];
  yLPos = new int[fCount];
  xVPos = new int[fCount];
  yVPos = new int[fCount];
  wLPos = new int[fCount];
  hLPos = new int[fCount];
  wVPos = new int[fCount];
  hVPos = new int[fCount];
  eUsed = new int[fCount];
  eMod = new int[fCount];
  eType = new int[fCount];
  bForm = new int[fCount];
  fSize = new int[fCount];
  valInt = new int[fCount];
  valFlt = new float[fCount];
  valStr = new String[fCount];
  vName = new String[fCount];

  for (int i=0; i<fCount; i++) {
    xLPos[i] = yLPos[i] = xVPos[i] = yVPos[i] = 0;
    wLPos[i] = hLPos[i] = wVPos[i] = hVPos[i] = 0;
    eUsed[i] = eMod[i] = eType[i] = 0;
    bForm[i] = fSize[i] = 0;
    valInt[i] = 0;
    valFlt[i] = 0.0;
    valStr[i] = "'" + i + "'";
    vName[i] = "#" + i;
  }

  avSize = 16;
  allVols = new float[avSize];
  hpXPos = new int[avSize];
  hpYPos = new int[avSize];
  for (int i=0; i<avSize; i++) {
    allVols[i] = 0.0;
  }
  
  /*
  // Temp - testing
  allVols[0] = 1; allVols[1] = 0.001; allVols[2] = 0.7; allVols[3] = 0.05; allVols[4] = 0.01;
  allVols[5] = 0.1; allVols[6] = 0.0265; allVols[7] = 0.001;
  allVols[8] = 0.0465; allVols[9] = 0.1265; allVols[10] = 0.2265; 
  allVols[11] = 0.3465; allVols[12] = 0.4265; allVols[13] = 0.5265;
  allVols[14] = 0.6465; allVols[15] = 0.3; 
  */
  // Compute hp Pos
  hpCircl = 150;
  float ratio = 1.7;
  for (int i=0; i<avSize/2; i++) {
    hpXPos[i] = int(sin((4.5-i)*TWO_PI/avSize*2)* hpCircl);
    hpYPos[i] = int(cos((4.5-i)*TWO_PI/avSize*2)* hpCircl);
    hpXPos[i+avSize/2] = int(sin((4.5-i)*TWO_PI/avSize*2)* hpCircl/ratio);
    hpYPos[i+avSize/2] = int(cos((4.5-i)*TWO_PI/avSize*2)* hpCircl/ratio);
  }
  
  /*
   //  Testing
   dclField("Hello",      0, 1, 0, 0, 0);
   dclField("World",      1, 1, 0, 4, 0);
   dclField("BPM",        2, 1, 0x1010, 2, 2);
   dclField("Main Vol.",  3, 1, 0x1123, 2, 6);
   valInt[1]=327;
   */

  flagRedraw = flagMod = true;
  flagShowConsole = false;
  flagShowVols = true;
  c1.set("C'est parti!");
} 


/*
  Indicate that a field is not used any more
 */
void rmvField(int num) {
  if (num <0 || num > fCount || (eUsed[num] == 0))
    return;
  eUsed[num] = 0;
  flagRedraw = true;
}

void dclField(String name, int num, int type, int forme, int xp, int yp) {
  if (num <0 || num > fCount)
    return;
  // Compute bounds
  int bsize = ((forme >> 8) & 0x3) + 2; // 
  int bpos = (forme >> 12) & 0x1;
  xLPos[num] = xVPos[num] = lMarg + xp * xFact;
  yLPos[num] = yVPos[num] = tMarg + yp * yFact;
  // bsize is a "box" factor indicating the width & height, typically 2, 3, 4 or 5
  wLPos[num] = wVPos[num] = bsize * xFact;
  if (((forme >> 10) & 0x1) != 0) wLPos[num] += xFact; // increase label size
  if (((forme >> 11) & 0x1) != 0) wVPos[num] += xFact; // increase value size
  hLPos[num] = hVPos[num] = bsize * yFact;
  // Now, the position of the value
  if (bpos == 0) 
    xVPos[num] = xVPos[num] + wLPos[num]; // value on the right
  else
    yVPos[num] = yVPos[num] + hLPos[num]; // value under
  eType[num] = type;
  bForm[num] = forme;
  vName[num] = name + "";
  fSize[num] = bsize;
  valInt[num] = 0;
  valFlt[num] = 0.0;
  valStr[num] = "--";
  eUsed[num] = 1;
  eMod[num] |= 3;
  flagMod = true;
  c1.set("Declared");
}



void setInt(int ent, int val) {
  if (ent < 0 || ent >= fCount || eUsed[ent]!=1)
    return;
  eMod[ent] |= 1;
  valInt[ent] = val;
  eType[ent] = 1; // int type
  flagMod = true;
}

void setFlt(int ent, float val) {
  if (ent < 0 || ent >= fCount || eUsed[ent]!=1)
    return;
  eMod[ent] |= 1;
  valFlt[ent] = val;
  eType[ent] = 2; // float type
  flagMod = true;
}

void setStr(int ent, String val) {
  if (ent < 0 || ent >= fCount || eUsed[ent]!=1)
    return;
  eMod[ent] |= 1;
  valStr[ent] = val+ "";
  eType[ent] = 3; // float type
  flagMod = true;
}

void oscEvent(OscMessage m) {
  String patt = m.addrPattern();
  String ttag = m.typetag();  

  // println(m.toString());
  int num;

  if (patt.equals("/chuck/ctl")) {
    // receive a variable value
    if (m.typetag().charAt(0)!='i')
      return;
    num = m.get(0).intValue();
    char x;
    x = m.typetag().charAt(1);
    if (x == 'i')
    {
      int val = m.get(1).intValue();
      setInt(num, val);
      // println(patt+ " " + num, " ", val);
    }
    if (x == 'f')
    {
      float flt = m.get(1).floatValue();
      setFlt(num, flt);
      // println(patt+ " " + num, " ", flt);
    }
    if (x == 's')
    {
      String str = m.get(1).stringValue();
      setStr(num, str);
      // println(patt+ " " + num, " ", str);
    }
    return;
  }

  if (patt.equals("/chuck/vol")) {

    String pvol = "    Vol";
    float flt;
    for (int i= 0; i<m.typetag().length() && i <avSize && m.typetag().charAt(i)=='f'; i++) {
      flt = m.get(i).floatValue();
      flt = abs(flt) + 0.60 * allVols[i];
      if (flt < 0.000001) flt = 0.0;
      allVols[i] = flt;
      pvol = pvol + "  " + flt;
    }
    c1.set(pvol);

    return;
  }

  if (patt.equals("/chuck/dcl")) {
    // receive a variable declaration
    // expect name, number, format, x, y
    if (ttag.equals("siiiii")) {
      String idt = m.get(0).stringValue();
      num = m.get(1).intValue();
      int typ = m.get(2).intValue();
      int fmt = m.get(3).intValue();
      int xpos = m.get(4).intValue();
      int ypos = m.get(5).intValue();
      println(" ==> " + patt + "  " + ttag + " " + idt + " " + num 
        + " " + typ + " " + fmt + " " + xpos + " " + ypos);
      dclField(idt, num, typ, fmt, xpos, ypos);
    }
    return;
  }

  if (patt.equals("/chuck/rmv")) {
    // remove a variable declaration
    // expect number
    if (ttag.equals("i")) {
      num = m.get(0).intValue();
      // println(" ==> " + patt + "  " + num);
      if (num == -1) {
        for (int i=0; i<fCount; i++)
          rmvField(i);
      } else {
        if (num >= 0 && num < fCount)
          rmvField(num);
      }
    }
    return;
  }


  if (patt.equals("/chuck/txt")) {
    // display a message on console
    // expect string
    if (ttag.equals("s")) {
      String str = m.get(0).stringValue();
      // println(" ==> " + patt + "  " + num);
      c1.set(str);
    }
    return;
  }


  if (patt.equals("/chuck/cmd")) {
    if (ttag.equals("i")) {
      num = m.get(0).intValue();
      switch (num) {
        default : flagRedraw = true; break;
        case 1 : flagShowConsole = true; flagRedraw = true; break;
        case 2 : flagShowConsole = false; flagRedraw = true; break;
      }
    }
  }
}



void willRedraw() {
  flagRedraw = false;
  background(0);
  textFont(f2);
  setColor(9);
  text("Cordes & Sons", 10, 10);
  for (int f=0; f<fCount; f++) {
    eMod[f] |= 3;
  }
  flagMod = true;
  prvHeight = height;
  prvWidth = width;
  setConsolePos();
}






void draw() {
  int x1, y1, x2, y2;
  colorMode(RGB, 255, 255, 255);
  textAlign(LEFT, TOP);
  // translate(2, fsDec);

  if (height != prvHeight || width != prvWidth) {
    flagRedraw = true;
  }

  if (flagRedraw) {
    willRedraw();
  }

  if (flagMod) {
    flagMod = false;
    for (int f=0; f<fCount; f++) {

      if (eMod[f] != 0 && eUsed[f] != 0) {

        switch(fSize[f]) {
        case 3 : 
          textFont(f1); 
          break;
        case 4 : 
          textFont(f2); 
          break;
        case 5 : 
          textFont(f3); 
          break;
        default : 
          textFont(f0);
        }
        // stroke(46);
        if (bxColor != 0) {
          stroke(bxColor); // Box color
          fill(bgColor);
          // Compute bounding box
          x1 = min(xLPos[f], xVPos[f]) - dx;
          y1 = min(yLPos[f], yVPos[f]) - dy;
          x2 = max(xLPos[f], xVPos[f]) - 2 - dx;
          y2 = max(yLPos[f], yVPos[f]) - 2 - dy;
          noFill();
          int w = x2-x1 + wLPos[f]; 
          int h = y2-y1 + hLPos[f];
          rect(x1, y1, x2-x1 + wLPos[f], y2-y1 + hLPos[f]);  // draw the box around
          // String text = "Box " + x1 + " " + y1 + " " + w + " " + h;
          // c1.set(text);
          // println(text);
        }

        if ((eMod[f] & 2) != 0) {
          // display the name
          // textAlign(LEFT, TOP);
          noStroke(); 
          fill(bgColor);
          rect(xLPos[f], yLPos[f], wLPos[f]-4-dx, hLPos[f]-4-dy);
          setColor(bForm[f]);
          text(vName[f], xLPos[f], yLPos[f]);
          eMod[f] = eMod[f] & (0xfd);
        }

        if ((eMod[f] & 1) != 0) {
          // display the value
          // textAlign(LEFT, TOP);
          noStroke(); 
          fill(bgColor);
          rect(xVPos[f], yVPos[f], wVPos[f]-4-dx, hVPos[f]-4-dy);
          setColor(bForm[f] >> 4);
          if (eType[f] == 1) {
            text(valInt[f], xVPos[f], yVPos[f]);
          }
          if (eType[f] == 2) {
            text(valFlt[f], xVPos[f], yVPos[f]);
          }
          if (eType[f] == 3) {
            text(valStr[f], xVPos[f], yVPos[f]);
          }
          eMod[f] = eMod[f] & (0xfe);
        }
        //
      }
    }
  }

  if (flagShowConsole) {
    /* Redraw the console */
    smooth();
    textFont(typo);
    fill(bgColor);
    rect(xCsl, yCsl, wCsl, hCsl);
    fill(240, 240, 220); // text color
    text(c1.get(), xCsl, yCsl, wCsl, hCsl);
  }
  
  if (flagShowVols) {
    int rad = 28;
    float xP = 1400;
    float yP = 220;
    float rE = hpCircl + rad + 2;
  ellipseMode(RADIUS);
     fill(0);
     ellipse(xP, yP, rE, rE);
    colorMode(HSB, 1.0, 1.0, 1.0);
    noStroke();
 
    for (int i= 0; i<8; i++) {
      // Output : red = 1.0
      drawGradient(hpXPos[i]+xP, hpYPos[i]+yP, sqrt(allVols[i]) * 3, 1.0, rad);
    }
    for (int i= 8; i<16; i++) {
      // green = 0.333
      // Input : blue
      drawGradient(hpXPos[i]+xP, hpYPos[i]+yP, sqrt(allVols[i]) * 3, 0.666, rad);
    }
     // println("Pos " + (hpXPos[3]+500) + " " + (hpYPos[3]+500) + " " + allVols[3] );
    }
}


void drawGradient(float x, float y, float z, float col, int rd) {
  int radius = rd;
  // float h = 1; // rouge
  // h = 0.33;
  float s;
  for (int r = radius; r > 0; --r) {
    s = float(r)/rd;
    fill(col, s, (1.0-s)*z);
    ellipse(x, y, r, r);
  }
}