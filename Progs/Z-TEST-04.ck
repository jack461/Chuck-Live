/*
Exemple d'instrument potentiel utilisant l'Arturia BeatStep
*/


// patch
Noise n => Gain g => BiQuad f => Envelope e => JCRev r;
Gain out[2];

Impulse i => f;
0.015 => g.gain; 
/*
Impulse i => BiQuad f => Envelope e => JCRev r;

Delay d => r;
100::ms => d.max;
60::ms => d.delay;
0.8 => d.gain;
e => d;
*/
DelayL d => r;
SinOsc s => e;
1000::ms => d.max;
// 2.0::ms => d.delay;
57 => Std.mtof => float zfreq;
(1.0/zfreq)::second => d.delay;
0.96 => d.gain;
e => d;
d => d;
e => r;

// set the filter's pole radius
.99 => f.prad;
// set equal gain zeros
1 => f.eqzs;
// envelope rise/fall time
0.7::ms => e.duration;
// reverb mix
.1 => r.mix;
0.5 => r.gain;
0.4 => s.gain;

/*
// Use this
r => out[0] => dac.chan(0);
r => out[1] => dac.chan(1);
// or that
r => out[0] => SOUND.SKG[0];
r => out[1] => SOUND.SKG[1];
*/

r => out[0] => SOUND.SKG[0];
r => out[1] => SOUND.SKG[1];

// SOUND.gain(0.3);

"Arturia" => string devName;

<<< "About to open", devName, "input" >>>;
MidiIn MIN;

if(!MIN.open(devName))
{
    <<< "Error: MIDI port did not open on port: ", devName >>>;
    me.exit();
}

<<< devName, "open." >>>;
MidiMsg msg;

int cmd, note, vel;
-5 => float keyStart;
36 => int Xcursion;
keyStart => float key;
0 => int switcher;
0 => int ctr;
float freq;
while( true )
{
    MIN => now;
    while(MIN.recv(msg))
    {
        me.yield();
        msg.data1 => cmd;
        msg.data2 => note;
        msg.data3 => vel;
        //
        if (msg.data1 == 0xF8)
        {
            // Do nothing
        }
        else
        if (cmd == 144) {
            if (ctr >= Xcursion)
            {
                0 => ctr;
                keyStart => key;
                Math.random2(48,60) => int x => Std.mtof => float zfreq;
                (1.0/zfreq)::second => d.delay;
                <<< "Xcursion in", x >>>;
            }
             0 => out[switcher].gain;
            1 - switcher => switcher;
            1 => out[switcher].gain;
            // note on
            //
            <<< msg.data1, msg.data2, msg.data3 >>>;
            1 => i.next;
            note + key + Math.random2(1,1)*12 => Std.mtof => freq;
            freq => f.pfreq;
            freq * 0.75 => s.freq;
            e.keyOn();
               key + 0.5 => key;
            ctr++;
        }
        else
        if (cmd == 128) {
            // 
            <<< msg.data1, msg.data2, msg.data3 >>>;
            e.keyOff();
        }
        else
        if (cmd == 0xfa) {
            // sequence restart
            <<< "Sequence", "Restart." >>>;
            keyStart => key;
            0 => ctr;
            0 => switcher;
        }
    }
}
