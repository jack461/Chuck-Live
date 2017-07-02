


Ticker toto;

/*
toto.out => dac.chan(0);
toto.out => dac.chan(1);
*/
toto.out => SOUND.SKG[1];
toto.out => SOUND.SKG[1];

0.05 => toto.out.gain;

/*
fun void play(int note) {
    float freq;
    1 => toto.i.next;
    note  => Std.mtof => freq;
    freq => toto.f.pfreq;
    freq  => toto.s.freq;
    toto.e.keyOn();
    1000::ms => now;
    toto.e.keyOff();
}
*/

fun void play(int note) {
    toto.play(note);
    1000::ms => now;
    toto.stop(note);
}



play(60);
second => now;
play(72);
second => now;
play(84);
second => now;
play(96);
second => now;
play(48);
second => now;
