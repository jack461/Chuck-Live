/*


Live SET FX Manager

Use 8 inputs and 8 outputs

Jean-Jacques Girardot - May/June 2017

License : WTFPL
http://www.wtfpl.net




*/

// This is the Jack to use on the MS-20 
// to activate the code
23 => int UnitSwitch;
// ==================


// Various Options
1 => int useSOUND_MGR;
28 => int ModVolume; // Addt. modulation volume
5 => int GroupNumber;
-1 => int KeybUnitNumber;
27 => int ModGain; // input gain


0 => int doWork;
0 => int konnected;
0 => float OutGain;
0 => float InGain;

0 => int currPreset;
0 => int currAlgo;
0 => int processing;
3.5 => float gF;



me.id() => int me_id;
"FX MGR:" + me_id => string ModuleIdt;

int InputsUsed[];
0 => int testMode;
if (testMode) {
    // test mode : use analog ins for 0 to 3
//    [8,9,10,11,0,1,2,3,4,5,6,7]
//  [6,7, 8,9,10,11,0,1,2,3,4,5]
[4,5,6,7,8,9,10,11,0,1,2,3]
     @=> InputsUsed;
}
else
{
    // Std Mode : use first 8 inputs
    [0,1,2,3,4,5,6,7,8,9,10,11] @=> InputsUsed;
}


// Use multiple Gains
// Remember the default gain value is 1 !

0 => int O;
// Declare the specific ins and outs
O+0 => int Out0;
O+1 => int Out1;
O+2 => int Out2;
O+3 => int Out3;
O+4 => int Out4;
O+5 => int Out5;
O+6 => int Out6;
O+7 => int Out7;
//
8 => int I; 
I+0 => int In0;
I+1 => int In1;
I+2 => int In2;
I+3 => int In3;
I+4 => int In4;
I+5 => int In5;
I+6 => int In6;
I+7 => int In7;
//
I+8 => int In8;
I+9 => int In9;
I+10 => int InA;
I+11 => int InB;
I+12 => int InC;
I+13 => int InD;
I+14 => int InE;
I+15 => int InF;
//
24 => int W;
W => int FirstFree;
int perms[]; // channels permutations


// ===================
// Echo Box 1
//  [Echo1In]  =>  hpf  => echo  => [Echo1Out]

30 => float MaxDelay1;
Echo ech1;
HPF hpf1;
hpf1.freq(60);
hpf1.Q(0.8);
ech1.max(MaxDelay1::second);
ech1.delay(5::second);
ech1.mix(0.4);
FirstFree => int Echo1In;
FirstFree +1 => int Echo1Out;
// Read in 17, out in 18
GL.GGains[Echo1In] => hpf1 => ech1 => GL.GGains[Echo1Out];
ech1.gain(0.9);
ech1 => hpf1;
FirstFree + 2 => FirstFree; // uses 2 entries


// ===================
// Echo Box 2
//  [Echo2In]  =>  hpf  => echo  => [Echo2Out]

30 => float MaxDelay2;
Echo ech2;
HPF hpf2;
hpf2.freq(60);
hpf2.Q(0.8);
ech2.max(MaxDelay2::second);
ech2.delay(5::second);
ech2.mix(0.4);
FirstFree => int Echo2In;
FirstFree +1 => int Echo2Out;
// Read in x, out in x+1
GL.GGains[Echo2In] => hpf2 => ech2 => GL.GGains[Echo2Out];
ech2.gain(0.9);
ech2 => hpf2;
FirstFree + 2 => FirstFree; // uses 2 entries


// ===================
// Echo Box 3
//  [Echo3In]  =>  hpf  => echo  => [Echo3Out]

30 => float MaxDelay3;
Echo ech3;
HPF hpf3;
hpf3.freq(60);
hpf3.Q(0.8);
ech3.max(MaxDelay3::second);
ech3.delay(5::second);
ech3.mix(0.4);
FirstFree => int Echo3In;
FirstFree +1 => int Echo3Out;
// Read in x, out in x+1
GL.GGains[Echo3In] => hpf3 => ech3 => GL.GGains[Echo3Out];
ech3.gain(0.9);
ech3 => hpf3;
FirstFree + 2 => FirstFree; // uses 2 entries


// ===================
// Echo Box 4
//  [Echo4In]  =>  hpf  => echo  => [Echo4Out]

