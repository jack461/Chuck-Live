/*
Read the nanoKONTROL2 controls.
Send OSC signals
Manage scenes, controls switching, etc.

J.J. GIRARDOT - April-June 2017

License : WTFPL
http://www.wtfpl.net


*/
// need "Globals.ck" to signal some values
me.id() => int me_id;
"nK2:" + me_id => string ModuleIdt;

// host name and port
"localhost" => string hostname;
8641 => int port;
"nanoKONTROL" => string devName;

MidiMsg msg;
MidiMsg wmsg;

320::ms => dur Tempo;
1 => int doHandle;
0 => int doUpdate;
0 => int ctlMode => GL.CtlF;
0 => int scene;  // Current scene
8 => int scnNb;  // Allow 8 Scenes
0 => int CSig;
80 => int CK; // Command key Number
84 => int Ksync; // synchronize commands
85 => int SHK; // Shift Key
0 => int shiftB => GL.ShiftF;
-1 => int prevShift;

<<< ModuleIdt, ":About to open", devName, "input" >>>;
MidiIn nK2;

if (!nK2.open(devName))
{
    <<< ModuleIdt, ":Can't open", devName, "input" >>>;
    me.exit();
}

<<< ModuleIdt, ":About to open", devName, "output" >>>;
MidiOut nK2Out;

if (!nK2Out.open(devName))
{
    <<< ModuleIdt, ":Can't open", devName, "output" >>>;
    me.exit();
}


<<< ModuleIdt, ":", devName, "looks OK" >>>;


// Messages sent
[ "/midi/ctl0", "/midi/ctl1", "/midi/ctl2", "/midi/ctl3", 
"/midi/ctl4", "/midi/ctl5", "/midi/ctl6", "/midi/ctl7" ] @=> string scIdt[];


[ [  // Non shift mode
0,  1,  2,  3,  4,  5,  6,  7,  -1, -1, -1, -1, -1, -1, -1, -1, // 0
16, 17, 18, 19, 20, 21, 22, 23, -1, -1, -1, -1, -1, -1, -1, -1, // 16
32, 33, 34, 35, 36, 37, 38, 39, -1, 81, 82, 83, 84, 85, CK, -1, // 32
48, 49, 50, 51, 52, 53, 54, 55, -1, -1, 88, 89, 90, 91, 92, -1, // 48 
64, 65, 66, 67, 68, 69, 70, 71, -1, -1, -1, -1, -1, -1, -1, -1, // 64
-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 80
-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 96
-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1  // 112
], [  // Shift mode
8,  9, 10, 11, 12, 13, 14, 15,  -1, -1, -1, -1, -1, -1, -1, -1, // 0
24, 25, 26, 27, 28, 29, 30, 31, -1, -1, -1, -1, -1, -1, -1, -1, // 16
40, 41, 42, 43, 44, 45, 46, 47, -1, 81, 82, 83, 84, 85, CK, -1, // 32
56, 57, 58, 59, 60, 61, 62, 63, -1, -1, 88, 89, 90, 91, 92, -1, // 48
72, 73, 74, 75, 76, 77, 78, 79, -1, -1, -1, -1, -1, -1, -1, -1, // 64
-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 80
-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 96
-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1  // 112
]] @=> int convTable[][];

// Manage controls
// Keep values here of All controls of all scenes
int AllCtls[scnNb][128];
//
int tglMod[128];
int ActualPos[128];

// All these are "toggled" keys
[32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79 
] @=> int CtlAddrs[];

// Build the various useful data representationq
{
    int i, j, k;
    // Initialize the controller
    for (0 => i; i<CtlAddrs.cap(); i++)
    {
        1 => tglMod[CtlAddrs[i]];
    }
    // Build the Actual position on the nK2 of our "virtual" controls.
    for (0 => i; i<128; i++)
    {
        -1 => ActualPos[i];
    }
    for (0 => i; i<2; i++)
    {
        for (0 => j; j<128; j++)
        {
            convTable[i][j] => k;
            if (k>=0) j => ActualPos[k];
        }
    }
}

// Some control buttons have specific meaning
[46, 43, 44, 42, 41, 45] @=> int CtlNums[];
int CtlStats[6];

fun void setSig(int flags[])
{
    int k;
    for (0 => int i; i<flags.cap(); i++)
    {
        flags[i] => k;
        if (k) k => CtlStats[i];
    }
}

