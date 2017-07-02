/*
Prog laucher for the PAD

Wait for a command

Lauch the program...


Jean-Jacques Girardot - May/June 2017

License : WTFPL
http://www.wtfpl.net


*/

3 => int GroupNumber;


// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;
// 
8641 => oin.port;
// Define messages
1 => int DevNum; // wait for this device
"/midi/key" + DevNum => string PADCMD;
// create an address in the receiver
oin.addAddress( PADCMD + ", iiii");


/* 

Programs management

For each midi note, we have an entry with :

- # of a program to launche
- channel for this program
- volume for the program
- other parameters, as a unique string

*/
int launchNumber[128];
int launchChan[128];
int launchVol[128];
string launchPars[128];
string launchIdent[128];
{
    // Initialization
    for (0 => int i; i<128; i++)
    {
        -1 => launchNumber[i];
        0 => launchChan[i];
        0 => launchVol[i];
        "" => launchPars[i];
        "" => launchIdent[i];
    }
}


fun void P(int note, int pnum, int chan, int vol, string pars)
{
    if (note < 0 || note > 127) 0 => note;
    pnum => launchNumber[note];
    chan => launchChan[note];
    vol => launchVol[note];
    pars => launchPars[note];
}
fun void P(int note, int pnum, int chan, int vol)
{
    P(note, pnum, chan, vol, "");
}
fun void P(int note, int pnum, int chan)
{
    P(note, pnum, chan, -1, "");
}
fun void P(int note, int pnum)
{
    P(note, pnum, -1, -1, "");
}
fun void P(int note, int pnum, string pars)
{
    P(note, pnum, -1, -1, pars);
}
fun void P(string idt, int note)
{
    // Use a specific module for number "x" prog
    if (note < 0 || note > 127) 0 => note;
    idt => launchIdent[note];
    // still need a classical declaration    
}

P(36,0); // "thunder"
P(37,0,"10");  // "thunder"
P(38,1); // -1 => random channel, 20 => volume
P(39,0,"25");  // "thunder"
P(40,3); // blipper
P(41,0,"100");// "thunder"
P(42,4); // kick
P(43,0,"250");// "thunder"
P(44,5);
P(45,6,"snare.wav");
P(46,6,"hihat.wav");
P(47,6,"snare-chili.wav");
P(48,6,"hihat-open.wav");
P(49,6,"snare-hop.wav");

<<< "PAD-Player:done.", "" >>>;

fun void lauchP(int note) {
    if (note <= 0 || note > 127) return;
    int pnum, chan, vol;
    string progid;
    launchNumber[note] => pnum; 
    if (pnum < 0) return;
    me.dir() + "PAD/" => progid;
    if (launchIdent[note] == "")
        progid + "P" + pnum => progid; // Use P0, P1, P133, etc.
    else
        progid + launchIdent[note] => progid; // Use provided name
    launchChan[note] => chan;
    launchVol[note] => vol;
    if (vol < 0 || vol > 100) Math.random2(30,70) => vol;
    progid + ".ck:" + note + ":" + chan + ":" + vol => progid;
    if (launchPars[note] != "") progid + ":" + launchPars[note] => progid;
    <<< "Lauching", note, "as", progid >>>;
    Machine.add(progid);
}


GL.Asig | 0x20000 => GL.Asig; // Pad Player OK

int cha, cmd, ctl, val;
// infinite event loop

while (true)
{
    // wait for event to arrive
    oin => now;
    
    // grab the next message from the queue. 
    while ( oin.recv(msg) != 0 )
    {
        if (msg.address == PADCMD)
        {
            msg.getInt(0) => cha;
            msg.getInt(1) => cmd;
            msg.getInt(2) => ctl;
            msg.getInt(3) => val;
            <<< "PAD:", msg.address, msg.typetag, cha, cmd, ctl, val >>>;
            // We car run up to 64 programs
            if ((cmd == 144) && (ctl >= 36) && (ctl <= 99))
            {
                if (GL.ShiftF) {
                    <<< "PAD-Player:will try to interrupt prog", ctl >>>;
                }
                else
                {
                    <<< "PAD-Player:will launch prog", ctl >>>;
                    lauchP(ctl);
                }
            }
            
        }
    }
}


