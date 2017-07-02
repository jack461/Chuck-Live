
/*
A SawOsc based synth, with moving resonant filters
Defined as a public class
    
    Usage:
    
    VSynth synt;



synt.out() => dac; // Mono output

synt.play(0, 60); // play middle C on channel 0
synt.stop(0, 60); // stop playing the C on channel 0
synt.stop(); // all notes off


V2.2 -- June 19, 2017

Jean-Jacques Girardot

License : WTFPL
http://www.wtfpl.net


*/
public class VSynth {
    
    
    // The declaration / initialization part
    NRev rev;
    Gain globg;
    
    16 => int Nnotes; // Polyphony
    4 => int Channels; // Channel count
    int pitches[Channels][Nnotes];
    0 => int trace;
    // Common characteristics
    0.5 => float gGain => globg.gain;
    0.10 => rev.mix;
    30 => float QFactor;  // in [1 128]
    0.005 => float fastness;
    0.002 => float volAttack;
    0.0008 => float volDecay;
    0.25 => float freqLFactor;
    32 => float freqHFactor;
    0 => int Ktransp;
    0.015 => float Gdetune;
    1 => float globDetune;
    1 => float globVibrato;
    1 => float globTremolo;
    0 => int flagVib;
    0 => int flagTrem;
    1 => float vibExcur;
    0 => float tremExcur;
    0.001 => float vibEps;
    0.001 => float vDelta;
    0.001 => float tremEps;
    0.001 => float tDelta;
    1 => float cmdDetune;
    0.20 => float dgain;
    1 => float portemento;
    1.2 => float loopDly; // loop internal delay, in ms
    fastness * 1.23 => float r1fincr;
    fastness * 1.13 => float r2fincr;
    fastness * 1.17 => float r3fincr;
    {
        for (0 => int k; k<Channels; k++) {
            for (0 =>int i; i<Nnotes; i++)
                -1 => pitches[k][i];
        }
    }
    // Connecting to output
    rev => globg;
    
    spork ~ sporkedVproc(); // inutile pour l'instant
    
    fun Gain out() {
        return globg;
    }
    
    fun void setPars(float fst) {
        fst => fastness;
        
        // Update pars
        
        fastness * 1.23 => r1fincr;
        fastness * 1.13 => r2fincr;
        fastness * 1.17 => r3fincr;
    }
    
    // This is forked for each note to be played
    fun void generate(int chan, int num, int k, int vel)
    {
        SawOsc s1, s2, s3;
        ResonZ r1, r2, r3;
        Gain g, w;
        float r1f, r2f, r3f;
        fastness => float uFst;
        // each SawOsc is connected to each ResonZ filter
        s1 => r1; s1 => r2; s1 => r3;
        s2 => r1; s2 => r2; s2 => r3;
        s3 => r1; s3 => r2; s3 => r3;
        // filters go to general gain
        r1 => g; r2 => g; r3 => g;
        // SawOsc are also connected to direct Gain w
        s1 => w; s2 => w; w => g;
        // set some values
        dgain => w.gain; // direct gain of SawOsc
        0 => g.gain; // start volume at zero
        
        // Base frequency we are going to play
        float nfreq; 
        Std.mtof(k+Ktransp) => nfreq => float s1f;
        nfreq * (1+Gdetune) => float s2f;
        nfreq * (1.001-Gdetune) => float s3f;
                
        1.0 => float r1d;
        1.0 => float r2d;
        1.0 => float r3d;
        float gain, xgain, ogain;
        if (vel < 1) 1 => vel;
        if (vel > 127) 127 => vel;
        // ogain is the original gain, from velocity
        vel/127.0 => ogain => xgain;
        0 => gain;
        
        float lowfreq,  highfreq;
        float wg, qf;
        nfreq * freqLFactor => lowfreq => r1f => r2f => r3f => r1.freq => r2.freq => r3.freq;
        
        // Connect output to globalreverb
        g => rev;
        if (trace) <<< "VSynth:Playing", k, "by", me.id() >>>;
        // Play
        while (true)
        {
            if (QFactor != qf) { 
                QFactor => qf => r1.Q => r2.Q => r3.Q;
                // adjust xgain
                ogain * (1.0 + qf/128.0) => xgain;
                dgain * (1.0 - qf/120.0) => wg; if (wg < 0) 0 => wg;
                wg => w.gain;
            }
            
            nfreq * freqLFactor => lowfreq;
            nfreq * freqHFactor => highfreq;
            if (highfreq > 12000) 12000 => highfreq;
            // Manage Gain variation for enveloppes
            if (gain > xgain)  { gain - volDecay => gain; if (gain < 0) 0 => gain; }
            if (gain < xgain)  { gain + volAttack => gain; if (gain > 1) 1 => gain; } 
            gain*gain => g.gain;
            
            // Manage filters tune variations
            globDetune * globVibrato * s1f => s1.freq;
            globDetune * globVibrato * s2f => s2.freq;
            globDetune * globVibrato * s3f => s3.freq;
            
            loopDly :: ms  => now;
            
            if (r1f > highfreq) -1 => r1d;
            if (r1f < lowfreq) 1 => r1d;
            if (r2f > highfreq) -1 => r2d;
            if (r2f < lowfreq) 1 => r2d;
            if (r3f > highfreq) -1 => r3d;
            if (r3f < lowfreq) 1 => r3d;
            (1+r1fincr*r1d) * r1f => r1f => r1.freq;
            (1+r2fincr*r2d) * r2f => r2f => r2.freq;
            (1+r3fincr*r3d) * r3f => r3f => r3.freq;
            
            if (pitches[chan][num] != k)
                break;       
        }
        
        // Manage "note off"
        -1 => pitches[chan][num]; // this frees the entry
        while (gain > 0)
        {
            gain - volDecay => gain; if (gain < 0) 0 => gain;
            
            gain*gain => g.gain;
            globDetune * globVibrato * s1f => s1.freq;
            globDetune * globVibrato * s2f => s2.freq;
            globDetune * globVibrato * s3f => s3.freq;
            
            loopDly :: ms  => now;
            
            if (r1f > highfreq) -1 => r1d;
            if (r1f < lowfreq) 1 => r1d;
            if (r2f > highfreq) -1 => r2d;
            if (r2f < lowfreq) 1 => r2d;
            if (r3f > highfreq) -1 => r3d;
            if (r3f < lowfreq) 1 => r3d;
            (1+r1fincr*r1d) * r1f => r1f => r1.freq;
            (1+r2fincr*r2d) * r2f => r2f => r2.freq;
            (1+r3fincr*r3d) * r3f => r3f => r3.freq;
            
        }
        // Manage reverb
        0 => g.gain;
        g !=> rev; // disconnect generator
        100::ms => now;
    }
    
    
    // play a note on one channel, with velocity
    fun void play(int chan, int mno, int vel)
    {
        if (chan < 0) 0 => chan;
        if (chan >= Channels) Channels-1 => chan;
        // we accept "mno" outsides of [0 127]
        if (trace) <<< "VSynth:Play", chan, mno, vel >>>;
        int i;
        -1 => int ent;
        for (0 => i; i<Nnotes && ent<0; i++)
        {
            if (pitches[chan][i] == mno) {
                i => ent;
            }
        }
        if (ent < 0) {
            for (0 => i; i<Nnotes && ent<0; i++) {
                if (pitches[chan][i] == -1)
                    i => ent;
            }
        }
        if (ent < 0) {
            // Choose a random ent and kill it :-(
            Math.random2(0,Nnotes-1) => ent;
        }
        // Prepare to play, stop previous if necessary
        if (pitches[chan][ent] >= 0) {
            -1 => pitches[chan][ent];
            (loopDly * 1.1) ::ms => now; // wait for fork to realize...
        }
        mno => pitches[chan][ent];
        spork ~ generate(chan, ent, mno, vel);
    }
    
