 /*

Generic receiver from OSC interface

*/

22 => int UnitSwitch;
// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;
// 

24 => int EmitSwitch;

8641 => oin.port;
oin.listenAll();

// we will be sending OSC
// send object
OscOut xmit;
8642 => int xport;
"localhost" => string hostname;
// aim the transmitter
xmit.dest(hostname, xport);

1 => int trace;
// infinite event loop

// Check trace indicator
<<< "TEST-OSC:trace is currently", GL.Btn[UnitSwitch]>>>;

while (true)
{
    // wait for event to arrive
    oin => now;
    
    // grab the next message from the queue. 
    while (oin.recv(msg) != 0)
    {
        // getInt fetches the expected int (as indicated by "i")
        if (GL.Btn[UnitSwitch]) {
            msg.getInt(0) => int cha;
            msg.getInt(1) => int cmd;
            msg.getInt(2) => int ctl;
            msg.getInt(3) => int val;
            <<< "                          TEST:", 
            msg.address, cha, cmd, ctl, val >>>;
            if (GL.Btn[EmitSwitch]) {
                xmit.start(msg.address);
                xmit.add(cha);
                xmit.add(cmd);
                xmit.add(ctl);
                xmit.add(val);
                xmit.send();
            }
        }
        if (trace != GL.Btn[UnitSwitch]) {
            GL.Btn[UnitSwitch] => trace;
            <<< "                   ----- Trace:", trace >>>;
        }
    }
}

