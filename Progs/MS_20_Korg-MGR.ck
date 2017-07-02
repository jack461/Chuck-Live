/*

Managing the Korg MS20 USB controller


Jean-Jacques Girardot - May/June 2017

License : WTFPL
http://www.wtfpl.net


*/

// Needs "Globals.ck" which defines class GL
// Needs "Utils.ck" which defines class UT

// We will be sending various controller values with OSC

"localhost" => string hostname;
8641 => int port;
"MS-20 Controller" => string devName;
4 => int DevNum;

2 => int SpD; // the "special device"

me.id() => int me_id;
"MS20:" + me_id => string ModuleIdt;


<<< ModuleIdt, ": About to open", devName, "input" >>>;

MidiIn ms20;
MidiMsg msg;

// we will be sending OSC
// send object
OscOut xmit;
// aim the transmitter
xmit.dest(hostname, port);
// Messages sent
[ "/midi/keyb", "/midi/ctl" ] @=> string scIdt[];

if (!ms20.open(devName))
{
    <<< ModuleIdt, ": Can't open", devName, "input" >>>;
    me.exit();
}

<<< ModuleIdt, ":", devName, "looks OK" >>>;


fun void OSCSend(int type, int dev, int cha, int cmd, int ctl, int val) {
    if (type) {
        xmit.start(scIdt[type] + dev);
    } else {
        xmit.start(scIdt[0]);
    }
    xmit.add(cha);
    xmit.add(cmd);
    xmit.add(ctl);
    xmit.add(val);
    xmit.send();
    
}

// we will be converting our controls to different number,
// for different devices
int xDev[128]; // the devices numbers
int xCtl[128]; // the control numbers
// we build here the tables
{
    256 => int F;
    // We affect a rôle to every pot of the interface
    [  // [actual_ms20_ctl_number,  xDev number, xCtl number]
    [7,0,96],   // Global sound volume
    [1,0,98],   // Global modulation
    [91,1,96],  // Instrument 1 sound volume
    [90,2,96],  // Instrument 2 sound volume
    [89,3,96],  // Instrument 3 sound volume
    [88,4,96],  // Instrument 4 sound volume
    [11,5,96],  // Instrument 5 sound volume
    // Generic Modulations : sent and also keep as global values
    [12,0,97+F], [93,1,97+F], [30,2,97+F], [31,3,97+F], [85,4,97+F], [79,5,97+F],
    [25,11,97+F], [73,12,97+F], [75,13,97+F], [70,14,97+F], [72,15,97+F],
    // Instrument 2 specific controls
    [20,SpD,7],   // Instrument 2 Modulation speed
    [28,SpD,6],   // Instrument 2 Up detune
    [74,SpD,5],   // Instrument 2 Down detune
    [29,SpD,3],   // Instrument 2 Attack time
    [71,SpD,4],   // Instrument 2 Decay time
    [21,SpD,22],  // Instrument 2 Modulation excusion
    // [24,SpD,21],  // Instrument 2 Reverb Mix
       [24,8,97+F],
    [5,SpD,20],   // Instrument 2 portamento
    // [76,SpD,18],  // Instrument vibrato excursion
       [76,6,97+F],
    // [27,SpD,17],  // Instrument vibrato frequency
       [27,7,97+F],
    // [23,SpD,16],  // Instrument tremolo excursion
       [23,9,97+F],
    // [26,SpD,15],  // Instrument tremolo frequency
       [26,10,97+F],
    [18,SpD,14],  // Instrument filter Q-Factor
    [14,SpD,13],  // Instrument Keyb2 velocity
    [19,SpD,12],  // Instrument Keyb3 velocity
    [127,-1,-1]] @=> int cvt[][];
    int i, k;
    for (0 => i; i<128; i++) {
        -1 => xDev[i] => xCtl[i];
    }
    for (0 => i; i<cvt.cap(); i++) {
        cvt[i][0] => k;
        cvt[i][1] => xDev[k];
        cvt[i][2] => xCtl[k];
    }
}


int dev, xctl, cmd, cha, ctl, val;
int kntyp; // konnection type
int knnb1; // konnection # 1
int knnb2; // konnection # 2
int Flag;
0 => int defCh;
0 => int defDev;
16 => int MaxDev;

1 => GL.signalJK;
1 => GL.signalKN;