30 => float MaxDelay4;
Echo ech4;
HPF hpf4;
hpf4.freq(60);
hpf4.Q(0.8);
ech4.max(MaxDelay4::second);
ech4.delay(5::second);
ech4.mix(0.4);
FirstFree => int Echo4In;
FirstFree +1 => int Echo4Out;
// Read in x, out in x+1
GL.GGains[Echo4In] => hpf4 => ech4 => GL.GGains[Echo4Out];
ech4.gain(0.9);
ech4 => hpf4;
FirstFree + 2 => FirstFree; // uses 2 entries


// ===================
// Delay Box 1
//  [Dly1In]  =>  delay  => rev1  => [Dly1Out]

10 => float MxDely1;
Delay dly1;
NRev rev1;
dly1.max(MxDely1::second);
dly1.delay(5::second);
rev1.mix(0.1);
FirstFree => int Dly1In;
FirstFree +1 => int Dly1Out;
GL.GGains[Dly1In] => dly1 => rev1 => GL.GGains[Dly1Out];
dly1.gain(0.9);
FirstFree + 2 => FirstFree; // uses 2 entries


// ===================
// Delay Box 2
//  [Dly2In]  =>  delay  => rev2  => [Dly2Out]

10 => float MxDely2;
Delay dly2;
NRev rev2;
dly2.max(MxDely2::second);
dly2.delay(5::second);
rev2.mix(0.1);
FirstFree => int Dly2In;
FirstFree +1 => int Dly2Out;
GL.GGains[Dly2In] => dly2 => rev2 => GL.GGains[Dly2Out];
dly2.gain(0.9);
FirstFree + 2 => FirstFree; // uses 2 entries


// ===================
// Panned output 1
//  [P8_1In,.] => pan8 => [0,1,2,3,4,5,6,7]
Pan8 p8_1;
FirstFree => int P8_1In; // 2 ins, 
FirstFree+2 => int P8_1Out; // 8 outs
GL.GGains[P8_1In] => p8_1; // Input 
GL.GGains[P8_1In+1] => p8_1; //  
[0,1,7,2,6,3,5,4] @=> perms;
for (0 => int k; k<8; k++)
{
    p8_1.chan(k) => GL.GGains[P8_1Out+perms[k]]; // 
}
FirstFree + 10 => FirstFree; // uses 10 entries


// ===================
// Panned output 2
//  [P8_2In,.] => pan8 => [1,0,7,6,5,4,3,2]
Pan8 p8_2;
FirstFree => int P8_2In; // 2 ins, 
FirstFree+2 => int P8_2Out; // 8 outs
GL.GGains[P8_2In] => p8_2; // Input are 
GL.GGains[P8_2In+1] => p8_2; // 18 and 19 
[1,0,7,6,5,4,3,2] @=> perms;
for (0 => int k; k<8; k++)
{
    p8_2.chan(k) => GL.GGains[P8_2Out+perms[k]]; // 
}
FirstFree + 10 => FirstFree; // uses 10 entries


// ===================
// Panned output 3
//  [P8_3In,.] => pan8 => [0,3,6,1,4,7,2,5]
Pan8 p8_3;
FirstFree => int P8_3In; // 2 ins, 
FirstFree+2 => int P8_3Out; // 8 outs
GL.GGains[P8_3In] => p8_3; // Input are 
GL.GGains[P8_3In+1] => p8_3; // 18 and 19 
[0,3,1,7,5,2,4,6] @=> perms;
for (0 => int k; k<8; k++)
{
    p8_3.chan(k) => GL.GGains[P8_3Out+perms[k]]; // 
}
FirstFree + 10 => FirstFree; // uses 10 entries


// ===================
// Panned output 4
//  [P8_4In,.] => pan8 => [1,6,3,0,5,2,7,4]
Pan8 p8_4;
FirstFree => int P8_4In; // 2 ins, 
FirstFree+2 => int P8_4Out; // 8 outs
GL.GGains[P8_4In] => p8_4; // Input 
GL.GGains[P8_4In+1] => p8_4; // 18 
[1,6,3,0,5,2,7,4] @=> perms;
for (0 => int k; k<8; k++)
{
    p8_3.chan(k) => GL.GGains[P8_3Out+perms[k]]; // 
}
FirstFree + 10 => FirstFree; // uses 10 entries



