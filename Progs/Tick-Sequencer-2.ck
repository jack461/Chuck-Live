/*


Tick Sequencer Player -- Version 2

This is "unit 5" of my set.

Needs to be "connected" to a "hard" sequencer,
like the Arturia BeatStep

Jean-Jacques Girardot - May/June 2017

License : WTFPL
http://www.wtfpl.net



*/
20 => int UnitSwitch; // This unit switch
// =================


// Various options
1 => int useSOUND_MGR; // we will use sound manager

5 => int UnitNumber; // unit number
1 => int GroupNumber;
31 => int ModVolume; // Addt. modulation volume
30 => int ToneVolume;
29 => int bgToneVolume;

me.id() => int me_id;
"Tick Seq:" + me_id => string ModuleIdt;


Ticker tickit;

// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;
// 
// oin.port(port);
8641 => oin.port;
// create an address in the receiver
"/midi/ctl" + UnitNumber => string ControllerX;
oin.addAddress(ControllerX + ", iiii");
"/midi/ctl" + 0 => string Controller0;
oin.addAddress(Controller0 + ", iiii");

"/midi/keyb" => string KeyBoard;
oin.addAddress(KeyBoard + ", iiii");

1 => GL.AB_sendSync;

// Use multiple out channels
Gain Go[8];
// Set Go gains
for (0 => int i; i<8; i++) {
    0 => Go[i].gain;
    tickit.out => Go[i];
}


0.5 => tickit.out.gain; // 
1 => float StdGain;

0 => int curOut; // current out channel


int cha, cmd, ctl, val;

0 => int lpc;
-5 => float keyStart;
keyStart => float key;
0 => float bgTone;
0 => float cnote;
1.17 => tickit.Fshift1;
0.86 => tickit.Fshift2;
tickit.setDgain(0.95);
0.5 => tickit.s1.gain;
0.5 => tickit.s2.gain;


0 => int doPlay;
0 => int doWork;
0 => int konnected;
0 => float gVol;


// Give info every minute or so
now => time infoDate;

// The "armed channels" that accept mini notes
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int armedChs[];
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int currChs[];

fun void recomputeChs()
{
    // The formula...
    GL.Btn[UnitSwitch] | ((GL.Btn[UnitSwitch] * (GL.Knkt[UnitSwitch] & 0x3f)) << 4)  => int z;
    if (z == doWork)
        return;
    z => doWork;
    for (0 => int i; i<16; i++)
        0 => armedChs[i];
    int w, j;
    if ((GL.Btn[UnitSwitch] => w) != 0)
    {
        // There is a plug here. ?
        GL.Knkt[UnitSwitch] => j;
        if ((j >= 0) && (GL.UChans[j] >= 0))
        {
            1 => armedChs[GL.UChans[j]];
        }
    }
    <<< ModuleIdt, ":", "NOW CONNEKTED [", doWork, "]"
    , armedChs[0], armedChs[1], armedChs[2], armedChs[3]
    , armedChs[4], armedChs[5], armedChs[6], armedChs[7] >>>;
}

GL.Asig | 0x80000 => GL.Asig; // Tick Sequencer OK


while (true)
{
    recomputeChs();
    if ((doWork || doPlay) && konnected) {
        // wait for event to arrive
        oin => now;
        GL.Pot[GroupNumber] * GL.Pot[ModVolume] => gVol => tickit.out.gain;
        // (GL.Pot[ToneVolume] * 40) -20 => keyStart;
        // grab the next message from the queue. 
        while (oin.recv(msg) != 0)
        {
            msg.getInt(0) => cha;
            msg.getInt(1) => cmd;
            msg.getInt(2) => ctl;
            msg.getInt(3) => val;
            if (GL.tTSeq & 1) {
                <<< "Tick Sequencer", me_id, ":", msg.address, cha, ctl, val >>>;
            }
            if ((msg.address == KeyBoard))
            {
                if (currChs[cha]) {
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
                        if (doPlay) {
                            //Math.random2(0,7) => curOut;
                            (curOut + 1) % 8 => curOut;
                            (GL.Pot[ToneVolume] * 60) -35 + key + ctl => cnote;
                            if (GL.tTSeq & 2) {
                                <<< "Tick Sequencer", me_id, "*** Note:", gVol, cha, ctl, val >>>;
                            }
                            StdGain => Go[curOut].gain; // Use selected output
                            bgTone + (GL.Pot[bgToneVolume] * 60) -35 => tickit.setZfreq;
                            tickit.play(cnote); // play the note
                            key + 0.5 => key;
                        }
                        else
                        {
                            tickit.stop(cnote);
                            0 => Go[curOut].gain;
                        }
                    }
                }
                continue;
            }
            if ((msg.address == ControllerX))
            {
                if (cmd == 255 && ctl == 8) {
                    // sequence loop start : there, we start/stop
                    doWork => doPlay; // start/stop playing
                    // Update playing channels
                    for (0 => int i; i< 16; i++)
                        armedChs[i] => currChs[i];
                    // Update tonality shift ?
                    lpc ++; 
                    if (lpc > 4) {
                        0 => lpc;
                        keyStart => key;
                        // Change background resonant tone
                        Math.random2(52,64) => bgTone;
                        // tickit.setZfreq(Math.random2(52,64));
                    }
                }
            }
            
        }
    }
    else
    {
        500::ms => now;
        if (doWork || doPlay) {
            if (konnected == 0) {
                // we are on ! konnect to the output
                <<< "Tick Sequencer:", "connecting outputs." >>>;
                for (0 => int i; i<8; i++) {
                    0 => Go[i].gain;
                    Go[i] => SOUND.SKG[i];
                }
                1 => konnected;
            }
        } else {
            if (konnected == 1) {
                // we are off ! diskonnect to the output
                <<< "Tick Sequencer:", "disconnecting outputs." >>>;
                            tickit.stop(cnote);
                for (0 => int i; i<8; i++) {
                    0 => Go[i].gain;
                    Go[i] !=> SOUND.SKG[i];
                }
                0 => konnected; // diskonnected
            }
        }
    }
    
    
    if (now >= infoDate) {
        minute + now => infoDate;
        if (GL.signalActivity) {
            if (konnected) {
                <<< "     **** ", ModuleIdt, ":          ", "[", UnitSwitch,
                "]", doPlay, doWork, konnected >>>;
            } else {
                <<< "     ---- ", ModuleIdt, ":          ", "[", UnitSwitch,
                "]", doPlay, doWork, konnected >>>;
            }
        }
    }
}