GL.Asig | 0x10 => GL.Asig; // MS 20 MGR OK
/*

We keep the MS-20 always active
as it is our "main" control device

*/
while (true)
{
    ms20 => now;
    while (ms20.recv(msg))
    {
        // <<< msg.data1, msg.data2, msg.data3 >>>;
        
        msg.data1 => cmd;
        cmd & 0x0f => cha;
        cmd & 0xf0 => cmd;
        msg.data2 => ctl;
        msg.data3 => val;
        0 => Flag;
        defCh => cha; // Use current default channel
        
        // OSCSend(cha, cmd, ctl, val);
        if (GL.tms20 & 1) <<< ModuleIdt, ":", dev, xctl, cha, cmd, ctl, val >>>;
        if (cmd == 144 || cmd == 128)
        {
            if (val == 0 || cmd == 128) 
            {
                // indique que l'on a recu la note off
                // correspondant a une "note on"
                0 => val; // set velocity to zero
            }
            
            OSCSend(0, defDev, cha, cmd, ctl, val);
        }
        else
        {
            if (cmd == 176) {
                xDev[ctl] => dev;
                xCtl[ctl] => xctl;
                xctl & 0xff00 => Flag;
                xctl & 0xff => xctl;
                if (dev >= 0) {
                    if (dev >= MaxDev) defDev => dev; // Which "Unit" should we use
                    OSCSend(1, dev, defCh, cmd, xctl, val);
                    // Special cases
                    if (xctl == 96) {
                        // keep global dev info
                        // We manage volumes as values in [0 1]
                        val / 127.0 => float u => GL.Pot[dev];
                        if (GL.tms20 & 2) {
                            <<< ModuleIdt, ": **** Vol", dev, "set to", u >>>;
                        }
                        UT.xVal(dev,u);
                    }
                    if (xctl == 97) {
                        // keep global dev info
                        val / 127.0 => float u => GL.Pot[dev+16];
                        if (GL.tms20 & 2) {
                            <<< ModuleIdt, ": **** Mod", dev, "set to", u >>>;
                        }
                        UT.xVal(dev+16,u);
                    }
                    if (Flag) {
                        // Signal special : command is 16, device i ctl num
                        OSCSend(1, 0, defCh, 16, dev, val);
                    }
                }
                else
                {
                    if (ctl == 77) {
                        // setting a default device
                        if (val == 0) 0 => defDev;
                        if (val == 43) 1 => defDev;
                        if (val == 85) 2 => defDev;
                        if (val == 127) 3 => defDev;
                        OSCSend(1, 0, 0, 176, 127, defDev);
                    }
                    if (ctl == 82) {
                        // setting a default channel
                        if (val == 0) 0 => defCh;
                        if (val == 43) 1 => defCh;
                        if (val == 85) 2 => defCh;
                        if (val == 127) 3 => defCh;
                        OSCSend(1, 0, 0, 176, 125, defCh);
                    }
                    if (ctl == 15) {
                        // setting a scale
                        0 => int scale;
                        if (val == 0) 0 => scale;
                        if (val == 43) 1 => scale;
                        if (val == 85) 2 => scale;
                        if (val == 127) 3 => scale;
                        OSCSend(1, defDev, defCh, 176, 124, scale);
                    }
                    if (ctl == 22) {
                        // setting a detune level
                        0 => int detune;
                        if (val == 0) 0 => detune;
                        if (val == 43) 1 => detune;
                        if (val == 85) 2 => detune;
                        if (val == 127) 3 => detune;
                        OSCSend(1, defDev, defCh, 176, 123, detune);
                    }
                    if (ctl == 99) val => kntyp;
                    if (ctl == 98) val => knnb1;
                    if (ctl == 6) {
                        // Trace to be sent ?
                        // OSCSend(1, 6, 0, 1, 1, kntyp);
                        val => knnb2;
                        // Define what event we want to send
                        if (kntyp == 4) {
                            // A jack is plugged in
                            if (knnb1 == knnb2)
                            {
                                // signal jack plugged in
                                if (GL.signalJK) OSCSend(1, 0, 0, 2, knnb1, knnb1);
                                // set button "on"
                                1 => GL.Btn[knnb1];
                            } else {
                                // signal konnection established
                                if (knnb1 < knnb2) { knnb1 => int x; knnb2 => knnb1; x => knnb2; }
                                if (GL.signalKN) OSCSend(1, 0, 0, 4, knnb1, knnb2);
                                knnb1 => GL.Knkt[knnb2];
                                knnb2 => GL.Knkt[knnb1];
                            }
                        }
                        if (kntyp == 5) {
                            // A jack is unplugged 
                            if (knnb1 == knnb2)
                            {
                                // signal jack unplugged
                                if (GL.signalJK) OSCSend(1, 0, 0, 3, knnb1, knnb1);
                                // set button "on"
                                0 => GL.Btn[knnb1];
                            } else {
                                // signal konnection broken
                                if (knnb1 < knnb2) { knnb1 => int x; knnb2 => knnb1; x => knnb2; }
                                if (GL.signalKN) OSCSend(1, 0, 0, 5, knnb1, knnb2);
                                -1 => GL.Knkt[knnb2];
                                -1 => GL.Knkt[knnb1];
                            }
                        }
                        if (kntyp == 6) {
                            <<< "Type 6", knnb1, knnb2 >>>;
                            if (knnb2 == 0)
                                UT.UnDclVars(-1);
                            else
                                UT.DclAll();
                        }
                    }
                }
            }
            else
            {
                if (cmd == 208) {
                    if (GL.tms20 & 2) <<< ModuleIdt, ": ***", cmd, ctl >>>;
                    if (ctl == 0) {
                        // send "all notes off"
                        OSCSend(1, 2, 0, 176, 126, 0);
                    }
                }
            }
        }
    }
}