// Various little things
// 
HPF hpfX;
hpfX.freq(90);
hpfX.Q(0.6);
hpfX.gain(1.1);
FirstFree => int hpfXIn; 
FirstFree+1 => int hpfXOut; 
GL.GGains[hpfXIn] => hpfX => GL.GGains[hpfXOut];
FirstFree + 2 => FirstFree; // uses 2 entries
 



Phasor pha1, pha2, pha3;
pha1 => blackhole;
pha2 => blackhole;
pha3 => blackhole;
SinOsc lfo1 => blackhole;
0.02 => lfo1.freq;
SinOsc lfo2 => blackhole;
0.02 => lfo2.freq;
1 => float tremVal;


// ***********************************************
// Communication management
64 => int sizA;
56 => int firstpV;
int MngCtls[sizA];
int sndNbrss[sizA];
float prvCtVals[sizA];
0 => int ptCt;
// send values of controls used by a specific preset
fun void sendModed() {
    for (0 => int i; i<MngCtls.cap() && MngCtls[i] >= 0; i++) {
        MngCtls[i] => int b;
        if (b>=0 && b<GL.Pot.cap() && GL.Pot[b]!=prvCtVals[i]) {
            GL.Pot[b] => float v;
            UT.xVal(sndNbrss[i], v);
            v => prvCtVals[i];
        }
    }
}
fun void using(int ctl, int vNum, string idt) {
    // Declare to processing that we are using a specific Pot for a variable
    if ((ptCt >= sizA-1) || (vNum < 0) || (vNum >= sizA))
        return;
    4 => int xC; 16 => int yC;
    ctl => MngCtls[ptCt] ; // we are using this value
    -1 => MngCtls[ptCt+1] ; // limit
    vNum + firstpV => sndNbrss[ptCt]; // The displayed variable
    // Now, declare it
    UT.xDcl(idt, vNum + firstpV, 2, UT.FXcolor, xC+4*(vNum % 4), yC+2*(vNum / 4));
    ptCt++;
}

fun void unuseall() {
    for (0 => int i; i<sizA; i++) {
        UT.UnDclVars(firstpV+i);
        -1 => MngCtls[i];
    }
    0 => ptCt;
}
unuseall();

// ###############################################
// ###############################################

// 1) The KonneKtion Matrice

// Definition of KonneKtions matrices
[   // a KonneKtion set is list of couples x and y, meaning G[x] => G[y], followed by a -1 marker
/*  0 */   [-1],
/*  1 */   [In0, Out0,   In1, Out1,  -1], // konnect 0 => 0, 1 => 1
//         Connects the 8 inputs to the 8 outputs
/*  2 */   [In0, Out0,   In1, Out1,   In2, Out2,   In3, Out3,   In4, Out4,   In5, Out5,   In6, Out6,   In7, Out7, -1],  
//         Connect direct 1&2 to Out 1&2, 1 to echo, echo to Out 4&5 
/*  3 */   [In0, Out0,   In1, Out1,   In0, Echo1In,   Echo1Out, Out4,   Echo1Out, Out5,  -1],
//   Connect in 1 & 2 to the 8Panner 1, input
/*  4 */   [In0, P8_1In,   In1, P8_1In+1],
/*  5 */   [P8_1Out, Out0, P8_1Out+1, Out1, P8_1Out+2, Out2, P8_1Out+3, Out3,
           P8_1Out+4, Out4, P8_1Out+5, Out5, P8_1Out+6, Out6, P8_1Out+7, Out7, -1],
/*  6 */   [P8_2Out, Out0, P8_2Out+1, Out1, P8_2Out+2, Out2, P8_2Out+3, Out3,
           P8_2Out+4, Out4, P8_2Out+5, Out5, P8_2Out+6, Out6, P8_2Out+7, Out7, -1],
/*  7 */   [P8_3Out, Out0, P8_3Out+1, Out1, P8_3Out+2, Out2, P8_3Out+3, Out3,
           P8_3Out+4, Out4, P8_3Out+5, Out5, P8_3Out+6, Out6, P8_3Out+7, Out7, -1],
/*  8 */   [P8_4Out, Out0, P8_4Out+1, Out1, P8_4Out+2, Out2, P8_4Out+3, Out3,
           P8_4Out+4, Out4, P8_4Out+5, Out5, P8_4Out+6, Out6, P8_4Out+7, Out7, -1],
/*  9 */   [In0, Echo1In, In1, Echo1In, Echo1Out, Out0, Echo1Out, Out1],
/* 10 */   [In0, Dly1In, In1, Dly1In, In4, Dly1In, Dly1Out, Out0, Dly1Out, Out1,
            Dly1Out, Out2, Dly1Out, Out3, Dly1Out, Out4, Dly1Out, Out5,
            Dly1Out, Out6, Dly1Out, Out7],
/* 11 */   [In0, Echo1In, In1, Echo1In, In4, Echo1In, Echo1Out, Out0, Echo1Out, Out1,
            Echo1Out, Out2, Echo1Out, Out3, Echo1Out, Out4, Echo1Out, Out5,
            Echo1Out, Out6, Echo1Out, Out7],
// In0, In1 and In4 in two different delays with a reverb first ; 
/* 12 */   [In0, Dly1In, In1, Dly2In,
            In4, hpfXIn, hpfXOut, Dly1In, hpfXOut, Dly2In, 
            Dly1Out, Out0, Dly2Out, Out1,
            Dly1Out, Out2, Dly2Out, Out3, Dly1Out, Out4, Dly2Out, Out5,
            Dly1Out, Out6, Dly2Out, Out7],
/* 13 */   [In0, P8_1In, In1, P8_1In+1, In2, P8_2In, In3, P8_2In+1, In4, P8_3In],

// ==========
/*  ? */   [-1] // last one
]   @=> int KMat[][];


