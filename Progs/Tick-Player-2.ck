/*


Tick Player

This is "unit 5" of my set.



Jean-Jacques Girardot - May/June 2017

License : WTFPL
http://www.wtfpl.net


*/


// Various options
1 => int useSOUND_MGR;
2 => int KeybUnitNumber; // unit number
1 => int GroupNumber;
15 => int UnitSwitch; // This unit switch

31 => int ModVolume; // Addt. modulation volume


Ticker tickit;

"Tick Play" => string ModuleIdt;
me.id() => int me_id;

// Basically, we get key on/key command and we play the notes...


// create our OSC receiver
OscIn oin;
// create our OSC event
OscMsg msg;
// 
// oin.port(port);
8641 => oin.port;

// create an address in the receiver
"/midi/ctl" + KeybUnitNumber => string ControllerX;
oin.addAddress(ControllerX + ", iiii");
"/midi/ctl" + 0 => string Controller0;
oin.addAddress(Controller0 + ", iiii");
"/midi/keyb" => string KeyBoard;
oin.addAddress(KeyBoard + ", iiii");


// Use multiple out channels
Gain Go[8];
// konnect Go to outputs
for (0 => int i; i<8; i++) {
    // tickit.out => Go[i] => SOUND.SKG[i];
    tickit.out => Go[i];
    0 => Go[i].gain;
}

0.5 => tickit.out.gain; // 
1 => float StdGain;

0 => int curOut; // current out channel

int cha, cmd, ctl, val;


0 => int lpc;
-5 => float keyStart;
keyStart => float key;
0 => float cnote;

1 => tickit.Fshift1;
1 => tickit.Fshift2;
tickit.setDgain(0.95);
0.5 => tickit.s1.gain;
0.5 => tickit.s2.gain;


0 => int doWork;
0 => int konnected;


GL.Asig | 0x40000 => GL.Asig; // Tick Player OK

// Give info every minute or so
now => time infoDate;

while (true)
{
    if (doWork) {
        // wait for event to arrive
        oin => now;
        // revEvt => now;
        GL.Pot[GroupNumber] * GL.Pot[ModVolume] => tickit.out.gain;
        // grab the next message from the queue. 
        while (oin.recv(msg) != 0)
        {
            // Should we stop ?
            if (GL.Btn[UnitSwitch] == 0)
            {
                0 => doWork; // this will stop us playing sooner/later
            }
            msg.getInt(0) => cha;
            msg.getInt(1) => cmd;
            msg.getInt(2) => ctl;
            msg.getInt(3) => val;
            if (GL.tTPly & 1) {
                <<< ModuleIdt, ":", me_id, ":", cha, cmd, ctl, val >>>;
            }
            if ((msg.address == KeyBoard))
            {
                // Note on/off
                // there, ctl is note number, val is velocity
                // we do not use the velocity sent, but a default one
                // for the specific channel
                if (cmd == 128) {
                    0 => val;
                }
                if (val == 0) 
                {
                    tickit.stop(cnote);
                    0 => Go[curOut].gain;
                }
                else
                {
                    if (doWork) {
                        Math.random2(0,7) => curOut;
                        key + ctl => cnote;
                        if (GL.tTPly & 2) <<< ModuleIdt, ":", me_id, "    *** Note:", cha, ctl >>>;
                        StdGain => Go[curOut].gain; // Use selected output
                        tickit.play(cnote); // play the note
                        key + 0.5 => key;
                        if (key > keyStart + 24) keyStart => key;
                    }
                }
            }
        }
    }
    else
    {
        500::ms => now;
        if (GL.Btn[UnitSwitch] != 0) {
            if (konnected == 0) {
                // we are on ! konnect to the output
                if (GL.tTPly & 2) <<< ModuleIdt, ":", me_id, ":", "connecting outputs." >>>;
                for (0 => int i; i<8; i++) {
                    0 => Go[i].gain; // yes, it's OK
                    Go[i] => SOUND.SKG[i];
                }
                1 => konnected;
            }
            1 => doWork;
        } else {
            if (konnected == 1) {
                // we are off ! diskonnect the output
                if (GL.tTPly & 2) <<< ModuleIdt, ":", me_id, ":", "disconnecting outputs." >>>;
                for (0 => int i; i<8; i++) {
                    0 => Go[i].gain;
                    Go[i] !=> SOUND.SKG[i];
                }
                0 => konnected; // diskonnected
            }
            0 => doWork;
        }
    }
    
    if (now >= infoDate) {
        minute + now => infoDate;
        if (GL.signalActivity) {
            if (konnected) {
                <<< "     **** ", ModuleIdt, me_id, ":          ", "[", UnitSwitch, KeybUnitNumber,
                "]", doWork, konnected >>>;
            } else {
                <<< "     ---- ", ModuleIdt, me_id, ":          ", "[", UnitSwitch, KeybUnitNumber,
                "]", doWork, konnected >>>;
            }
        }
    }
    
}

