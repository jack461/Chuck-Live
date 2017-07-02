/*
Exemple d'instrument potentiel utilisant l'Arturia BeatStep
*/


// patch
/*
Noise n => Gain g => BiQuad f => Envelope e => JCRev r;
Impulse i => f;
0.01 => g.gain; 
Impulse i => BiQuad f => Envelope e => JCRev r;

Delay d => r;
100::ms => d.max;
60::ms => d.delay;
0.8 => d.gain;
e => d;
*/

SinOsc s => Envelope e => JCRev r;
Delay d => r;
800::ms => d.max;
150::ms => d.delay;
0.8 => d.gain;
e => d;

/*
// set the filter's pole radius
.99 => f.prad;
// set equal gain zeros
1 => f.eqzs;
*/
// envelope rise/fall time
1::ms => e.duration;
// reverb mix
.3 => r.mix;
0.4 => r.gain;
0.4 => s.gain;

//r => dac.chan(0);
r => dac.chan(1);

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
            // note on
            //<<< msg.data1, msg.data2, msg.data3 >>>;
            // 1 => i.next;
            note + key + Math.random2(0,0)*12 => Std.mtof => s.freq;
            e.keyOn();
        }
        if (cmd == 128) {
            // <<< msg.data1, msg.data2, msg.data3 >>>;
            e.keyOff();
        }
    }
}
