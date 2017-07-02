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
Delay d => r;
800::ms => d.max;
120::ms => d.delay;
0.8 => d.gain;
e => d;

// set the filter's pole radius
.99 => f.prad;
// set equal gain zeros
1 => f.eqzs;
// envelope rise/fall time
1::ms => e.duration;
// reverb mix
.3 => r.mix;
0.4 => r.gain;

r => out[0] => dac.chan(0);
r => out[1] => dac.chan(1);

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
0 => int key;
0 => int switcher;
while( true )
{
    MIN => now;
    while(MIN.recv(msg))
    {
        msg.data1 => cmd;
        msg.data2 => note;
        msg.data3 => vel;
        //
        
        if (cmd == 144) {
            0 => out[switcher].gain;
            1 - switcher => switcher;
            1 => out[switcher].gain;
            // note on
            //<<< msg.data1, msg.data2, msg.data3 >>>;
            1 => i.next;
            note + key + Math.random2(1,1)*12 => Std.mtof => f.pfreq;
            e.keyOn();
        }
        if (cmd == 128) {
            // <<< msg.data1, msg.data2, msg.data3 >>>;
            e.keyOff();
        }
    }
}
