/*
Sound Manager
for 8 channels

Jean-Jacques Girardot - May 2017

License : WTFPL
http://www.wtfpl.net


*/

// Run First

public class SOUND {
    
    // static Gain @ SKG[]; // The 8 output connections
    static Dyno @ SKG[]; // The 8 output connections
    static Gain @ SGI[]; // 8 input konnections 
    static WvOut @ SKRec[]; // 8 recorders
    static int KonnektFlag;
    static float KGain;
    static float nexGain;
    static float MaxGain;
    static int chcf[];
    static int chins[];
    static int recording;
    static int recordId;
    static int recordUniq;
    static int recordMode;
    static int recordNCh;
    static int trace;
    static int inpCount;
    static int outCount;
    static float chanVols[]; 
    static int volTick, volNumb;
    
    // static string @ recordDir;
    
    public static void KonnektInit() {
        <<< "SOUND:Running", "KonnektInit();" >>>;
        0 => KonnektFlag;
        0 => KGain;
        0 => nexGain;
        0 => recording;
        0 => recordMode => recordNCh;
        0.7 => MaxGain; // Max. output gain for this configuration
        Math.random2(100000,999999) => recordUniq;
    }
    
    // Konnect the expected 8 outputs for Gain
    public static void KonnektHome() {
        <<< "SOUND:Running", "KonnektHome();" >>>;  
        // For the home :
        if (!KonnektFlag) {
            if (dac.channels() >= 10)
            {
                [0,1,7,9,5,4,8,6] @=> chcf;
            }
            else
            {
                // We connect by pairs
                [0,1,0,1,0,1,0,1] @=> chcf;
            }
            for (0 => int i; i<chcf.cap(); i++) {
                SKG[i] => dac.chan(chcf[i]);
            }
            if (adc.channels() >= 12)
            {
                [0,1,2,3,4,5,6,7,8,9,10,11] @=> chins;
            }
            else
            {
                [0,1,0,1,0,1,0,1,0,1,0,1] @=> chins;
            }
            for (0 => int i; i<chins.cap(); i++) {
                adc.chan(chins[i]) => SGI[i];
            }
            1 => KonnektFlag;
            <<< "SOUND now connected to outputs", chcf[0], chcf[1], chcf[2], chcf[3],
            chcf[4], chcf[5], chcf[6], chcf[7] >>>;
            <<< "SOUND now connected to inputs", chins[0], chins[1], chins[2], chins[3],
            chins[4], chins[5], chins[6], chins[7], chins[8], chins[9], chins[10], chins[11] >>>;
        }
        else
        {
            <<< "SOUND already connected to outputs", chcf[0], chcf[1], chcf[2], chcf[3],
            chcf[4], chcf[5], chcf[6], chcf[7] >>>;
            <<< "SOUND already connected to inputs", chins[0], chins[1], chins[2], chins[3],
            chins[4], chins[5], chins[6], chins[7], chins[8], chins[9], chins[10], chins[11] >>>;
        }
    }
    
    
    // Konnect the expected 8 outputs for Gain
    public static void KonnektLo() {
        <<< "SOUND:Running", "KonnektLo();" >>>;  
        // For the home :
        if (!KonnektFlag) {
            if (dac.channels() >= 24)
            {
                [16,17,19,21,23,22,20,18] @=> chcf;
            }
            else
            {
                // We connect by pairs
                [0,1,0,1,0,1,0,1] @=> chcf;
            }
            for (0 => int i; i<chcf.cap(); i++) {
                SKG[i] => dac.chan(chcf[i]);
            }
            if (adc.channels() >= 24)
            {
                [16,17,18,19,20,21,22,23,0,1,2,3] @=> chins;
            }
            else
            {
                [0,1,0,1,0,1,0,1,0,1,0,1] @=> chins;
            }
            for (0 => int i; i<chins.cap(); i++) {
                adc.chan(chins[i]) => SGI[i];
            }
            1 => KonnektFlag;
            <<< "SOUND now connected to outputs", chcf[0], chcf[1], chcf[2], chcf[3],
            chcf[4], chcf[5], chcf[6], chcf[7] >>>;
            <<< "SOUND now connected to inputs", chins[0], chins[1], chins[2], chins[3],
            chins[4], chins[5], chins[6], chins[7], chins[8], chins[9], chins[10], chins[11] >>>;
        }
        else
        {
            <<< "SOUND already connected to outputs", chcf[0], chcf[1], chcf[2], chcf[3],
            chcf[4], chcf[5], chcf[6], chcf[7] >>>;
            <<< "SOUND already connected to inputs", chins[0], chins[1], chins[2], chins[3],
            chins[4], chins[5], chins[6], chins[7], chins[8], chins[9], chins[10], chins[11] >>>;
        }
    }
    
    
    /* Method for setting slowly the global gain of the system */
    public static void gain(float val) {
        if (val > 1.0) 1.0 => val;
        if (val < 0.0) 0.0 => val;
        val => nexGain;
    }
    
