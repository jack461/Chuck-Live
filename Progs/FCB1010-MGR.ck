/*

Management of the Behringer FCB1010 

Jean-Jacques Girardot - June 2017

License : WTFPL
http://www.wtfpl.net


*/

MidiIn MIDIDev;

// 
"USB Midi" => string devName;
me.id() => int me_id;
"FCB1010:" + me_id => string ModuleIdt;

<<< "About to open", devName, "input" >>>;

if(!MIDIDev.open(devName))
{
    <<< ModuleIdt, ":Error: MIDI port did not open on:", devName >>>;
    me.exit();
}

<<< ModuleIdt, ":", devName, "open." >>>;

MidiMsg msg;

int cmd, cha, ctl, val;

GL.Asig | 0x20 => GL.Asig; // FCB1010 MGR OK

while (true)
{
    MIDIDev => now;
    while (MIDIDev.recv(msg))
    {
        if (GL.tFCB & 1) {
            <<< msg.data1, msg.data2, msg.data3 >>>;
        }
        msg.data1 => cmd;
        cmd & 0x0f => cha;
        cmd & 0xf0 => cmd;
        msg.data2 => ctl;
        msg.data3 => val;
        if (cmd == 192) {
            // This is a preset number [0-99]
            ctl => GL.cPreset;
            UT.xVal(51, ctl+1);
        }
        if (cmd == 176) {
            if (ctl == 7) {
                // pedal B
                val / 127.0 => GL.pedB;
            } else {
                // pedal A
                val / 127.0  => GL.pedA;
            }
        }
    }
    
}