fun void HandleCtls()
{
    <<< ModuleIdt, ":Sporking HandleCtls for nK2 MGR =>", me.id() >>>;
    MidiMsg xMsg;
    176 => xMsg.data1;
    int i, k, c, snd;
    Tempo - (now%Tempo) => now;
    while (doHandle)
    {
        for (0 => i; i<6; i++)
        {
            CtlStats[i] => k;           
            0 => snd;
            // is "do nothing"
            if (k == 1) { 0 => xMsg.data3; 1 => snd; 0 => CtlStats[i]; }  // 1 : turn off, switch to 0
            else if (k == 2) { 127 => xMsg.data3; 1 => snd; 0 => CtlStats[i]; } // 2: turn on, switch to 3
            else if (k == 3) { k+c+1 => CtlStats[i];  } // switch to 4 or 5, synchro
            else if (k == 4) { 127 => xMsg.data3; 1 => snd; 5 => CtlStats[i]; } // 4: turn on, switch to 5
            else if (k == 5) { 0 => xMsg.data3; 1 => snd; 4 => CtlStats[i]; } // 5: turn off, switch to 6
            else if ((k == 6) || (k == 8)) { k+1 => CtlStats[i]; } // 6: 8: wait 1, skip to next
            else if (k == 7) { 127 => xMsg.data3; 1 => snd; 8 => CtlStats[i]; } // 7: slow blink on
            else if (k == 9) { 0 => xMsg.data3; 1 => snd; 6 => CtlStats[i]; } // 9: slow blink off
            if (snd) { CtlNums[i] => xMsg.data2; nK2Out.send(xMsg); }
            
        }
        if (doUpdate > 0) { doUpdate--; if (doUpdate == 0) { setSig([0, 1, 1, 0, 0, 0]); 0 => CSig;}}
        1 - c => c;
        Tempo => now;
    }
}

// Update displays
// Scenes signatures
[  
[1, 0, 0, 1, 1, 0], [1, 0, 0, 1, 6, 0], 
[1, 0, 0, 6, 1, 0], [1, 0, 0, 2, 6, 0],
[1, 0, 0, 6, 2, 0], [1, 0, 0, 2, 2, 0],
[1, 0, 0, 6, 6, 0], [1, 0, 0, 6, 8, 0]
] @=> int SceneSigs[][];


fun void updDisp()
{
    176 => wmsg.data1;
    for (0 => int i; i<CtlAddrs.cap(); i++)
    {
        CtlAddrs[i] => wmsg.data2;
        AllCtls[scene][CtlAddrs[i]] => wmsg.data3;
        nK2Out.send(wmsg);
    }
    setSig(SceneSigs[scene]);
}

fun void updCtl()
{
    176 => wmsg.data1;
    46 => wmsg.data2;
    ctlMode => wmsg.data3;
    nK2Out.send(wmsg);
}

/*
Update buttons after a shift on/off
*/
fun void updShift()
{
    if (shiftB != prevShift)
    {
        int w;
        shiftB => prevShift;
        176 => wmsg.data1;
        for (32=>int i; i<80; i++)
        {
            convTable[shiftB][i] => w;
            if (w >= 32 && w <80) 
            {
                i => wmsg.data2;
                AllCtls[scene][w] => wmsg.data3;
                nK2Out.send(wmsg);
            }
        }
        45 => wmsg.data2;
        shiftB * 127 => wmsg.data3;
        nK2Out.send(wmsg);
    }
}

// send object
OscOut xmit;
fun void OSCSend(int scene, int cha, int cmd, int ctl, int val) {
    xmit.start(scIdt[scene]);
    xmit.add(cha);
    xmit.add(cmd);
    xmit.add(ctl);
    xmit.add(val);
    xmit.send();
    
}

// aim the transmitter
xmit.dest(hostname, port);

// Run : light ON/OFF a row of leds
fun void lpCtls(int ctl, int cnt, int val)
{
    176 => wmsg.data1;
    for (0 => int i; i<cnt; i++)
    {
        ctl+i => wmsg.data2;
        val => wmsg.data3;
        nK2Out.send(wmsg);
        30::ms => now;
    }
}

<<< ModuleIdt, ":Initializing", devName >>>;

lpCtls(32,8,127);
lpCtls(48,8,127);
lpCtls(64,8,127);

lpCtls(32,8,0);
lpCtls(48,8,0);
lpCtls(64,8,0);


<<< ModuleIdt, ":Main loop started.", "" >>>;

spork ~ HandleCtls();

setSig([1, 1, 1, 1, 1, 1]);


int cScene, newScene, cmd, cha, ctl, val;

GL.Asig | 0x200 => GL.Asig; // nK2 MGR OK

