/*

    MAD BLIPPER tool
    
    JJG - April/June 2017

    Connect it with the nK2 Manager

*/


// Various options
0 => int useStudioKonnekt;
2 => int ScNumber; // scene number

1 => int periodMin;
10000 => int periodMax;

me.id() => int me_id;
"BLIP-:" + me_id => string ModuleIdt;


// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;
// 
// 8641 => int port;
// oin.port(port);
8641 => oin.port;
// create an address in the receiver
"/midi/ctl" + ScNumber => string ScNK2;
oin.addAddress(ScNK2 + ", iiii");

0.1 => float globalVolume;
// Output range
0 => int outRange;

int ctlVals[128];
for (0 => int i; i<128; i++) 0 => ctlVals[i];

100 => int period;

class KEvent extends Event
{
    float lowf, higf;
    float pan, pspeed;
}

KEvent evt[8];

fun float sigSqr(float v)
{
    if (v >= 0.0) return v*v;
    else return -v*v;
}

fun void genSnd(int pN)
{
    // The associated event
    evt[pN] @=> KEvent e;
    // impulse to filter to dac
    Impulse i => BiQuad f => Pan8 p;
    for (0 => int k; k<8; k++)
    {
        p.chan(k) => SOUND.SKG[k];
    }

    // set the filter's pole radius
    .99 => f.prad;
    // set equal gain zeros
    1 => f.eqzs;
    // set filter gain
    .5 => f.gain;
    
    while (true)
    {
        e => now;
        1.0 => i.next;
        Math.random2f(e.lowf, e.higf) => f.pfreq;
        if (ctlVals[pN+48]) {
            e.pan + e.pspeed => e.pan;
            if (e.pan > 8) e.pan - 8 => e.pan;
            if (e.pan < 0) e.pan + 8 => e.pan;
        }
        globalVolume => p.gain;
        e.pan => p.pan;
    }
}


for (0 => int i; i<8; i++)
{
    100 => evt[i].lowf;
    500 => evt[i].higf;
    0 => evt[i].pan;
    0.1 => evt[i].pspeed;
    spork ~ genSnd(i);
}

fun void bground()
{
    0 => int k;
    while (true)
    {
        if (ctlVals[k+32] != 0)
        {
            evt[k].signal();
        }
        (k+1)%8 => k;
        if (period < 1)
        {
            <<< ModuleIdt, "Period." , period >>>;
            100 => period;
        }
        period::ms => now;
    }
}

spork ~ bground();

<<< ModuleIdt, "Ready to receive" >>>;

GL.Asig | 0x8000 => GL.Asig; // Drops player Instrument OK

50 => float lfr;
5000 => float hfr;

now => time lst;
float dv;

// infinite event loop
int cmd, cha, ctl, val;
while (true)
{
    // wait for event to arrive
    oin => now;
    
    // grab the next message from the queue. 
    while (oin.recv(msg) != 0)
    {
        // getInt fetches the expected int (as indicated by "i")
        msg.getInt(0) => cha;
        msg.getInt(1) => cmd;
        msg.getInt(2) => ctl;
        msg.getInt(3) => val;
        <<< ModuleIdt, "Rec:", cha, cmd, ctl, val >>>;
        1 =>int doSig;
        if ((ctl >= 0 && ctl <=7) || (ctl >=16 && ctl <= 23))
        {
            ctl%8 => int proc;
            
            // set the current sample/impulse
            if (now > lst + 10::ms)
            {
                now => lst; 
                if (ctl <= 7)
                {
                    if (ctlVals[45] != 0)
                    {
                        if (ctl == 0) { val/127.0 => dv; dv*dv => globalVolume;}
                        <<< ModuleIdt, "Global volume:", globalVolume >>>;
                        0 => doSig;
                    }
                    else
                    {
                        // set filter resonant frequency
                        // val is in [0 - 127]
                        // 30+3*val => evt[proc].lowf;
                        // 50+50*val => evt[proc].higf;
                        Std.mtof(val/1.3 + 18) => float bf;
                        10 + bf * 0.8 => float lowf => evt[proc].lowf;
                        80 + bf * 1.3 => float higf => evt[proc].higf;
                        // 
                        <<< ModuleIdt, "Filter freq:", lowf, higf >>>;
                    }
                }
                if (ctl > 8) {
                    if (ctlVals[ /*45*/ 70] != 0)
                    {
                        // The pot. indicates a pan velocity
                        sigSqr((val-63)/64.0) => dv => evt[proc].pspeed;
                        0 => doSig;
                        <<< ModuleIdt, "Pan speed:", dv >>>;
                    }
                    else
                    {
                        val*8/127.0  => evt[proc].pan;
                    }
                }
                if (doSig && (ctlVals[ /* proc+64*/ 71] != 0))
                    evt[proc].signal();
            }
        }
        else
        if (ctl == 96)
        {
            val/127.0 => dv; dv*dv => globalVolume;
            <<< ModuleIdt, "Global volume:", globalVolume >>>;
        }
        else
        {
            3 => int tmp;
            if (ctl == 64)
            {
                if (ctlVals[66]) 1 => tmp; 
                if (ctlVals[67]) 7 => tmp;
                if (period > periodMin) { period - (period >> tmp) - 1 => period; }
                if (period < periodMin) { periodMin => period; }
                <<< ModuleIdt, "++:BPM." , 30000.0/period >>>;
            }
            if (ctl == 65)
            {
                if (ctlVals[66]) 1 => tmp; 
                if (ctlVals[67]) 7 => tmp;
                if (period < periodMax) { period + (period >> tmp) + 1 => period; }
                if (period > periodMax) { periodMax => period; }
                <<< ModuleIdt, "--:BPM." , 30000.0/period >>>;
            }
            val => ctlVals[ctl];
        }
    }
}