    // play a note on one channel
    fun void play(int chan, int mno)
    {
        play(chan, mno, 127);
    }
    
    // play a note on first channel
    fun void play(int mno)
    {
        play(1, mno, 127);
    }
    
    // Stop a note on one channel
    fun void stop(int chan, int mno)
    {
        if (chan < 0) 0 => chan;
        if (chan >= Channels) chan % Channels => chan;
        if (trace) <<< "VSynth:Stop", mno >>>;
        int i;
        -1 => int ent;
        if (mno >= 0) {
            for (0 => i; i<Nnotes && ent<0; i++)
            {
                if (pitches[chan][i] == mno) {
                    0 => ent; mno + 256 => pitches[chan][i];
                }
            }
        }
        else
        {
            for (0 => i; i<Nnotes; i++)
            {
                -1 => pitches[chan][i];
            }
        }
    }
    
    // All notes off for one channel...
    fun void stop(int chan)
    {
        if (chan < 0) 0 => chan;
        if (chan >= Channels) chan % Channels => chan;
        for (0 =>int i; i<Nnotes; i++)
            -1 => pitches[chan][i];
    }
    
    // All notes off...
    fun void stop()
    {
        for (0 => int k; k<Channels; k++) {
            for (0 =>int i; i<Nnotes; i++)
                -1 => pitches[k][i];
        }
    }
    
    fun void sporkedVproc()
    {
        float absVib, absTrem;
        int vibDir;
        if (trace) <<< "VSynth:Sporked !", me.id() >>>;
        0 => absVib;
        0 => absTrem;
        0 => vibDir;
        vibEps => vDelta;
        tremEps => tDelta;
        while (true) {
            if (cmdDetune != globDetune)
            { 
                (cmdDetune-globDetune) * (portemento + 0.0001) / 10.0 => float delta;
                globDetune + delta => globDetune;
            }
            if (flagVib || (absVib > 0))
            {
                // absVib oscilate between 1 and vibExcur
                absVib + vDelta => absVib;
                if (vibDir) absVib * vibExcur + 1 => globVibrato; 
                else 1.0/(absVib * vibExcur + 1) => globVibrato; 
                if (absVib <= 0) { vibEps => vDelta; 0 => absVib; 1 - vibDir => vibDir; } // make things grow
                if (absVib >= 1) { - vibEps => vDelta; 1 => absVib;  }  // make things schrink
            }
            if (flagTrem || (absTrem > 0))
            {
                // absTrem oscilate between 0 and 1
                absTrem + tDelta => absTrem;
                1.0 - absTrem * tremExcur => globTremolo;
                gGain * globTremolo => globg.gain;
                if (absTrem <= 0) { tremEps => tDelta; 0 => absTrem; }
                if (absTrem >= 1) { - tremEps => tDelta; 1 => absTrem; }
            }
            1::ms => now;
        }
    }
}


<<< "VSynth: now running as", me.id() >>>;

GL.Asig | 0x1000 => GL.Asig; // VSynth Instrument OK


while (true) {
    minute => now;
}

