/*
Beat/Tone management
*/
public class BM {
    // BPM : beat by minute
    static float BPM, newBPM;
    // BPB : beat by Bar
    static int BPB, newBPB;
    // beat and bar duration
    static dur beat, bar;
    // Dates of next beat and bar
    static time nxtBeat, nxtBar;
    // Dates of current beat and bar
    static time currentBar, currentBeat;
    static int metro; // becoming unused
    // Current bar # and beat number in the bar
    static int Nbar, Nbeat;
    // Max values for BPM and BPB
    static int MaxBPM, MaxBPB;
    // tracing ?
    static int trace;
    
    static int key, newKey;
    static int octave, newOctave;
    
    // Change BPM and BPM from an external process
    fun static void BPMSet(float newB, int Kbeat) {
        if (newB < 10.0) 10.0 => newB;
        if (newB > MaxBPM) MaxBPM => newB;
        if (Kbeat < 1) 1 => Kbeat;
        if (Kbeat > MaxBPB) MaxBPB => Kbeat;
        // Keep the values
        // They will be changed on a bar boundary
        newB => newBPM;
        Kbeat => newBPB;
    }
    
    // Synchronize on a beat
    fun static void sync() {
        currentBeat => time x;
        while (x < now) x + beat => x;
        x => now;
        me.yield(); // let every one synchronize
    }
    
    // Synchromize on a specific beat of a bar
    // sync(0) => sync. on bar start
    // sync(2) => sync on third time
    // sync(0.25) => sync on a quarter time after bar start
    fun static void sync(float k) {
        if (k < 0) 0 => k;
        k *  beat + currentBar => time x;
        while (x < now) x + bar => x;
        x => now;
        me.yield(); // let every one synchronize
    }
    
    // Update changed values
    fun static int doUpdate() {
        0 => int change;
        if (((BPM != newBPM) || (BPB != newBPB))) {
            if (newBPM < 10.0) 10.0 => newBPM;
            if (newBPM > MaxBPM) MaxBPM => newBPM;
            if (newBPB < 1) 1 => newBPB;
            if (newBPB > MaxBPB) MaxBPB => newBPB;
            newBPM => BPM; // values  checked
            newBPB => BPB; // 
            if (trace & 1) {
                <<< "Tempo change", BPM, BPB >>>;
            }
            (60.0/BPM)::second => beat;
            beat * BPB => bar;
            1 => change;
        }
        if (key != newKey) newKey => key;
        if (octave != newOctave) newOctave => octave;
        return change;
    }
    
    fun static void doBeat() {
        // First sync
        // sync();
        0 => Nbar => Nbeat;
        while (currentBeat < now) {
            currentBeat + beat => currentBeat;
        }
        if (trace & 2) {
            <<< "BM:doBeat:is", me.id(), now, currentBeat >>>;
        }
        currentBeat => currentBar => now;
        currentBeat + beat => nxtBeat;
        currentBar + BPB * beat => nxtBar;
        while (metro || Nbeat != 0)
        {
            if ((Nbeat == 0) && doUpdate())
            {
                if (trace & 2) {
                    <<< "BM:doBeat:", "Updated ! " >>>;
                }
                while (currentBeat < now) {
                    currentBeat + beat => currentBeat;
                }
                currentBeat => currentBar => now;
                currentBeat + beat => nxtBeat;
                currentBar + BPB * beat => nxtBar;
            }
            // Here, we have a correct beat, bar, currentBeat, currentBbar
            // we are precisely at "currentBeat"
            if (trace & 1) {
                <<< "    bar", Nbar, "  beat", Nbeat >>> ;
            }
            nxtBeat => now;
            // switch to a nea beat
            nxtBeat => currentBeat;
            currentBeat + beat => nxtBeat;
            Nbeat++;
            if (Nbeat >= BPB) {
                Nbar++; 0 => Nbeat;
                nxtBar => currentBar;
                currentBar + BPB * beat => nxtBar;
            }
        }
    }
    
    fun static void init() {
        3000 => MaxBPM;
        16 => MaxBPB;
        120 => newBPM => BPM;
        4 => newBPB => BPB; 
        (60.0/BPM)::second => beat;
        beat * BPB => bar;
        beat - now % beat + now => currentBeat => currentBar;
        currentBeat + beat => nxtBeat;
        currentBar + bar => nxtBar; 
        0 => Nbar => Nbeat;
        1 => metro;
        0 => trace;
        if (trace & 4) {
            <<< "BM:", beat, bar, currentBeat, now >>> ;
        }
        // Key information
        4 => newOctave => octave;
        0 => newKey => key;
        // Now, run the beat manager...
        spork ~ doBeat();
    }
}


/*
Define some default values
*/
BM.init();

<<< "BM: Defined as", me.id()  >>>;

GL.Asig | 4 => GL.Asig; // BM MGR OK

while (true) {
    minute => now;
}


