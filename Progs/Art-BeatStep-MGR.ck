/*

Module "Art-BeatStep-MGR.ck"

Management of the Arturia BeatStep

Does a complicate algorithm to determine
the sequence size, the tempo, etc.
J.J. Girardot

June 17 2017

License : WTFPL
http://www.wtfpl.net


*/

me.id() => int me_id;
"ArtBS:" + me_id => string ModuleIdt;
1 => int UnitSwitch; // plug there to connect the code
-1 => int KonnectedDevice;


5 => int DevNum; // This device Number
6 => int defChannel; // Default channel number
defChannel => int actChannel; // current channel number
defChannel => GL.UChans[UnitSwitch]; // signal our channel number

"localhost" => string hostname;
8641 => int port;
"/midi/ctl" => string DevIdent;

MidiIn BeatStep;
"Arturia BeatStep" => string devName;

MidiOut BeatOut;

if(!BeatStep.open(devName))
{
    <<< ModuleIdt, ":Error: input MIDI device did not open on port: ", devName >>>;
    me.exit();
}

<<< ModuleIdt, ":", devName, "open. input" >>>;

if(!BeatOut.open(devName))
{
    <<< ModuleIdt, ":Error: output MIDI device did not open on port: ", devName >>>;
    me.exit();
}

<<< ModuleIdt, ":", devName, "open. output" >>>;


MidiMsg msg;

// we will be sending OSC
// send object
OscOut xmit;
// aim the transmitter
xmit.dest(hostname, port);

// Messages sent
[ "/midi/keyb", "/midi/ctl" ] @=> string scIdt[];

