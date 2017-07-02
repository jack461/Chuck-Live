/*
Read the nanoPAD2 controls.
Send OSC signals
Manage scenes, controls switching, etc.

J.J. GIRARDOT - June 2017

License : WTFPL
http://www.wtfpl.net


*/

public class nPAD2MGR {
    static int sendNotes; // set to send sequencer notes
    static int sendCtls; // set to send controls
}

1 => nPAD2MGR.sendNotes; // default : send notes
0 => nPAD2MGR.sendCtls; // not controls

"nPAD2" => string ModuleIdt;

// host name and port
"localhost" => string hostname;
8641 => int port;
"nanoPAD" => string devName;
1 => int DevNum;

<<< ModuleIdt, ":About to open", devName, "input" >>>;

MidiIn nP2;
MidiMsg msg;

// send object
OscOut xmit;
// aim the transmitter
xmit.dest(hostname, port);


if (!nP2.open(devName))
{
    <<< ModuleIdt, ":Can't open", devName, "input" >>>;
    me.exit();
}

<<< ModuleIdt, ":", devName, "looks OK" >>>;

[ "/midi/key", "/midi/ctl" ] @=> string scIdt[];


fun void OSCSend(int type, int dev, int cha, int cmd, int ctl, int val) {
    xmit.start(scIdt[type] + dev);
    xmit.add(cha);
    xmit.add(cmd);
    xmit.add(ctl);
    xmit.add(val);
    xmit.send();
    
}

int cmd, cha, ctl, val;

GL.Asig | 0x100 => GL.Asig; // nPAD2 MGR OK

while (true)
{
    nP2 => now;
    while (nP2.recv(msg))
    {
        msg.data1 => cmd;
        cmd & 0x0f => cha;
        cmd & 0xf0 => cmd;
        msg.data2 => ctl;
        msg.data3 => val;
        if (GL.tnP2 & 1) {
             <<< ModuleIdt, ":", cmd, cha, ctl, val >>>;
        }
        // For now, we use only note/on note off
        if (cmd == 144 || cmd == 128)
        {
            if (val == 0 || cmd == 128) 
            {
                // flag indique que l'on a recu la note off
                // correspondant a une "note on"
                0 => val; // set velocity to zero
            }
            if (nPAD2MGR.sendNotes) OSCSend(0, DevNum, cha, cmd, ctl, val);
        }
        if (cmd == 176)
        {
            if (nPAD2MGR.sendCtls) OSCSend(1, DevNum, cha, cmd, ctl, val);
        }
    }
}