    /*
    Start recording on "n" channels
    */
    public static void recordStart(int nkv) {
        if ((!recording) && (nkv > 0)) {
            if (nkv > 8) 8 => nkv;
            nkv => recordNCh;
            1 => recordMode;
            10::ms => now; // wait for completion
            // print some message
            <<< "\n\n\nSOUND:", "recording", recording, "channels in ", recordId, "started.\n\n\n" >>>;
        }
    }
    
    /*
    Stop current recording
    */
    public static void recordStop() {
        if (recording) {
            2 => recordMode;
            10::ms => now; // wait for completion
            // print some message
            <<< "\n\n\nSOUND:", "recording", recordId, "ended.\n\n\n" >>>;
        }
    }
    
    /*
    Start 8 channels recording
    */
    public static void recordStart() {
        recordStart(8);
    }
    
    // Slowly change gain when possible
    private static void gainSet() {
        if (trace & 1) {
            <<< "SOUND:gainSet", me.id() >>>;
        }
        5 => float cycle;
        float prvGain, actGain;
        0.0004 => float eps;
        KGain => prvGain => actGain;
        while (true)
        {
            if (nexGain > KGain)
            {
                KGain + eps => KGain;
                if (KGain >= nexGain) {
                    nexGain => KGain;
                } 
                KGain * KGain * MaxGain => actGain;
            }
            if (nexGain < KGain)
            {
                KGain - eps => KGain;
                if (KGain <= nexGain) {
                    nexGain => KGain;
                } 
                KGain * KGain * MaxGain => actGain;
            }
            if (prvGain != actGain) {
                for (0 => int i; i<8; i++) {
                    KGain * KGain * MaxGain => SKG[i].gain;
                }
                actGain => prvGain;
            }
            if (recordMode == 1)
            {
                // command to start recording
                string srec;
                recordId++;
                for (0 => int i; i<8; i++) {
                    SKG[i] => SKRec[i % recordNCh];
                }
                // open "recordNCh" files
                for (0 => int i; i<recordNCh; i++) {
                    SKRec[i] => blackhole;
                    me.dir() + "RECS/" + "SK-Rec-" + recordUniq + "-" 
                     + recordId + "-" + i + ".wav" => srec;
                    SKRec[i].wavFilename(srec);
                    // <<< "*open", srec >>>;
                }
                recordNCh => recording;
                // Done -- reset recordMode
                0 => recordMode;
            }
            if (recordMode == 2)
            {
                // command to stop recording
                string srec;
                // Close Files [up to 8 channels]
                for (0 => int i; i<recording; i++) {
                    me.dir() + "RECS/" + "SK-Rec-" + recordUniq + "-" 
                     + recordId + "-" + i + ".wav" => srec;
                    SKRec[i].closeFile(srec);
                    // <<< "*close", srec >>>;
                    SKRec[i] !=> blackhole;
                }
                // Disconnect recorders
                for (0 => int i; i<8; i++) {
                    SKG[i] !=> SKRec[i % recording];
                }
                0 => recording;
                // Done -- reset recordMode
                0 => recordMode;
            }
            {
                // Compute various in/out volumes
                for (0 => int i; i<8; i++)
                    Std.fabs(SOUND.SKG[i].last()) +=> chanVols[i];
                for (0 => int i; i<8; i++)
                    Std.fabs(SOUND.SGI[i].last()) +=> chanVols[i+8];
                
                if (volTick++ > 20) {
                    0 => volTick;
                    // Send sound volume information for trace
                    UT.xChV(chanVols);
                    for (0 => int i; i<16; i++)
                        0 => chanVols[i];
                }
            }
            cycle::ms => now;
        }
    }
    
