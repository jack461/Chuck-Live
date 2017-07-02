/*

  When MAIN Volume manager fails,
  an alternate one
  
*/



// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;
// oin.port(port);
8641 => oin.port;
0 => int ScNumber; // sound control number
// create an address in the receiver
"/midi/ctl" + ScNumber => string Controller;
oin.addAddress(Controller + ", iiii");


<<< "XSOUND: inited as", me.id() >>>;


int cha, cmd, ctl, val;
while (true)
{
    // wait for event to arrive
    oin => now;
    
    // grab the next message from the queue. 
    while (oin.recv(msg) != 0)
    {
        msg.getInt(0) => cha;
        msg.getInt(1) => cmd;
        msg.getInt(2) => ctl;
        msg.getInt(3) => val;
        /// 
        <<< "XSOUND:", msg.address, cha, cmd, ctl, val >>>;
        if (msg.address == Controller) // Always true, actually
        {
            if (cmd == 176) {
                // Controller
                if ((ctl == 96)) {
                    val/127.0 => float u;
                    // u * u => u;
                    <<< "XSOUND: main volume", u >>>;
                    SOUND.gain(u);
                }
            }
            if (cmd == 4) {
                if (ctl == 30 && val == 29) {
                    <<< "XSOUND:",  "*** Start recording" >>>;
                    // SOUND.recordStart();
                }
            }
            if (cmd == 5) {
                if (ctl == 30 && val == 29) {
                    <<< "XSOUND:",  "Stop recording ***" >>>;
                    // SOUND.recordStop();
                }
            }
        }
    }
}

