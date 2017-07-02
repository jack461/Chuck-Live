/*

     Various tests

Jean-Jacques Girardot - June 2017

License : WTFPL
http://www.wtfpl.net


*/

/*

// Some live expressions to choose from...

0 => GL.tFCB;
0 => BM.trace; 

// ===================
0.0 => SOUND.nexGain;

0.4 => SOUND.nexGain; // This will be squared !

// Or even :
for (0 => int i; i<8; i++) {
    0.1 => SOUND.SKG[i].gain;
}

Machine.add(me.dir() + "Progs/SOUND.Volume.ck");

// ====================
<<< "In", adc.channels() >>>;
<<< "Out", dac.channels() >>>;


1 => BM.trace;  // trace beat

25 => BM.newBPM;
10::second => now;

BM.sync(2);
<<< "Synchro on beat", 2 >>>; 

BM.sync(1);
<<< "Synchro on beat", 1 >>>; 

30 => BM.newBPM;



0 => BM.trace;  // trace beat
10::second => now;
90 => BM.newBPM;

UT.xtr("test de message");


SOUND.recordStart(2);// start stereo recording

SOUND.recordStop();



// Test sound through SOUND manager
SinOsc s => SOUND.SKG[0]; s => SOUND.SKG[1];
440 => s.freq;
SOUND.gain(0.5);
20::second => now;
s !=> SOUND.SKG[0]; s !=> SOUND.SKG[1];
5::second => now;



// Test sound direct
SinOsc s => dac.chan(0); s => dac.chan(1);
440 => s.freq; 0.05 => s.gain;
10::second => now;
s !=> dac.chan(0); s !=> dac.chan(1);
5::second => now;




0.5 => SOUND.SGI[0].gain;
0.5 => SOUND.SGI[1].gain;
SOUND.SGI[0] !=> SOUND.SKG[0];
SOUND.SGI[1] !=> SOUND.SKG[1];


*/

/*

SOUND.recordStart(2);// start stereo recording


// Test sound through SOUND manager
SinOsc s => SOUND.SKG[0]; s => SOUND.SKG[1];
440 => s.freq;
SOUND.gain(0.5);
10::second => now;
SOUND.gain(0.0);
10::second => now;
s !=> SOUND.SKG[0]; s !=> SOUND.SKG[1];
5::second => now;



SOUND.recordStop();



1 => GL.AB_sendSync;

0 => GL.AB_sendSync;

4 => GL.AB_eTrace;

0 => GL.AB_sendNotes; // set to send sequencer notes

1 => GL.tFCB;

0 => GL.tFCB;


*/


1 => GL.tms20;
5 => GL.tVSP;


// Need at least on expression to make ChucK happy...
<<< "Done.", me.id() >>>;