// Definition of preset konnektion
[  // the KonneKtions for a preset are a LIST of KonneKtions matrices ended by -1
//    Each value is an entry number in the KMat list
/*  0 */   [-1],  // Nothing to do
/*  1 */   [2, -1], // direct 1-8 => 1-8
/*  2 */   [1, -1], // xtest 
/*  3 */   [3, -1], // just 3
/*  4 */   [4,5,-1], // Connect in 1&2 to Pan8 1&1, and P8_1 Outs to Std Outs 
/*  5 */   [9,-1],
/*  6 */   [10,-1],
/*  7 */   [11,-1],
/*  8 */   [12,-1],
/*  9 */   [13,5,6,7,-1],
// ==========
/*  ? */   [-1]//  Last one
]   @=> int KList[][];



// This builds only internal konnections
fun void setKonnections(int nb) {
    <<< "   =* setKonnections", nb >>>;
    // Is this necessary ?
    if (nb < 0 || nb >= KList.cap() || nb == currAlgo) { 
        return;
    }
    int KL[];
    int XXL[];
    // First, perform all unKonneKtions
    KList[currAlgo] @=> XXL;
    for (0 => int k; k<XXL.cap() && XXL[k]>=0; k++) {
        XXL[k] => int w; // We expect no error here
        KMat[w] @=> KL;
        // do disconnect what is connected
        for (0 => int i; i<KL.cap() && KL[i] >= 0; i+2 => i) {
            GL.GGains[KL[i]] !=> GL.GGains[KL[i+1]];
            <<< "          ", ModuleIdt, "disconnect", KL[i], "from", KL[i+1] >>>;
        }
    }
    // Then, perform all KonneKtions
    nb => currAlgo;
    KList[currAlgo] @=> XXL;
    for (0 => int k; k<XXL.cap() && XXL[k]>=0; k++) {
        XXL[k] => int w;
        KMat[w] @=> KL;
        // do connect what is to be konnected
        for (0 => int i; i<KL.cap() && KL[i] >= 0; i+2 => i) {
            GL.GGains[KL[i]] => GL.GGains[KL[i+1]];
            <<< "          ", ModuleIdt, "connect", KL[i], "=>", KL[i+1] >>>;
        }
    }
}

// ==========================================
// ==========================================

// 2) The initializations

//  Definition of initializations to do
[   // a list of action numbers, terminated by -1
/*  0 */   [0, -1], // sets all outputs to zero
/*  1 */   [1, -1], // sets all outputs to 1
/*  2 */   [1,2, -1], // sets all outputs to 1, more gain for bass
/*  3 */   [1,2,3,5,-1], // sets all outputs to 1, more gain for bass, set names
/*  4 */   [1,2,3,6,-1], // sets all outputs to 1, more gain for bass, set names
// ===========
/*  ? */   [-1] // last
]   @=> int listOfInits[][];


