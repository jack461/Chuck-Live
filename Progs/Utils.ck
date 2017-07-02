/*

Various run-time utilities

Jean-Jacques Girardot - June 2017

License : WTFPL
http://www.wtfpl.net


*/

// we will be sending OSC
// send object
8642 => int xport;
"localhost" => string hostname;


public class UT {
    // Static variables
    static int trace;
    static int DefaultColor;
    static int FXcolor;
    static int SyntColor;
    static int SeqTickColor;
    
    // Instance variables
    int procId;
    
    
    meDcl(); // Initialize myself
    fun void meDcl() {
        ident() + 100 * me.id() => procId;
        if (trace & 1) {
            <<< "### Executing meDcl for", me.id(), procId >>>;
        }
    }
    
    fun void meExit() {
        if (trace & 1) {
            <<< "### Executing meExit for", me.id(), procId >>>;
        }
    }
    
    fun void is(Shred je) {
        ident() + 100 * je.id() => procId;
        if (trace & 1) {
            <<< "*** Hello ! I am shread", je.id(), procId >>>;
        }
    }
    
    static OscOut @ xmit;
    
    
    /// Access to arguments
    public static int getInt(int num, int def) {
        -7245123 => int val;
        string a;
        if ((me.args() > num) && ((me.arg(num) => a).length() > 0))
        {
            Std.atoi(a) => val;
        }
        if (val == -7245123) def => val;
        return val;
    }
    
    public static int ident() {
        return getInt(0,0);
    }
    
    // Return or allocate a "valid" channel number
    public static int channel() {
        getInt(1,-1) => int ch;
        if (ch < 0 || ch >= 8) Math.random2(0,7) => ch;
        return ch;
    }
    
    // Return a [0 100] volume value
    public static int volume() {
        return getInt(2,30);
    }
    
    public static string getStr(int pos) {
        if (pos < 0) return "";
        if (pos >= me.args()) return "";
        return me.arg(pos);
    }




    // Communication with the Processing front-end
    
    // Send a command
    public static void xCmd(int val)
    {
        xmit.start("/chuck/cmd");
        xmit.add(val);
        xmit.send();
    }

    // Trace a string
    public static void xTrc(string txt)
    {
        xmit.start("/chuck/txt");
        xmit.add(txt);
        xmit.send();
    }
    
    // Send a message with parameters
    public static void xTrc(string kmd, int p1, int p2, int p3, int p4)
    {
        xmit.start(kmd);
        xmit.add(p1).add(p2).add(p3).add(p4);
        xmit.send();
    }
    
    // Send a variable declaration
    public static void xDcl(string idt, int num, int typ, int fmt, int xpos, int ypos) {
        xmit.start("/chuck/dcl");
        xmit.add(idt);
        xmit.add(num);
        xmit.add(typ);
        xmit.add(fmt);
        xmit.add(xpos);
        xmit.add(ypos);
        xmit.send();
    }
    
    // Send a control as float value
    public static void xVal(int num, int val) {
        xmit.start("/chuck/ctl");
        xmit.add(num);
        xmit.add(val);
        xmit.send();
    }
    
    // Send a control as float value
    public static void xVal(int num, float val) {
        xmit.start("/chuck/ctl");
        xmit.add(num);
        xmit.add(val);
        xmit.send();
    }
    
    // Send info about channels volume
    public static void xChV(float val[]) {
        xmit.start("/chuck/vol");
        for (0 => int i; i<val.cap(); i++) {
            xmit.add(val[i]);
        }
        xmit.send();
    }
    
    // Remove a declared variable (or all if -1)
    public static void UnDclVars(int v) {
        xmit.start("/chuck/rmv");
        xmit.add(v);
        xmit.send();
    }
    
    
    public static void DclTckSeq() {
        // x & y corners
        8 => int xC; 4 => int yC;
        // par. numbers
        48 => int fP; // first par.
        UT.SeqTickColor => int pp; // parameter presentation
        // Col. 1
        UT.xDcl("Cr.Freq.",29, 2, pp, xC, yC);
        // Col. 2
        UT.xDcl("Md.Freq.",30, 2, pp, xC+4, yC);
        // Col. 3
        UT.xDcl("S.Vol.",31, 2, pp, xC+8, yC);
    }
    
    // Declare the synth parameters
    public static void DclSPars() {
        // x & y corners
        8 => int xC; 6 => int yC;
        // par. numbers
        32 => int fP; // first par.
        UT.SyntColor => int pp; // parameter presentation
        // Col. 1
        UT.xDcl("Mod.Lev.",fP, 2, pp, xC, yC);
        UT.xDcl("Mod.Freq.",fP+1, 2, pp, xC, yC+2);
        UT.xDcl("Scale",fP+2, 1, pp, xC, yC+4);
        UT.xDcl("Port.",fP+3, 2, pp, xC, yC+6);
        UT.xDcl("W.Mix",fP+4, 2, pp, xC, yC+8);
        // Col. 2
        UT.xDcl("H-Xcur.",fP+5, 2, pp, xC+4, yC);
        UT.xDcl("Attack.",fP+6, 2, pp, xC+4, yC+2);
        UT.xDcl("D.mode",fP+7, 1, pp, xC+4, yC+4);
        UT.xDcl("V.Amp.",fP+8, 2, pp, xC+4, yC+6);
        UT.xDcl("V.Freq.",fP+9, 2, pp, xC+4, yC+8);
        // Col 3
        UT.xDcl("L-Xcur.",fP+10, 2, pp, xC+8, yC);
        UT.xDcl("Release",fP+11, 2, pp, xC+8, yC+2);
        UT.xDcl("Reverb",fP+12, 2, pp, xC+8, yC+4);
        UT.xDcl("T.Amp.",fP+13, 2, pp, xC+8, yC+6);
        UT.xDcl("T.Freq.",fP+14, 2, pp, xC+8, yC+8);
    }
    
    // Declare All Parameters
    public static void DclAll() {
        
        // Declare some interesting variables
        UT.xDcl("General",0, 2, 0x1244,0,4); // general volume
        UT.xDcl("BPM", 50 , 1, 0xDD,0,14); // current BPM
        UT.xDcl("Preset", 51 , 1, UT.FXcolor,4,14);
        
        // Group parameters*/
        UT.xDcl("Groupe 1",1, 2, UT.SeqTickColor,4,4);
        UT.xDcl("Groupe 2",2, 2, UT.SyntColor,4,6);
        UT.xDcl("Groupe 3",3, 2, UT.DefaultColor,4,8);
        UT.xDcl("Groupe 4",4, 2, UT.DefaultColor,4,10);
        UT.xDcl("Groupe 5",5, 2, UT.FXcolor,4,12);
        
        // Synthesizer
        DclSPars();
        // Sequenceur
        DclTckSeq();
        
    }
    
    
}

// Initialize
0x22 => UT.DefaultColor;
0x77 => UT.FXcolor;
0x88 => UT.SyntColor;
0x44 => UT.SeqTickColor;
// aim the transmitter
new OscOut @=> UT.xmit;
// Initialize it
UT.xmit.dest(hostname, xport);

//===================================
// Make sure to loop...
<<< "Utilities: inited as", me.id() >>>;

UT.xTrc("Connected to trace");

GL.Asig | 2 => GL.Asig; // Utils OK
while (true) {
    hour => now;
}

