/* PAD Lauched program
   We expect : arg(1) = ch. output number, in 0-7
               arg(2) = output volume, in 0-100
*/
/* Create an utility object */
UT moi; moi.is(me);

int ident, channel, volume;
moi.ident() => ident;
moi.channel() => channel;
moi.volume() => volume;

volume / 100.0 => float xgain;

Gain out;

out => SOUND.SKG[channel]; //dac.chan(channel);


<<< "PAD Px lauched as", me.id(), "[[", ident, channel, volume, "]]" >>>;




// ===================================================
// Work done...
1::second => now;
<<< "Deconnecting output from", channel >>>;
out !=> SOUND.SKG[channel];
1::second => now;

