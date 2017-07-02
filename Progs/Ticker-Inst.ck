/*


Tick instrument


Jean-Jacques Girardot

License : WTFPL
http://www.wtfpl.net


*/

public class Ticker {
    
    // The patch itself
    
    // patch
    Noise n => Gain g => BiQuad f => Envelope e => Dyno dy => JCRev r;
    Gain out;
    
    Impulse i => f;
    0.018 => g.gain; 
    
    DelayL d => dy;
    SinOsc s1 => e;
    SinOsc s2 => e;
    e => d;
    d => d;
    
    1000::ms => d.max;
    
    0.75 => float Fshift1;
    0.87 => float Fshift2;
    
    r => out; // this is the output
    dy.limit(); // use as a limiter
    0.6 => dy.thresh;
    
    // set the filter's pole radius
    .99 => f.prad;
    // set equal gain zeros
    1 => f.eqzs;
    // envelope rise/fall time
    0.7::ms => e.duration;
    // reverb mix
    .1 => r.mix;
    0.7 => r.gain;
    0.4 => s1.gain;
    0.3 => s2.gain;
    
    setZfreq(57);
    setDgain(0.96);
    
    fun void setZfreq(float mfreq) {
        mfreq => Std.mtof => float zfreq;
        (1.0/zfreq)::second => d.delay;
    }
    
    fun void setDgain(float val) {
        if (val < 0.001) 0.001 => val;
        if (val > 0.999) 0.999 => val;
        val => d.gain;
    }
    
    fun void play(float note) {
        float freq;
        1 => i.next;
        note  => Std.mtof => freq;
        freq => f.pfreq;
        freq * Fshift1 => s1.freq;
        freq * Fshift2 => s2.freq;
        e.keyOn();
    }
    
    fun void stop(float note) {
        e.keyOff();
    }
}


<<< "Ticker: now running as", me.id() >>>;

GL.Asig | 0x2000 => GL.Asig; // Ticker Instrument OK

while (true) {
    minute => now;
}