fun void doInitializations(int nb) {
    <<< "   =* doInitializations", nb >>>;
    if (nb < 0 || nb >= listOfInits.cap()) { 
        return;
    }
    listOfInits[nb] @=> int IL[];
    int act;
    for (0 => int i; IL[i] >= 0; i++) {
        IL[i] => act;
        <<< "          ", ModuleIdt, "performing", IL[i]>>>;
        if (act == 0) {
            // Reset all out gains
            for (0 => int i; i<8; i++) {
                0 => GL.GGains[i+O].gain;
            }
            continue;
        } 
        if (act == 1) {
            // Set out gains to 1
            for (0 => int i; i<8; i++) {
                1 => GL.GGains[i+O].gain;
            }
            continue;
        }
        if (act == 2) {
            // Set more gain for bass
            2 => GL.GGains[In4].gain;
            continue;
        }
        if (act == 3) {
            // Set specific delays values
            dly1.delay(910::ms);
            dly2.delay(340::ms);
            continue;
        }
        if (act == 4) {
            // Reset Pan 8 input gains to 1
            1.0 => GL.GGains[P8_1In].gain;
            1.0 => GL.GGains[P8_1In+1].gain;
            1.0 => GL.GGains[P8_2In].gain;
            1.0 => GL.GGains[P8_2In+1].gain;
            1.0 => GL.GGains[P8_3In].gain;
            1.0 => GL.GGains[P8_3In+1].gain;
            1.0 => GL.GGains[P8_4In].gain;
            1.0 => GL.GGains[P8_4In+1].gain;
            continue;
        }
        if (act == 5) {
            <<< "\ndeclaring variables" + "\n" >>>;
            using(ModGain, 0, "Inp.Vol");
            using(ModVolume, 4, "Out.Vol");
            using(16, 1, "dly1.Vol");
            using(17, 5, "dly2.Vol");
            using(18, 2, "rev1.Mix");
            using(19, 6, "rev2.Mix");
            continue;
        }
        if (act == 6) {
            <<< "\ndeclaring variables" + "\n" >>>;
            using(ModGain, 0, "Inp.Vol");
            using(ModVolume, 4, "Out.Vol");
            using(16, 1, "pan1.Vol");
            using(17, 5, "pan1.Phaz");
            using(18, 2, "pan2.Vol");
            using(19, 6, "pan2.Phaz");
            using(20, 3, "pan3.Vol");
            using(21, 7, "pan3.Phaz");
            continue;
        }
    }
}


// ==========================================
// ==========================================

// 3) The run Time

// The runtime operations
[  // list of actions, terminated by -1
/*   0 */ [-1], // nothing to do
/*   1 */ [0,-1], // Set all output gains to gF * OutGain
/*   2 */ [2,-1], // Use potentiometers for volume 
/*   3 */ [1,2,-1], // Apply a tremolo 
/*   4 */ [0,3,-1], // Apply the Panner
/*   5 */ [5,-1], // test xxx
/*   6 */ [6,-1], // test xxx
/*   7 */ [7,0,10,-1], // test xxx
/*   8 */ [8,0,-1],
/*   9 */ [9,0,10,-1],
// =========
/* -- */ [-1]//// last
]  @=> int listOfRunTimes[][];
listOfRunTimes[0] @=> int runTimes[];
0 => int XRuntime;