    // Start the slow varying gain manager
    public static void startSlowManager() {
        spork ~ gainSet();
    }
    
    /* Public Method for setting slowly the global gain of the system */
    public static void gain(float val) {
        if (val > 1.0) 1.0 => val;
        if (val < 0.0) 0.0 => val;
        val => nexGain;
    }
    
    
}

// ===============================================
// We need some further initializations, because of
// some ChucK limitations...

// Number of inputs
12 => SOUND.inpCount;
// Number of outputs
8 => SOUND.outCount;
// Actual outputs
new Dyno [SOUND.outCount] @=> SOUND.SKG;
// The initialization of inputs
new Gain [SOUND.inpCount] @=> SOUND.SGI;
// The output recorders
new WvOut[SOUND.outCount] @=> SOUND.SKRec;
// Channels volumes
new float [16] @=> SOUND.chanVols;

for (0 => int i; i<SOUND.outCount; i++) {
    // Set Dyno to limiter
    SOUND.SKG[i].limit();
    SOUND.SKG[i].thresh(0.8); // set threshold not too low
    // Initial output gains set to 0
    0.0 => SOUND.SKG[i].gain;
}

for (0 => int i; i<SOUND.inpCount; i++) {
    // Initial input gains set to 1
    1.0 => SOUND.SGI[i].gain;
    // "pull" inputs with blackholes
    SOUND.SGI[i] => blackhole;
}

for (0 => int i; i<16; i++) {
    0.0 => SOUND.chanVols[i];
}

0 => SOUND.recording;
0 => SOUND.recordId;
0 => SOUND.volTick => SOUND.volNumb;
// Connect to dac
SOUND.KonnektInit();
// 
SOUND.KonnektHome();
// SOUND.KonnektLo();
SOUND.startSlowManager();


/*
Now we build the OSC receiver
*/
// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;
// oin.port(port);
8641 => oin.port;
0 => int ScNumber; // sound control number
// create an address in the receiver
"/midi/ctl" + ScNumber => string Controller;
oin.addAddress(Controller + ", iiii");



//===================================
// Make sure to loop...
// This keeps Gains objects and their connection to dac

<<< "SOUND: inited as", me.id() >>>;

GL.Asig | 8 => GL.Asig; // Sound MGR OK

int cha, cmd, ctl, val;
while (true)
{
    // wait for event to arrive
    oin => now;
    
    // grab the next message from the queue. 
    while (oin.recv(msg) != 0)
    {
        msg.getInt(0) => cha;
        msg.getInt(1) => cmd;
        msg.getInt(2) => ctl;
        msg.getInt(3) => val;
        /// 
        if (SOUND.trace & 2) {
            <<< "SOUND:", msg.address, cha, cmd, ctl, val >>>;
        }
        if (msg.address == Controller) // Always true, actually
        {
            if (cmd == 176) {
                // Controller
                if ((ctl == 96)) {
                    val/127.0 => float u;
                    // u * u => u;
                    if (SOUND.trace & 1) {
                        <<< "SOUND: main volume", u >>>;
                    }
                    SOUND.gain(u);
                    UT.xVal(0,u);
                }
            }
            if (cmd == 4) {
                if (ctl == 30 && val == 29) {
                    if (SOUND.trace & 1) {
                        <<< "SOUND:",  "*** Start recording" >>>;
                    }
                    SOUND.recordStart();
                }
            }
            if (cmd == 5) {
                if (ctl == 30 && val == 29) {
                    if (SOUND.trace & 1) {
                        <<< "SOUND:",  "Stop recording ***" >>>;
                    }
                    SOUND.recordStop();
                }
            }
        }
    }
}

