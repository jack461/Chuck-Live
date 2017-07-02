/* PAD Lauched program
   We expect : arg(1) = ch. output number, in 0-7
               arg(2) = output volume, in 0-100
*/
/* Create an utility object */
3 => int GroupNumber;
UT moi; moi.is(me);

int ident, channel, volume;
moi.ident() => ident;
moi.channel() => channel;
moi.volume() => volume;

volume / 100.0 => float xgain;
0.3 => float VFact;

Gain out;

out => SOUND.SKG[channel]; //dac.chan(channel);


<<< "PAD", ident, "lauched as", me.id(), "[[", ident, channel, volume, "]]" >>>;

// Do the work
// ===================================================
1.5 => float Range;
3 => float Urange;
Math.random2(0,7) => int ch; // output channel
Math.random2f(200, 700) * Urange => float bazFreq; // bse freq.
Math.random2f(0.1, 6) => float lfoFreq;
Math.random2f(5,9) => float duree; // seconds
Math.random2f(350,800) => float period; // ms
Math.random2f(0.10, 0.20) * xgain => float gain;
if (maybe) { period / 6.0 => period; gain * 1.5 => gain; }

<<< "ShortGen", ch, bazFreq, lfoFreq, duree, period, gain >>>;

TriOsc s => NRev vrb => out;
SinOsc lfo => blackhole;
duree/9.0 => float durincr;
duree/2.2 => float durdecr;
0.25 => vrb.mix;

bazFreq => lfo.gain;
lfoFreq => lfo.freq;
0 => float vol;
0 => out.gain;
duree::second + now => time end;
end - durincr::second => time startdecr;
period / (durincr * 1000) => float incr ;
period / (durdecr * 1000) => float decr ;

while (now < end || vol > 0) {
    if (now >= startdecr)
    {
        vol - decr => vol;
        if (vol< 0) 0 => vol;
    }
    else if (vol < 1)
    {
        vol + incr => vol;
        if (vol>1) 1 => vol;
    }
    vol * vol * gain * GL.Pot[GroupNumber] * VFact => out.gain;
    lfo.last() + bazFreq * Range + 10 => s.freq;
    period::ms => now;
    // <<< "Vol", vol * vol * gain >>>;
}



// ===================================================
// Work done...
0.1::second => now;
<<< "Deconnecting output from", channel >>>;
out !=> SOUND.SKG[channel];
0.1::second => now;

moi.meExit(); // Reset all I have to reset...
0.1::second => now;
