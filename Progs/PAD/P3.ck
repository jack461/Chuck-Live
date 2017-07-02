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


<<< "PAD", ident, "lauched as", me.id(), "[[", ident, channel, volume, "]]"  >>>;
// Do the work
// ===================================================

BM.sync();

1.5 => float Range;
3 => float Urange;

Math.random2(0,7) => int ch; // output channel
Math.random2f(300, 800) * Urange => float bazFreq; // base freq.
Math.random2f(0.1, 8) => float lfoFreq; // lfo freq.
Math.random2f(8, 12) => float duree; // seconds
Math.random2f(0.1, 0.3) * xgain => float gain;
Math.random2f(3, 25) => float delta; // beween oscs
[1, 2, 2, 4, 4, 8] @=> int beatdivs[];
(BM.beat/ms) / beatdivs[Math.random2(0,beatdivs.cap()-1)]
   => float period ;
if (maybe) bazFreq + 800 => bazFreq;
if (4*delta >= period) period / 4.0 => delta;

<<< "ShortGen", ch, bazFreq, lfoFreq, duree, period, delta, gain >>>;


TriOsc s => NRev vrb => out;
TriOsc t => vrb;
TriOsc u => vrb;
TriOsc v => vrb;

SinOsc lfo => blackhole;
duree/12.0 => float durincr;
duree/1.5 => float durdecr;
0.2 => vrb.mix;

bazFreq => lfo.gain;
lfoFreq => lfo.freq;
0 => float vol;
0 => out.gain;
duree::second + now => time end;
end - durdecr::second => time startdecr;
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
    delta::ms => now;
    lfo.last() + bazFreq * Range + 10 => t.freq;
    delta::ms => now;
    lfo.last() + bazFreq * Range + 10 => u.freq;
    delta::ms => now;
    lfo.last() + bazFreq * Range + 10 => v.freq;
    (period-3*delta)::ms => now;
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
