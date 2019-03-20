/* This is a simple additive layered drum machine

Sounds adapted from standard ChucK demos by Ge Wang, Perry Cook
This was part of ICMC 2009 demo

Modified 2009-2015 by Rebecca Fiebrink

It is recommended to run this on the command line rather than in MiniAudicle.

If you run it in MiniAudicle, you will need to set the Current Directory 
(in Preferences) to the directory containing the data/ subdirectory,
otherwise MiniAudicle won't be able to find the drum samples. 

*/

// create our OSC receiver
OscRecv recv;
// use port 12000
12000 => recv.port;
// start listening (launch thread)
recv.listen();

0 => int useTriggerFinger;

// Listen for this OSC message, containing one float
// Event oe will be triggered whenever this message arrives.
recv.event( "/wek/outputs, f" ) @=> OscEvent oe;

<<< "Listening for 1 classifier output (5 classes) on port 12000, message name /wek/outputs">>>; 


    //Master gain envelope
    Envelope e => dac;
    30::second => e.duration;
    0 => e.target => e.value;
    e.keyOn();
    
    
    //Beats-specific stuff:
    //.5::second => dur T;
    
    //The synthesis patch: envelope each of 5 parts individually
    Envelope e1 => e;
    Envelope e2 => e;
    Envelope e3 => e;
    Envelope e4 => e;
    Envelope e5 => e;
    0 => e1.value => e2.value => e3.value => e4.value => e5.value;
    0 => e1.target => e2.target => e3.target => e4.target => e5.target;
    60::second => e1.duration => e2.duration => e3.duration => e4.duration => dur defaultDuration;
    
        
    //This is called by the main code, only once after initialization, like a constructor
    fun void setup() {
        spork ~part1();
        spork ~part2();
        spork ~part3();
        spork ~part4();
        spork ~part5();
        e1.keyOn();
        e2.keyOn();
        e3.keyOn();
        e4.keyOn();
        e5.keyOn();
        turnOnUpTo(0);		
    }
    

    fun void setClass(int c) {
        		
            turnOnUpTo(c);
            turnOffAbove(c);
       
    }
    
    //drum parts
    fun void part1() {
        songOne();
    }
    
    fun void part2() {
        //spork ~songTwo();
        songTwo();
    }
    
    fun void part3() {
       // spork ~songThree();
        songThree();
    }
    
    fun void part4() {
        songFour();
    }
    
    fun void part5() {
        songFive();
    }
    
    fun void songOne() {               
    //construct the patch
    SndBuf buf => Gain g => e1;
    "data/End.wav" => buf.read;
    .1 => g.gain;
    
    // time loop
    while( true )
    {
        0 => buf.pos;
        Std.rand2f(.5,.6) => buf.gain;
        30::second => now;
    }
    }

    
    fun void songTwo() {               
    //construct the patch
    SndBuf buf => Gain g => e2;
    "data/ForrestGump.wav" => buf.read;
    .1 => g.gain;
    
    // time loop
    while( true )
    {
        0 => buf.pos;
        Std.rand2f(.5,.6) => buf.gain;
        30::second => now;
    }
    }

    
    fun void songThree() {               
    //construct the patch
    SndBuf buf => Gain g => e3;
    "data/Chanel.wav" => buf.read;
    .1 => g.gain;
    
    // time loop
    while( true )
    {
        0 => buf.pos;
        Std.rand2f(.5,.6) => buf.gain;
        30::second => now;
    }
    }
    
  fun void songFour() {
    // construct the patch
    SndBuf buf => Gain g => e4;
    "data/SuperRichKids.wav"=> buf.read;
    .1 => g.gain;
    
    // time loop
    while( true )
    {
        0 => buf.pos;
        Std.rand2f(.5,.6) => buf.gain;
        30::second => now;
    }
}

 fun void songFive() {
    //construct the patch
    SndBuf buf => Gain g => e5;
    "data/Monks.wav" => buf.read;
    .1 => g.gain;
    
    // time loop
    while( true )
    {
        0 => buf.pos;
        Std.rand2f(.1,.2) => buf.gain;
        30::second => now;
    }
}


 // fun void melody2() {
 //   SinOsc s => JCRev r => e3;
 //  .05 => s.gain;
 //   .25 => r.mix;
    
    // scale (in semitones)
 //   [ 0, 2, 4, 7, 9 ] @=> int scale[];
    
    // infinite time loop
 //   while( true )
 //   {
        // get note class
 //       scale[ Math.random2(0,4) ] => float freq;
    // get the final freq
 //   Std.mtof( 69 + (Std.rand2(0,3)*12 + freq) ) => s.freq;
    // reset phase for extra bandwidth
 //   0 => s.phase;
    
    // advance time
 //   if( Std.randf() > -.5 ) .25::second => now;
 //   else .5::second => now;
//}
//}






//Control layering via envelopes:
fun void turnOnUpTo(float p) {
    1 => e1.target;
    if (p > 0) 
        1 => e2.target;
    if (p > 1)
        1 => e3.target;
    if (p > 2) 
        1 => e4.target;
    if (p > 3) 
        1 => e5.target;
}

fun void turnOffAbove(float p) {
    if (p < 4) 
        0 => e5.target;
    if (p < 3) 
        0 => e4.target;
    if (p < 2)
        0 => e3.target;
    if (p < 1) 
        0 => e2.target;
}


//Be quiet! If you want to improve efficiency here, you could also stop
//other processing
fun void silent() {
    0 => e.target;
}

//Make sound!
fun void sound() {
    1 => e.target;
}

fun void waitForEvent() {
    // infinite event loop
    while ( true )
    {
        // wait for our OSC message to arrive
        oe => now;
        
        // grab the next message from the queue. 
        while ( oe.nextMsg() != 0 )
        { 
            // getFloat fetches the expected float (as indicated by "f")
			//We can cast it to an int:
            oe.getFloat()$int => int c;
            setClass(c-1);
        }
    }   
    
}

setup();
sound();
spork ~waitForEvent();
10::hour => now;