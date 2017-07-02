/*

Use the Nexus as a generic keybord
Send note on/off as OSC messages


Jean-Jacques Girardot - May/June 2017

License : WTFPL
http://www.wtfpl.net


*/

4 => int defChannel; // Default channel
// send object
// host name and port
"localhost" => string hostname;
8641 => int port;
// "/midi/ctl" => string DevIdent;
2 => int DevNum;
17 => int UnitSwitch;
-1 => int KonnectedDevice;
me.id() => int me_id;
"QuNx:" + me_id  => string ModuleIdt;


"QuNexus Port 1" => string devName;
MidiIn QuNex;
MidiMsg msg;


<<< ModuleIdt,": About to open", devName, "input" >>>;

if(!QuNex.open(devName))
{
    <<< ModuleIdt,": Can't open", devName, "input" >>>;
    me.exit();
}

<<< ModuleIdt,":", devName, "open." >>>;

defChannel => int actChannel;

OscOut xmit;
// aim the transmitter
xmit.dest(hostname, port);
// Messages sent
[ "/midi/keyb", "/midi/ctl" ] @=> string scIdt[];

/*
Send : type (0:keyb, 1:ctl), channel, command,
control numer/key number, value/velocity
*/
fun void OSCSend(int type, int cha, int cmd, int ctl, int val) {
    if (type) {
        xmit.start(scIdt[type] + DevNum);
    } else {
        xmit.start(scIdt[0]);
    }
    xmit.add(cha);
    xmit.add(cmd);
    xmit.add(ctl);
    xmit.add(val);
    xmit.send();
}

/*
For what I understand, the nexus only transmit "note on"
and zero-values "note on" as "note off"
*/

int cmd, cha, ctl, val;

GL.Asig | 0x40 => GL.Asig; // QuNexus MGR OK

while(true)
{
    QuNex => now;
    if (GL.Knkt[UnitSwitch] != KonnectedDevice) {
        GL.Knkt[UnitSwitch] => KonnectedDevice;
        defChannel => actChannel;
        if (KonnectedDevice >=0 && GL.UChans[KonnectedDevice] >=0) {
            GL.UChans[KonnectedDevice] => actChannel;
        }
        <<< ModuleIdt,":konnect:", KonnectedDevice, actChannel >>>;
    }
    while(QuNex.recv(msg))
    {
        if (KonnectedDevice >= 0) {
            msg.data1 => cmd;
            cmd & 0x0f => cha;
            cmd & 0xf0 => cmd;
            msg.data2 => ctl;
            msg.data3 => val;
            actChannel => cha; 
            if (GL.tQNx & 1) {
                <<< "QNxs:", cmd, cha, ctl, val >>>;
            }
            if (cmd == 144 || cmd == 128)
            {
                if (val == 0 || cmd == 128) 
                {
                    // flag indique que l'on a recu la note off
                    // correspondant a une "note on"
                    0 => val; // set velocity to zero
                }
                
                OSCSend(0, cha, cmd, ctl, val);
            }
            if (cmd == 224)
            {
                // Send "bend" as "all note off"
                OSCSend(1, cha, cmd, 0, 0);
            }
        }
    }
}

