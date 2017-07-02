/* PAD Lauched program
   We expect : arg(1) = ch. output number, in 0-7
               arg(2) = output volume, in 0-100
*/
/* Create an utility object */

int ident, channel, volume;
/*
*/
3 => int GroupNumber;
UT moi; moi.is(me);

moi.ident() => ident;
moi.channel() => channel;
moi.volume() => volume;
// 1 => channel;
// 40 => volume;

// Compute a global range for the sound best in 20-70
moi.getInt(3,50) / 10.0 - 5.0  => float Range;
if (Range < 0.2) 0.2 => Range;
if (Range > 5) 5 => Range;

<<< "PAD", ident, "lauched as", me.id(), "[[", ident, channel, volume, Range, "]]" >>>;
/* A kind of wind */
10 => float VFact;
volume / 100.0 => float xgain;
Math.random2f(1.2,2.5) => float duree;
duree*minute + now => time end;
<<< "*Pars:", channel, volume, xgain, duree >>>;

if (volume == 0) 0.5 => xgain;

Noise n1 => BPF f1 => Gain mult1 => Gain out => SOUND.SKG[channel]; //dac.chan(channel);
SinOsc m1 => mult1;
SinOsc m2 => mult1;
SinOsc m3 => mult1;
0 => out.gain;
3 => mult1.op;
Math.random2f(0.07,0.18) => m1.freq;
0.083 => m2.freq;
0.041 => m3.freq;
f1.set(Math.random2f(80,500)*Range,5);
Noise n2 => BPF f2 => Gain mult2 => out;
SinOsc m4 => mult2;
SinOsc m5 => mult2;
SinOsc m6 => mult2;
3 => mult2.op;
Math.random2f(0.01,0.09) => m4.freq;
0.6 => m4.gain;
0.029 => m5.freq;
0.011 => m6.freq;
f2.set(Math.random2f(200,800)*Range,10);
Noise n3 => BPF f3 => Gain mult3 => out;
SinOsc m7 => mult3;
SinOsc m8 => mult3;
SinOsc m9 => mult3;
3 => mult3.op;
Math.random2f(0.01,0.05) => m7.freq;
0.4 => m7.gain;
0.033 => m8.freq;
0.023 => m9.freq;
f3.set(Math.random2f(600,1200)*Range,5);
<<< "** Max Gain is", xgain >>>;
int mod;
while (now < end)
{
    Math.random2(1,10) => mod;
    if (mod == 1) f1.set(Math.random2f(80,500)*Range,5);
    if (mod == 2) f2.set(Math.random2f(200,800)*Range,10);
    if (mod == 3) f3.set(Math.random2f(600,1200)*Range,5);
    if (mod == 5) Range * 1.5 => Range;
    if (mod == 6) Range / 1.5 => Range;
    xgain * GL.Pot[GroupNumber] * VFact => out.gain;
    500::ms => now;
}
while (xgain > 0)
{
    xgain - 0.0005 => xgain;
    xgain * GL.Pot[GroupNumber] * VFact => out.gain;
    20::ms => now;
}
1::second => now;
<<< "Deconnecting output from", channel >>>;
out !=> SOUND.SKG[channel];
1::second => now;

moi.meExit(); // Reset all I have to reset...
0.1::second => now;

