/*
  Testing SOUND
*/

// StudioKonnekt.KonnektHome();

// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;
// 

// oin.port(port);
8641 => oin.port;
// create an address in the receiver
"/midi/ctl0" => string ScNK2;
oin.addAddress(ScNK2 + ", iiii");


// Build a connexion to the StudioKonneKt input
Gain GN[8] => StudioKonnekt.SKG;
Noise noiz;
for (0 => int i; i<8; i++) {
    0 => GN[i].gain;
    noiz => GN[i];
}

<<< "StudioKonnekt-MGR-TEST", "running" >>>;
int cmd, cha, ctl, val;
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
        if (ctl >= 64 && ctl <= 71) {
            <<< "Noise on", ctl % 8, ":", val != 0 >>>;
            val != 0 => GN[ctl % 8].gain;
        }
        else
        if ((ctl == 0) || (ctl == 96)) {
                <<< "StudioKonnekt.gain:", val/127.0 >>>;
                StudioKonnekt.gain(val/127.0);
                10::ms => now;
                <<< "Gain:", StudioKonnekt.SKG[0].gain() >>>;

        }
        else
        {
            <<< "      StudioKonnekt-MGR-TEST:", msg.address, cha, ctl, val >>>;
            <<< "Gain:", StudioKonnekt.SKG[0].gain() >>>;

        }
    }
    
    if (ctl == 90) {
        <<< "Exit code.", ctl >>>;
        break;
    }
}
    
for (0 => int i; i<8; i++) {
     0 => GN[i].gain;
}

<<< "StudioKonnekt-MGR-TEST", "end" >>>;

2::second => now;