fun void OSCSend(int type, int dev, int cha, int cmd, int ctl, int val) {
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


0 => int TickCount;
0 => int QNCount;
0 => int SeqNum;
0 => int CNote;
int kode;
now => time lastNow;
now => time current;

2048 => int stepSize;
int stepNb[stepSize];
-1 => int stepPos;
0 => int hadNote;
0 => int hadPos;
0 => int secondPos;

dur Sdur, QNdur;
0 => int seqlg;
0 => int validStart;
0 => int pivot;
0 => int currentLg;
24 => int tickPerBeat;
16 => int beatPerSeq;
-2048 => int prevNPos;
-1024 => int curNPos;
1024 => int intNgap;
-1 => int prevSQLg;

0 => GL.AB_aTrace; // debug
0 => GL.AB_eTrace; // event trace
1 => GL.AB_sendSync; // set to send Beat/Sequence sync
1 => GL.AB_sendNotes; // set to send sequencer notes


GL.AB_sendSync => int locsendSync;
GL.AB_sendNotes => int locsendNotes;

// Compute the smaller common divisor of 2 positive integers
// used to determinate the time sync/quater notes
// (the long substractive algorithm - but I love it)
fun int pgcd(int a, int b)
{
    if (a <= 0) return b;
    if (b <= 0) return a;
    while (a != b) {
        if (a > b) { a => int c; b => a; c => b; }
        b - a => b;
    }
    return a;
}

fun void resetSInfo()
{
    0 => TickCount;
    0 => QNCount;
    0 => SeqNum;
    -1 => stepPos; // adjust for note position
    -1 => prevSQLg;
    0 => hadNote => hadPos => secondPos => currentLg;
    // set high values for tickPerBeat & beatPerSeq
    48 => tickPerBeat; 32 => beatPerSeq;
    -2048 => prevNPos; -1024 => curNPos; 576 => intNgap;
    for (0 => int i; i < stepSize; i++) 0 => stepNb[i];
}

resetSInfo();

GL.Asig | 0x400 => GL.Asig; // Arturia BeatStep MGR OK

while (true)
{
    BeatStep => now;
    if (GL.Knkt[UnitSwitch] != KonnectedDevice) {
        GL.Knkt[UnitSwitch] => KonnectedDevice;
        defChannel => actChannel;
        if (KonnectedDevice >=0 && GL.UChans[KonnectedDevice] >=0) {
            GL.UChans[KonnectedDevice] => actChannel;
        }
        <<< ModuleIdt,":konnect:", KonnectedDevice, actChannel >>>;
    }
    while(BeatStep.recv(msg))
    {
        me.yield();
        msg.data1 => kode;
        //<<< "*", kode >>>;
        if (kode == 0xF8)
        {
            // <<< "*", "" >>>;
            // Clock tick 
            TickCount++; // Count ticks
            stepPos ++; // Tick number, one less than TickCount
            if (TickCount >= tickPerBeat)
            {
                0 => TickCount;
                QNCount++;
                if (locsendSync) OSCSend(1, DevNum, 0, 0xFF, 0, QNCount);
            }
            if (QNCount >= beatPerSeq)
            {
                // Update global switches if necessary 
                // so these commands take place synchronously at the start of a sequence
                GL.AB_sendSync => locsendSync;
                GL.AB_sendNotes => locsendNotes;
                0 => QNCount;
                SeqNum++;
                now => current;
                current - lastNow => Sdur;
                current => lastNow;
                if (Sdur != 0::ms)
                {
                    (60::second/Sdur)*beatPerSeq => float fbpm;
                    if (GL.AB_eTrace & 1) <<< ModuleIdt, ":BPM:", (60::second/Sdur)*beatPerSeq, "Seq:", SeqNum >>>;
                    (fbpm+0.5) $ int => int bpm; // BPM rounded to int
                    OSCSend(1, DevNum, 0, 0xFF, 5, bpm); // beats/seq also a sync. 
                    if (locsendSync) OSCSend(1, DevNum, 0, 0xFF, 8, SeqNum);
                    UT.xVal(50, bpm);
                }
            }
        }
        else if (kode == 0xFA)
        {
            // Sequence start
            if (GL.AB_eTrace & 2) <<< ModuleIdt, ":Start sequence.", "" >>>;
            resetSInfo();
            now => current => lastNow;
            OSCSend(1, DevNum, 0, 0xFF, 1, 0);
        }
        else if (kode == 0xFB)
        {
            // Sequence restart
            if (GL.AB_eTrace & 2) <<< ModuleIdt, ":Reprise sequence.", "" >>>;
            OSCSend(1, DevNum, 0, 0xFF, 3, 0);
        }
        else if (kode == 0xFC)
        {
            // Sequence Stop
            if (GL.AB_eTrace & 2) <<< ModuleIdt, ":End sequence.", "" >>>;
            OSCSend(1, DevNum, 0, 0xFF, 2, 0);
        }
        else if (kode == 128)
        {
            // Note off
            msg.data2 => CNote;
            if (GL.AB_eTrace & 2)  <<< ModuleIdt, ":At ", SeqNum, QNCount, stepPos, "Note off", CNote >>>;
            // Send the note somewhere
            if (locsendNotes) OSCSend(0, DevNum, actChannel, kode, CNote, 0);
        }
        else if (kode == 144)
        {
            // Note on
            //<<< "*", kode, 1 >>>;
            msg.data2 => CNote;
            //<<< "*", kode, 2 >>>;
            if (GL.AB_eTrace & 2)  <<< ModuleIdt, ":At ", SeqNum, QNCount, stepPos, "Note on", CNote >>>;
            //<<< "*", kode, 3 >>>;
            if (locsendNotes) OSCSend(0, DevNum, actChannel, kode, CNote, 63);
            // Send the note somewhere
            // Manage tempo/sequencer related things
            //<<< "*", kode, 4 >>>;
            if (stepPos >= 0 && stepPos < stepSize)
            {
                // <<< "*", kode, 5, stepPos, stepSize >>>;
                CNote => stepNb[stepPos]; // keep the note anyway
                pgcd(stepPos, intNgap) => intNgap;
                if (hadNote && (CNote == pivot))
                {
                    if (GL.AB_aTrace) <<< ModuleIdt, ":Found pivot", pivot, "at", stepPos >>>;
                    // We already have a "first"  and a 2nd note in the sequence
                    if (hadNote >= 2)
                    {
                        // if ((stepPos - validStart) >= (secondPos - hadPos))
                        {
                            
                            // Check this is also a coherent sequence coherent sequence for what we have found so far
                            // Loop from 0 possible new position
                            1 => int keep;
                            0 => int i; // loop start
                            // La position est-elle compatible avec  les données acquises ?
                            secondPos - hadPos => int lg; // loop length based upon the current limits
                            stepPos - validStart  => int lg2; // distance since previous limit
                            validStart - hadPos => int k; // 2nd pos starting
                            if (GL.AB_aTrace) <<< ModuleIdt, ":At", stepPos, "Check length", lg, "sequence starting at", k >>>;
                            if (lg != lg2) {
                                if (GL.AB_aTrace) <<< ModuleIdt, ":Sequences lengths", lg, lg2, "differ." >>>;
                                0 => keep;
                            }
                            for ( ; i < lg && keep ; )
                            {
                                if (stepNb[i] != stepNb[k])
                                {
                                    if (GL.AB_aTrace) <<< ModuleIdt, ":Notes", i, stepNb[i], "and", k, stepNb[k],"differ" >>>;
                                    0 => keep;
                                }
                                i++; k++;
                            }
                            if (keep)
                            {
                                // we have found the minimum sequence length
                                stepPos => validStart; 
                                3 => hadNote; // work is possibly done
                                if (currentLg < lg) lg => currentLg;
                                if (prevSQLg != currentLg) {
                                    currentLg => prevSQLg;
                                    intNgap => tickPerBeat;
                                    currentLg/intNgap => beatPerSeq;
                                    <<< "***** ArtBS:Sequence length is", currentLg >>>;
                                    <<< "***** Beat/Seq", beatPerSeq, "-- Beat div", intNgap >>>;
                                    // readjust all infos
                                    0 => TickCount;
                                    (stepPos / tickPerBeat) % beatPerSeq => QNCount;
                                    (stepPos - hadPos) / (tickPerBeat*beatPerSeq) => SeqNum;
                                    if (GL.AB_eTrace) <<< "***** Ajust:", SeqNum, QNCount, TickCount >>>;
                                    OSCSend(1, DevNum, 0, 0xFF, 4, beatPerSeq); // beats/seq
                                }
                            }
                            else
                            {
                                // Our 2nd find was a fake find next possible candidate
                                if (lg2 >= lg)
                                {
                                    1 => keep;
                                    for (secondPos + 1 => i; keep && i<= stepPos; i++)
                                    {
                                        if (stepNb[hadPos] == stepNb[i])
                                        {
                                            i => secondPos => validStart;
                                            0 => keep;
                                            if (GL.AB_aTrace) <<< ModuleIdt, ":Choosing new pos", secondPos, "as 2nd possible loop start" >>>;
                                            secondPos - hadPos => seqlg;
                                        }
                                    }
                                    2 => hadNote;
                                }
                            }
                        }
                    }
                    if (hadNote == 1)
                    {
                        // keep this a possible first loop item
                        if (GL.AB_aTrace) <<< ModuleIdt, ":Keep steppos", stepPos, "as 2nd possible loop start" >>>;
                        stepPos => secondPos => validStart; 
                        2 => hadNote;
                        secondPos - hadPos => seqlg;
                    }
                }
                if (!hadNote)
                {
                    if (stepPos < 0) 0 => stepPos;
                    stepPos => hadPos; 
                    1 => hadNote; CNote => pivot;
                    if (GL.AB_aTrace) <<< ModuleIdt, ":First note :", CNote, "at", hadPos >>>;
                }
            }
            
        }
        else
        {            
            //
            if (GL.AB_eTrace & 4) <<< ModuleIdt, ":unmanaged", msg.data1, msg.data2, msg.data3 >>>;
        }   
    }
}