fun void doRuntimes() {
    int act;
    // First, reset somes values
    1 => tremVal;
    for (0 => int anb; (runTimes[anb] => act) >= 0; anb++) {
        if (act == 0) {
            // <<< ">", act >>>;
            for (0 => int i; i<8; i++) {
                gF * OutGain => GL.GGains[i+O].gain;
            }
            continue;
        }
        if (act == 1) {
            // <<< ">", act >>>;
            // apply a tremolo to the gain;
            // Pot 21 = frequency in 0 => 10 Hz
            GL.Pot[21] * 10 => lfo1.freq;
            // Pot 20 = amplitude
            (lfo1.last() + 1) / 2 => tremVal;
            1 - tremVal * GL.Pot[20] => tremVal;
            tremVal * tremVal => tremVal;
            continue;
        }
        if (act == 2) {
            // <<< ">", act >>>;
            // Use 8 pots for now for inputs 0 to 8
            // gF * OutGain * tremVal => float GMult;
            gF * OutGain => float GMult;
            GL.Pot[16] * GMult => GL.GGains[O+0].gain;
            GL.Pot[17] * GMult => GL.GGains[O+1].gain;
            GL.Pot[16] * GMult => GL.GGains[O+2].gain;
            GL.Pot[17] * GMult => GL.GGains[O+3].gain;
            GL.Pot[16] * GMult => GL.GGains[O+4].gain;
            GL.Pot[17] * GMult => GL.GGains[O+5].gain;
            GL.Pot[16] * GMult => GL.GGains[O+6].gain;
            GL.Pot[17] * GMult => GL.GGains[O+7].gain;
            continue;
        }
        if (act == 3) {
            // <<< ">", act >>>;
            // Move manually around the scenary, using Pan 8
            GL.Pot[18] * 8 => p8_1.pan;
            continue;
        }
        if (act == 4) {
            // <<< ">", act >>>;
            // Move around the scenary, using Pan 8
            GL.Pot[20] * 8 => lfo2.freq; // 0 to 8 Hz
            (lfo2.last() + 1) * 4 => p8_1.pan;
            continue;
        }
        if (act == 5) {
            // Manage echo/gain for input 1-2
            GL.Pot[192] => ech1.gain; //
            (0.05 + GL.Pot[208] * 10)::second => ech1.delay; //
            GL.Pot[193] => ech1.mix; //
            continue;
        }
        if (act == 6) {
            // Manage delay/gain for input 1-2 / 7
            GL.Pot[194] => dly1.gain; //
            (0.1 + GL.Pot[210] * 15)::second => dly1.delay; //
            // GL.Pot[193] => ech1.mix; //
            continue;
        }
        if (act == 7) {
            // Manage delay/gain for input 1-2 / 7
            GL.Pot[16] => dly1.gain; //
            GL.Pot[17] => dly2.gain; //
            GL.Pot[18] => rev1.mix; //
            GL.Pot[19] => rev2.mix; //
            continue;
        }
        if (act == 8) {
            // Double pan
            GL.Pot[20] * 8 => p8_1.pan; //
            GL.Pot[21] * 8 => p8_2.pan; //
            continue;
        }
        if (act == 9) {
            0.001 => float mval;
            1.8 => float mfact;
            // Triple pan each with volume & panoramique
            GL.Pot[16] * 1.5 => GL.GGains[P8_1In].gain => GL.GGains[P8_1In+1].gain;
            GL.Pot[17] * GL.Pot[17] * mfact + mval => pha1.freq;
            GL.Pot[18] * 1.5 => GL.GGains[P8_2In].gain => GL.GGains[P8_2In+1].gain;
            GL.Pot[19] * GL.Pot[19] * mfact + mval => pha2.freq;
            GL.Pot[20] * 1.5 => GL.GGains[P8_3In].gain => GL.GGains[P8_3In+1].gain;
            GL.Pot[21] * GL.Pot[21] * mfact + mval => pha3.freq;
            1 => processing; //
            continue;
        }
        if (act == 10) {
            sendModed();
            continue;
        }
        <<< "->?", anb >>>;
    }
}


// ==========================================
// ==========================================

// ))) Managing Presets

// The set of presets
[   // A preset is : (konnection set number) (initializations) (run-time set)
/*  1 */ [0,0,0], // All is deconnected
/*  2 */ [1,1,0], // In [8] to OUt [8]
/*  3 */ [5,1,5], // In 1_2 in echo and 
/*  4 */ [7,2,5], // In 1_2 in echo and 
/*  5 */ [8,3,7], // Pour Kimonos 
/*  6 */ [9,2,8], // Pour Nokomis
/*  7 */ [9,4,9], // Pour Nokomis
/*  8 */ [3,1,1], // Test echo
/*  9 */ [3,1,3], // Test echo && tremolo
/* 10 */ [4,1,4], // Test panner
/* 11 */ [0,0,0], // All is deconnected
/* 12 */ [2,1,1], // Test X
// =========
/*  ? */ [0,0,0]  // Last one
]   @=> int setOfPresets[][];

