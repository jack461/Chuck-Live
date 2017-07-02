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

Gain out;

out => SOUND.SKG[channel]; //dac.chan(channel);


<<< "PAD", ident, "lauched as", me.id(), "[[", ident, channel, volume, "]]" >>>;


// construct the patch
SndBuf buf => out;
// read in the file
me.dir() + "data/kick.wav" => buf.read;
// set the gain
.3 => out.gain;
.5::second => dur T;

10 => int repeatit;

// time loop
while (repeatit > 0)
{
    // set the play position to beginning
    0 => buf.pos;
    // randomize gain a bit
    Math.random2f(.8,.9) * GL.Pot[GroupNumber] => buf.gain;
    
    // advance time
    1::T => now;
    repeatit--;
}


// ===================================================
// Work done...
1::second => now;
<<< "Deconnecting output from", channel >>>;
out !=> SOUND.SKG[channel];
1::second => now;

moi.meExit(); // Reset all I have to reset...
0.1::second => now;