while (true)
{
    nK2 => now;
    while (nK2.recv(msg))
    {
        msg.data1 => cmd;
        cmd & 0x0f => cha;
        cmd & 0xf0 => cmd;
        msg.data2 => ctl;
        msg.data3 => val;
        ///  if (GL.tnK2 & 2) <<< msg.data1, msg.data2, msg.data3 >>>;
        if ((msg.data1 & 0xff) == 176)
        {
            scene => cScene => newScene;
            convTable[shiftB][ctl] => int vCtl; // virtual ctl. nb
            if (vCtl == SHK)
            {
                // <<< "Shift", ctl, vCtl, val >>>;
                1 - shiftB => shiftB => GL.ShiftF; // just toggle the shift
                setSig([0, 0, 0, 0, 0, 1+shiftB]); 
                updShift();
                -1 => vCtl;
            } 
            else
            {
                if (tglMod[vCtl]) 
                {
                    127 - AllCtls[scene][vCtl] => val; // do not care about actual value
                }
                if (GL.tnK2 & 1)
                {
                    <<< ModuleIdt, ":Got", vCtl, val >>>;
                }
            }
            
            // Cycle is used as a "command" key
            if (vCtl == CK) { 
                127 - ctlMode => ctlMode; nK2Out.send(msg);
                (ctlMode != 0) => GL.CtlF;
                -1 => vCtl;
            }
            if (vCtl >= 0 && ctlMode != 0) 
            {
                // Manage here all commands
                if (vCtl >= 32) {
                    if ((vCtl == 88)) { 
                        (scene - 1 + scnNb) % scnNb => newScene;
                    }
                    if ((vCtl == 89)) {
                        (scene + 1) % scnNb => newScene;
                    }
                    if ((vCtl == 81)) {
                    }
                    if ((vCtl == 82)) {
                    }
                    if ((vCtl == 83)) {
                         8 => newScene; // switch to scene zero
                    }
                    if ((vCtl == 84)) {
                    }
                    if ((vCtl == 91)) {
                        0 => GL.tnK2; <<< ModuleIdt, ":Trace off" >>>;
                    }
                    if ((vCtl == 92)) {
                        1 => GL.tnK2; <<< ModuleIdt, ":Trace on" >>>;
                    }
                    if ((vCtl >= 32 && vCtl <= 47)) {
                        vCtl % scnNb + 8 => newScene; // always "change", even if the same
                    }
                    0 => ctlMode => GL.CtlF; // exit ctrl mode                
                    -1 => vCtl; // don't transmit anything
                }
                else
                {
                    // we will send a special control but dont get out of mode control
                    vCtl % scnNb => cScene; // Our new "current" scene
                    96 + (vCtl >> 4) => vCtl; // the new "virtual" button
                }
            }
            if ((vCtl == 88)) { 
                (scene - 1 + scnNb) % scnNb => newScene; 
            }
            if ((vCtl == 89)) {
                (scene + 1) % scnNb => newScene;
            }
            if (newScene != scene)
            {
                // we have just switched from one scene to another
                newScene & 0x7 => scene;
                if (GL.tnK2) {
                    <<< ModuleIdt, ":Scene", scene >>>;
                }
                0 => ctlMode => GL.CtlF; // get out of control mode
                0 => shiftB => GL.ShiftF;  // reset shift
                updDisp();                
                setSig([0, 0, 0, 0, 0, 1+shiftB]); updShift();
                -1 => vCtl;
            }
            // We are moving a slider or a potentiometer...
            if ((vCtl >= 0 && vCtl < 32) || (vCtl >= 96 && vCtl <= 97))
            {
                int k, w;
                // is the slider "synchronized" with actual value ?
                if (AllCtls[cScene][Ksync] == 0) 
                {
                    val - AllCtls[cScene][vCtl] =>  k;
                    (vCtl+2) << 2 + (k > 0) =>  w;
                }
                else
                {
                    0 => k;
                }
                if (k < -3) {
                    if (w != CSig) { w => CSig; setSig([0, 1, 4, 0, 0, 0]);};
                    -1 => vCtl; 
                }  // actual value is "less" 
                else if (k > 3) {
                    if (w != CSig) { w => CSig; setSig([0, 4, 1, 0, 0, 0]);};
                    -1 => vCtl; 
                } // actual value is "greater"
                else { 0 => CSig; setSig([0, 2, 2, 0, 0, 0]); }
                8 => doUpdate; 
            }
            
            if (vCtl >= 0)
            {
                val => AllCtls[cScene][vCtl];
                if ((vCtl >= 32) && (vCtl <= 90))
                {
                    // switch on/off the nK2 button
                    ctl => msg.data2;
                    val => msg.data3;
                    nK2Out.send(msg);
                }
                OSCSend(cScene, 0, cmd, vCtl, val);
                if (vCtl < 32) {
                    val / 127.0 => GL.Pot[vCtl + 32 * (cScene + 1)];
                }
            }
            
            updCtl();
            
            me.yield();
        }
    } 
}

<<< ModuleIdt, ":End." >>>;