// revoir gestion de currPreset / GL.cPreset
fun void setPreset(int newpr)
{
    <<< "*=* Switching to preset", newpr >>>;
    // Since we must be able to "unSet" a preset, we can't pretend
    // to switch to an unknown one. So we CHANGE to a null preset...
    if (newpr < 0 || newpr >= setOfPresets.cap()) {
        0 => newpr => GL.cPreset;
    }
    newpr => currPreset;
    unuseall(); // broke all var. konnections
    setKonnections(setOfPresets[newpr][0]);
    doInitializations(setOfPresets[newpr][1]);
    setOfPresets[newpr][2] => XRuntime;
    0 => processing;
    if (XRuntime < 0 || XRuntime >= listOfRunTimes.cap()) 0 => XRuntime;
    listOfRunTimes[XRuntime] @=> runTimes;
    <<< "       *", ModuleIdt, "preset", newpr, "[", setOfPresets[newpr][0],
    setOfPresets[newpr][1], setOfPresets[newpr][2], "]" >>>;
}

// ###############################################
// ###############################################


float u;
// Give info every minute or so
now => time infoDate;

/*
  Fast Real-time process of some operations
  */
fun void RTProcess() {
    while (true) {
        if (processing) {
            pha1.last() * 8 => p8_1.pan; //
            pha2.last() * 8 => p8_2.pan;
            pha3.last() * 8 => p8_3.pan;
            1::ms => now;
        }
        else
        {
            200::ms => now;
        }
    }
}

spork ~ RTProcess();

GL.Asig | 0x100000 => GL.Asig; // FX Live Manager OK

while (true)
{
    if (doWork) {
        if (GL.Btn[UnitSwitch] == 0) {
            0 => doWork; // Stop sooner or later
        }
        if (currPreset != GL.cPreset) 
            setPreset(GL.cPreset);
        GL.Pot[GroupNumber] * GL.Pot[ModVolume] => OutGain;
        // Manage run-time ops
        doRuntimes();
        // Manage echo length
        (GL.Pot[31] * MaxDelay1) :: second => ech1.delay;
        // Manage echo length
        (GL.Pot[31] * MaxDelay2) :: second => ech2.delay;
        // Manage global input gains
        GL.Pot[ModGain] => InGain;
        for (0 => int i; i<SOUND.inpCount; i++) {
            InGain => GL.GGains[I+i].gain;
        }
        // <<< GL.Pot[15], GL.Pot[16], GL.Pot[17], GL.GGains[0].gain() >>>;
        25::ms => now;
    }
    else
    {
        500::ms => now;
        if (GL.Btn[UnitSwitch] != 0) {
            if (konnected == 0) {
                // we are on ! konnect to the output
                <<< ModuleIdt, ":", "connecting outputs." >>>;
                for (0 => int i; i<SOUND.inpCount; i++) {
                    1 => GL.GGains[i+I].gain;
                    SOUND.SGI[InputsUsed[i]] => GL.GGains[i+I];
                }
                for (0 => int i; i<SOUND.outCount; i++) {
                    1 => GL.GGains[i+O].gain;
                    GL.GGains[i+O] => SOUND.SKG[i];
                }
                1 => konnected;
                setPreset(1);
            }
            1 => doWork;
        } else {
            if (konnected == 1) {
                // we are off ! diskonnect the output
                <<< ModuleIdt, ":", "disconnecting outputs." >>>;
                0 => OutGain;
                for (0 => int i; i<SOUND.outCount; i++) {
                    0 => GL.GGains[i+O].gain;
                    GL.GGains[i+O] !=> SOUND.SKG[i];
                }
                for (0 => int i; i<SOUND.inpCount; i++) {
                    0 => GL.GGains[i+I].gain;
                    SOUND.SGI[InputsUsed[i]] !=> GL.GGains[i+I];
                }
                0 => konnected; // diskonnected
                setPreset(0);
            }
            0 => doWork;
        }
    }
    
    if (now >= infoDate) {
        minute + now => infoDate;
        if (GL.signalActivity) {
            if (konnected) {
                <<< "     **** ", ModuleIdt, ":          ", "[", UnitSwitch, KeybUnitNumber,
                "]", currPreset, doWork, konnected, InGain, OutGain >>>;
            } else {
                <<< "     ---- ", ModuleIdt, ":          ", "[", UnitSwitch, KeybUnitNumber,
                "]", currPreset, doWork, konnected, InGain, OutGain >>>;
            }
        }
    }
    
}
