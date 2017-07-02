/*
   A public global class for all remanent objects that
   deserve to be known by everybody...
   
   Jean-Jacques Girardot - May/June 2017

License : WTFPL
http://www.wtfpl.net



*/

public class GL {
    static int Asig; // application signature
   static Gain @ GGains[];
   static float Pot[]; // All pots
   static int Btn[]; // 64 buttons
   static int Knkt[]; // 64 konnectors
   // Various Units
   static int UChans[]; // associated midi channels
   static int UTrans[]; // transposition [MIDI num]
   static int Runs[]; // refs. to running tasks
   static int CRuf[]; // contôl of running tasks
   // Globalized "Shift" and "Control"
   static int ShiftF; //nK2 "shift"
   static int CtlF;  // nK2 "ctl" 
   // Informations from the FCB 1010
   static int cPreset; // current preset [0-99]
   static float pedA;  // pedal A value [0-1]
   static float pedB;  // pedal B value [0-1]
   // Global trace flags
   static int t0, t1, t2, t3, t4, t5, t6, t7, t8, t9;
   static int signalActivity;
   // Devices specific traces
   //
   // For the FCB 1010
   static int tFCB;
   // For the Korg MS 20
   static int tms20, signalJK, signalKN;
   // For the QuNexus
   static int tQNx, tnK2, tnP2, tAbs;
   // For the Arturia BeatStep
   static int AB_aTrace, AB_eTrace, AB_sendSync, AB_sendNotes;
   // For the Tick Sequencer
   static int tTSeq;
   // For the VSynth Player
   static int tVSP;
   // For the Rhodey Player
   static int tRhP;
   // For the Tick Player
   static int tTPly;
}

// Global indicators
1 => GL.signalActivity; // print some info every minute
0 => GL.ShiftF => GL.CtlF; // shift & command keys
// For effects connectivity
new Gain [96] @=> GL.GGains;
// We manage some potentiometers
288 => int PotNB;
new float [PotNB] @=> GL.Pot;
// MS20 connectivity pannel
64 => int BtnNB;
new int [BtnNB] @=> GL.Btn;
new int [BtnNB] @=> GL.Knkt;
new int [BtnNB] @=> GL.UChans;
new int [BtnNB] @=> GL.UTrans;
// Unimplemented : track running tasks
512 => int RunsNB;
new int [RunsNB] @=> GL.Runs;
new int [RunsNB] @=> GL.CRuf;

for (0 => int i; i<PotNB; i++) {
    0.0 => GL.Pot[i];
}

for (0 => int i; i<BtnNB; i++) {
    0 => GL.Btn[i];
    -1 => GL.Knkt[i];
    -1 => GL.UChans[i];
    0 => GL.UTrans[i];
}

for (0 => int i; i<RunsNB; i++) {
    0 => GL.Runs[i];
    0 => GL.CRuf[i];
}


// Associate some default MIDI channels to some units
0 => GL.UChans[0];
1 => GL.UChans[5];
2 => GL.UChans[9];
3 => GL.UChans[13];
4 => GL.UChans[17];
5 => GL.UChans[21];
6 => GL.UChans[1];
7 => GL.UChans[6];
8 => GL.UChans[10];

//===================================
// Make sure to loop...
// This keeps Gains objects and their connection to dac
<<< "Global data", "inited." >>>;

1 => GL.Asig; // Globals OK
while (true) {
    hour => now;
}



