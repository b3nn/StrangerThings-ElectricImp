// Stranger Things Xmas Lights

const NUMPIXELS = 100;      // Number of total neopixels in our light array
const LETTERDELAY = 0.8;    // How long each letter should stay fully light up

// Not 100% sure on the Imp's memory management, so we have a few constrants to help 
// it avoid crashing from too many messages or to large of a message to display

const MAX_MSGS = 10;        // Max number of queued message we allow to be saved
const MAX_MSG_SIZE = 200;   // Max number of letters in each message
const CHECKEVERY = 30;      // How many seconds between each time we check for new messages in the queue

// Globals for our Message Queue
MESSAGES <- [];
MSG_IS_TYPING <- false;

// Lookup is our LED Neopixel light position to Letter Mapping table
LOOKUP <- {};
LOOKUP.A <- 9;
LOOKUP.B <- 11;
LOOKUP.C <- 13;
LOOKUP.D <- 15;
LOOKUP.E <- 17;
LOOKUP.F <- 19;
LOOKUP.G <- 21;
LOOKUP.H <- 23;

LOOKUP.I <- 48;
LOOKUP.J <- 43;
LOOKUP.K <- 41;
LOOKUP.L <- 39;
LOOKUP.M <- 37;
LOOKUP.N <- 35;
LOOKUP.O <- 33;
LOOKUP.P <- 32;
LOOKUP.Q <- 29;

LOOKUP.R <- 52;
LOOKUP.S <- 53;
LOOKUP.T <- 55;
LOOKUP.U <- 57;
LOOKUP.V <- 59;
LOOKUP.W <- 61;
LOOKUP.X <- 63;
LOOKUP.Y <- 65;
LOOKUP.Z <- 69;

// Our Bulb Colors
GREEN  <- [0x88,0x00,0x00];
RED    <- [0x00,0x88,0x00];
ORANGE <- [0x20,0x88,0x00];
BLUE   <- [0x00,0x00,0x88];
WHITE  <- [0x88,0x88,0x88];
BLACK  <- [0,0,0];


// We'll use SPI to control the NeoPixel lights, you've got two options on the Imps
// spi257 means we wire up Pin 2 on the Imp to talk to the neopixels
spi <- hardware.spi257;

// Extra Pins for playing Audio Files on a connected Adafuit SoundFX Board (don't use the SPI ones)
audio <- hardware.pin1;
audio.configure(DIGITAL_OUT, 1);
audioFlicker <- hardware.pin8;
audioFlicker.configure(DIGITAL_OUT, 1);
audioStartMsg <- hardware.pin9;
audioStartMsg.configure(DIGITAL_OUT, 1);


server.log("Device started (version: " + imp.getsoftwareversion() + ")");
server.log(imp.getmacaddress());


/* Code from https://github.com/ersatzavian */


/*
Copyright (C) 2014 electric imp, inc.
Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
and associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, 
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial 
portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE 
AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/* WS2812 "Neopixel" LED Driver
 * 
 * Uses SPI to emulate 1-wire
 * http://learn.adafruit.com/adafruit-neopixel-uberguide/advanced-coding
 *
 */

// constants for using SPI to emulate 1-wire
const BYTESPERPIXEL = 27;
const BYTESPERCOLOR = 9; // BYTESPERPIXEL / 3
const SPICLK = 7500; // SPI clock speed in kHz
const DELAY = 0.025; // For NeoPixel Latching

// this string contains the "equivalent waveform" to send the numbers 0-255 over SPI at 7.5MHz.
// 9 bytes of string are required to send 1 byte of emulated 1-wire data. 
// For example, to add a byte containing the number "14" to the frame:
// bits.slice(14 * 9, (14 * 9) + 9);
bits <- ["\xE0\x70\x38\x1C\x0E\x07\x03\x81\xC0",
                "\xE0\x70\x38\x1C\x0E\x07\x03\x81\xF8",
                "\xE0\x70\x38\x1C\x0E\x07\x03\xF1\xC0",
                "\xE0\x70\x38\x1C\x0E\x07\x03\xF1\xF8",
                "\xE0\x70\x38\x1C\x0E\x07\xE3\x81\xC0",
                "\xE0\x70\x38\x1C\x0E\x07\xE3\x81\xF8",
                "\xE0\x70\x38\x1C\x0E\x07\xE3\xF1\xC0",
                "\xE0\x70\x38\x1C\x0E\x07\xE3\xF1\xF8",
                "\xE0\x70\x38\x1C\x0F\xC7\x03\x81\xC0",
                "\xE0\x70\x38\x1C\x0F\xC7\x03\x81\xF8",
                "\xE0\x70\x38\x1C\x0F\xC7\x03\xF1\xC0",
                "\xE0\x70\x38\x1C\x0F\xC7\x03\xF1\xF8",
                "\xE0\x70\x38\x1C\x0F\xC7\xE3\x81\xC0",
                "\xE0\x70\x38\x1C\x0F\xC7\xE3\x81\xF8",
                "\xE0\x70\x38\x1C\x0F\xC7\xE3\xF1\xC0",
                "\xE0\x70\x38\x1C\x0F\xC7\xE3\xF1\xF8",
                "\xE0\x70\x38\x1F\x8E\x07\x03\x81\xC0",
                "\xE0\x70\x38\x1F\x8E\x07\x03\x81\xF8",
                "\xE0\x70\x38\x1F\x8E\x07\x03\xF1\xC0",
                "\xE0\x70\x38\x1F\x8E\x07\x03\xF1\xF8",
                "\xE0\x70\x38\x1F\x8E\x07\xE3\x81\xC0",
                "\xE0\x70\x38\x1F\x8E\x07\xE3\x81\xF8",
                "\xE0\x70\x38\x1F\x8E\x07\xE3\xF1\xC0",
                "\xE0\x70\x38\x1F\x8E\x07\xE3\xF1\xF8",
                "\xE0\x70\x38\x1F\x8F\xC7\x03\x81\xC0",
                "\xE0\x70\x38\x1F\x8F\xC7\x03\x81\xF8",
                "\xE0\x70\x38\x1F\x8F\xC7\x03\xF1\xC0",
                "\xE0\x70\x38\x1F\x8F\xC7\x03\xF1\xF8",
                "\xE0\x70\x38\x1F\x8F\xC7\xE3\x81\xC0",
                "\xE0\x70\x38\x1F\x8F\xC7\xE3\x81\xF8",
                "\xE0\x70\x38\x1F\x8F\xC7\xE3\xF1\xC0",
                "\xE0\x70\x38\x1F\x8F\xC7\xE3\xF1\xF8",
                "\xE0\x70\x3F\x1C\x0E\x07\x03\x81\xC0",
                "\xE0\x70\x3F\x1C\x0E\x07\x03\x81\xF8",
                "\xE0\x70\x3F\x1C\x0E\x07\x03\xF1\xC0",
                "\xE0\x70\x3F\x1C\x0E\x07\x03\xF1\xF8",
                "\xE0\x70\x3F\x1C\x0E\x07\xE3\x81\xC0",
                "\xE0\x70\x3F\x1C\x0E\x07\xE3\x81\xF8",
                "\xE0\x70\x3F\x1C\x0E\x07\xE3\xF1\xC0",
                "\xE0\x70\x3F\x1C\x0E\x07\xE3\xF1\xF8",
                "\xE0\x70\x3F\x1C\x0F\xC7\x03\x81\xC0",
                "\xE0\x70\x3F\x1C\x0F\xC7\x03\x81\xF8",
                "\xE0\x70\x3F\x1C\x0F\xC7\x03\xF1\xC0",
                "\xE0\x70\x3F\x1C\x0F\xC7\x03\xF1\xF8",
                "\xE0\x70\x3F\x1C\x0F\xC7\xE3\x81\xC0",
                "\xE0\x70\x3F\x1C\x0F\xC7\xE3\x81\xF8",
                "\xE0\x70\x3F\x1C\x0F\xC7\xE3\xF1\xC0",
                "\xE0\x70\x3F\x1C\x0F\xC7\xE3\xF1\xF8",
                "\xE0\x70\x3F\x1F\x8E\x07\x03\x81\xC0",
                "\xE0\x70\x3F\x1F\x8E\x07\x03\x81\xF8",
                "\xE0\x70\x3F\x1F\x8E\x07\x03\xF1\xC0",
                "\xE0\x70\x3F\x1F\x8E\x07\x03\xF1\xF8",
                "\xE0\x70\x3F\x1F\x8E\x07\xE3\x81\xC0",
                "\xE0\x70\x3F\x1F\x8E\x07\xE3\x81\xF8",
                "\xE0\x70\x3F\x1F\x8E\x07\xE3\xF1\xC0",
                "\xE0\x70\x3F\x1F\x8E\x07\xE3\xF1\xF8",
                "\xE0\x70\x3F\x1F\x8F\xC7\x03\x81\xC0",
                "\xE0\x70\x3F\x1F\x8F\xC7\x03\x81\xF8",
                "\xE0\x70\x3F\x1F\x8F\xC7\x03\xF1\xC0",
                "\xE0\x70\x3F\x1F\x8F\xC7\x03\xF1\xF8",
                "\xE0\x70\x3F\x1F\x8F\xC7\xE3\x81\xC0",
                "\xE0\x70\x3F\x1F\x8F\xC7\xE3\x81\xF8",
                "\xE0\x70\x3F\x1F\x8F\xC7\xE3\xF1\xC0",
                "\xE0\x70\x3F\x1F\x8F\xC7\xE3\xF1\xF8",
                "\xE0\x7E\x38\x1C\x0E\x07\x03\x81\xC0",
                "\xE0\x7E\x38\x1C\x0E\x07\x03\x81\xF8",
                "\xE0\x7E\x38\x1C\x0E\x07\x03\xF1\xC0",
                "\xE0\x7E\x38\x1C\x0E\x07\x03\xF1\xF8",
                "\xE0\x7E\x38\x1C\x0E\x07\xE3\x81\xC0",
                "\xE0\x7E\x38\x1C\x0E\x07\xE3\x81\xF8",
                "\xE0\x7E\x38\x1C\x0E\x07\xE3\xF1\xC0",
                "\xE0\x7E\x38\x1C\x0E\x07\xE3\xF1\xF8",
                "\xE0\x7E\x38\x1C\x0F\xC7\x03\x81\xC0",
                "\xE0\x7E\x38\x1C\x0F\xC7\x03\x81\xF8",
                "\xE0\x7E\x38\x1C\x0F\xC7\x03\xF1\xC0",
                "\xE0\x7E\x38\x1C\x0F\xC7\x03\xF1\xF8",
                "\xE0\x7E\x38\x1C\x0F\xC7\xE3\x81\xC0",
                "\xE0\x7E\x38\x1C\x0F\xC7\xE3\x81\xF8",
                "\xE0\x7E\x38\x1C\x0F\xC7\xE3\xF1\xC0",
                "\xE0\x7E\x38\x1C\x0F\xC7\xE3\xF1\xF8",
                "\xE0\x7E\x38\x1F\x8E\x07\x03\x81\xC0",
                "\xE0\x7E\x38\x1F\x8E\x07\x03\x81\xF8",
                "\xE0\x7E\x38\x1F\x8E\x07\x03\xF1\xC0",
                "\xE0\x7E\x38\x1F\x8E\x07\x03\xF1\xF8",
                "\xE0\x7E\x38\x1F\x8E\x07\xE3\x81\xC0",
                "\xE0\x7E\x38\x1F\x8E\x07\xE3\x81\xF8",
                "\xE0\x7E\x38\x1F\x8E\x07\xE3\xF1\xC0",
                "\xE0\x7E\x38\x1F\x8E\x07\xE3\xF1\xF8",
                "\xE0\x7E\x38\x1F\x8F\xC7\x03\x81\xC0",
                "\xE0\x7E\x38\x1F\x8F\xC7\x03\x81\xF8",
                "\xE0\x7E\x38\x1F\x8F\xC7\x03\xF1\xC0",
                "\xE0\x7E\x38\x1F\x8F\xC7\x03\xF1\xF8",
                "\xE0\x7E\x38\x1F\x8F\xC7\xE3\x81\xC0",
                "\xE0\x7E\x38\x1F\x8F\xC7\xE3\x81\xF8",
                "\xE0\x7E\x38\x1F\x8F\xC7\xE3\xF1\xC0",
                "\xE0\x7E\x38\x1F\x8F\xC7\xE3\xF1\xF8",
                "\xE0\x7E\x3F\x1C\x0E\x07\x03\x81\xC0",
                "\xE0\x7E\x3F\x1C\x0E\x07\x03\x81\xF8",
                "\xE0\x7E\x3F\x1C\x0E\x07\x03\xF1\xC0",
                "\xE0\x7E\x3F\x1C\x0E\x07\x03\xF1\xF8",
                "\xE0\x7E\x3F\x1C\x0E\x07\xE3\x81\xC0",
                "\xE0\x7E\x3F\x1C\x0E\x07\xE3\x81\xF8",
                "\xE0\x7E\x3F\x1C\x0E\x07\xE3\xF1\xC0",
                "\xE0\x7E\x3F\x1C\x0E\x07\xE3\xF1\xF8",
                "\xE0\x7E\x3F\x1C\x0F\xC7\x03\x81\xC0",
                "\xE0\x7E\x3F\x1C\x0F\xC7\x03\x81\xF8",
                "\xE0\x7E\x3F\x1C\x0F\xC7\x03\xF1\xC0",
                "\xE0\x7E\x3F\x1C\x0F\xC7\x03\xF1\xF8",
                "\xE0\x7E\x3F\x1C\x0F\xC7\xE3\x81\xC0",
                "\xE0\x7E\x3F\x1C\x0F\xC7\xE3\x81\xF8",
                "\xE0\x7E\x3F\x1C\x0F\xC7\xE3\xF1\xC0",
                "\xE0\x7E\x3F\x1C\x0F\xC7\xE3\xF1\xF8",
                "\xE0\x7E\x3F\x1F\x8E\x07\x03\x81\xC0",
                "\xE0\x7E\x3F\x1F\x8E\x07\x03\x81\xF8",
                "\xE0\x7E\x3F\x1F\x8E\x07\x03\xF1\xC0",
                "\xE0\x7E\x3F\x1F\x8E\x07\x03\xF1\xF8",
                "\xE0\x7E\x3F\x1F\x8E\x07\xE3\x81\xC0",
                "\xE0\x7E\x3F\x1F\x8E\x07\xE3\x81\xF8",
                "\xE0\x7E\x3F\x1F\x8E\x07\xE3\xF1\xC0",
                "\xE0\x7E\x3F\x1F\x8E\x07\xE3\xF1\xF8",
                "\xE0\x7E\x3F\x1F\x8F\xC7\x03\x81\xC0",
                "\xE0\x7E\x3F\x1F\x8F\xC7\x03\x81\xF8",
                "\xE0\x7E\x3F\x1F\x8F\xC7\x03\xF1\xC0",
                "\xE0\x7E\x3F\x1F\x8F\xC7\x03\xF1\xF8",
                "\xE0\x7E\x3F\x1F\x8F\xC7\xE3\x81\xC0",
                "\xE0\x7E\x3F\x1F\x8F\xC7\xE3\x81\xF8",
                "\xE0\x7E\x3F\x1F\x8F\xC7\xE3\xF1\xC0",
                "\xE0\x7E\x3F\x1F\x8F\xC7\xE3\xF1\xF8",
                "\xFC\x70\x38\x1C\x0E\x07\x03\x81\xC0",
                "\xFC\x70\x38\x1C\x0E\x07\x03\x81\xF8",
                "\xFC\x70\x38\x1C\x0E\x07\x03\xF1\xC0",
                "\xFC\x70\x38\x1C\x0E\x07\x03\xF1\xF8",
                "\xFC\x70\x38\x1C\x0E\x07\xE3\x81\xC0",
                "\xFC\x70\x38\x1C\x0E\x07\xE3\x81\xF8",
                "\xFC\x70\x38\x1C\x0E\x07\xE3\xF1\xC0",
                "\xFC\x70\x38\x1C\x0E\x07\xE3\xF1\xF8",
                "\xFC\x70\x38\x1C\x0F\xC7\x03\x81\xC0",
                "\xFC\x70\x38\x1C\x0F\xC7\x03\x81\xF8",
                "\xFC\x70\x38\x1C\x0F\xC7\x03\xF1\xC0",
                "\xFC\x70\x38\x1C\x0F\xC7\x03\xF1\xF8",
                "\xFC\x70\x38\x1C\x0F\xC7\xE3\x81\xC0",
                "\xFC\x70\x38\x1C\x0F\xC7\xE3\x81\xF8",
                "\xFC\x70\x38\x1C\x0F\xC7\xE3\xF1\xC0",
                "\xFC\x70\x38\x1C\x0F\xC7\xE3\xF1\xF8",
                "\xFC\x70\x38\x1F\x8E\x07\x03\x81\xC0",
                "\xFC\x70\x38\x1F\x8E\x07\x03\x81\xF8",
                "\xFC\x70\x38\x1F\x8E\x07\x03\xF1\xC0",
                "\xFC\x70\x38\x1F\x8E\x07\x03\xF1\xF8",
                "\xFC\x70\x38\x1F\x8E\x07\xE3\x81\xC0",
                "\xFC\x70\x38\x1F\x8E\x07\xE3\x81\xF8",
                "\xFC\x70\x38\x1F\x8E\x07\xE3\xF1\xC0",
                "\xFC\x70\x38\x1F\x8E\x07\xE3\xF1\xF8",
                "\xFC\x70\x38\x1F\x8F\xC7\x03\x81\xC0",
                "\xFC\x70\x38\x1F\x8F\xC7\x03\x81\xF8",
                "\xFC\x70\x38\x1F\x8F\xC7\x03\xF1\xC0",
                "\xFC\x70\x38\x1F\x8F\xC7\x03\xF1\xF8",
                "\xFC\x70\x38\x1F\x8F\xC7\xE3\x81\xC0",
                "\xFC\x70\x38\x1F\x8F\xC7\xE3\x81\xF8",
                "\xFC\x70\x38\x1F\x8F\xC7\xE3\xF1\xC0",
                "\xFC\x70\x38\x1F\x8F\xC7\xE3\xF1\xF8",
                "\xFC\x70\x3F\x1C\x0E\x07\x03\x81\xC0",
                "\xFC\x70\x3F\x1C\x0E\x07\x03\x81\xF8",
                "\xFC\x70\x3F\x1C\x0E\x07\x03\xF1\xC0",
                "\xFC\x70\x3F\x1C\x0E\x07\x03\xF1\xF8",
                "\xFC\x70\x3F\x1C\x0E\x07\xE3\x81\xC0",
                "\xFC\x70\x3F\x1C\x0E\x07\xE3\x81\xF8",
                "\xFC\x70\x3F\x1C\x0E\x07\xE3\xF1\xC0",
                "\xFC\x70\x3F\x1C\x0E\x07\xE3\xF1\xF8",
                "\xFC\x70\x3F\x1C\x0F\xC7\x03\x81\xC0",
                "\xFC\x70\x3F\x1C\x0F\xC7\x03\x81\xF8",
                "\xFC\x70\x3F\x1C\x0F\xC7\x03\xF1\xC0",
                "\xFC\x70\x3F\x1C\x0F\xC7\x03\xF1\xF8",
                "\xFC\x70\x3F\x1C\x0F\xC7\xE3\x81\xC0",
                "\xFC\x70\x3F\x1C\x0F\xC7\xE3\x81\xF8",
                "\xFC\x70\x3F\x1C\x0F\xC7\xE3\xF1\xC0",
                "\xFC\x70\x3F\x1C\x0F\xC7\xE3\xF1\xF8",
                "\xFC\x70\x3F\x1F\x8E\x07\x03\x81\xC0",
                "\xFC\x70\x3F\x1F\x8E\x07\x03\x81\xF8",
                "\xFC\x70\x3F\x1F\x8E\x07\x03\xF1\xC0",
                "\xFC\x70\x3F\x1F\x8E\x07\x03\xF1\xF8",
                "\xFC\x70\x3F\x1F\x8E\x07\xE3\x81\xC0",
                "\xFC\x70\x3F\x1F\x8E\x07\xE3\x81\xF8",
                "\xFC\x70\x3F\x1F\x8E\x07\xE3\xF1\xC0",
                "\xFC\x70\x3F\x1F\x8E\x07\xE3\xF1\xF8",
                "\xFC\x70\x3F\x1F\x8F\xC7\x03\x81\xC0",
                "\xFC\x70\x3F\x1F\x8F\xC7\x03\x81\xF8",
                "\xFC\x70\x3F\x1F\x8F\xC7\x03\xF1\xC0",
                "\xFC\x70\x3F\x1F\x8F\xC7\x03\xF1\xF8",
                "\xFC\x70\x3F\x1F\x8F\xC7\xE3\x81\xC0",
                "\xFC\x70\x3F\x1F\x8F\xC7\xE3\x81\xF8",
                "\xFC\x70\x3F\x1F\x8F\xC7\xE3\xF1\xC0",
                "\xFC\x70\x3F\x1F\x8F\xC7\xE3\xF1\xF8",
                "\xFC\x7E\x38\x1C\x0E\x07\x03\x81\xC0",
                "\xFC\x7E\x38\x1C\x0E\x07\x03\x81\xF8",
                "\xFC\x7E\x38\x1C\x0E\x07\x03\xF1\xC0",
                "\xFC\x7E\x38\x1C\x0E\x07\x03\xF1\xF8",
                "\xFC\x7E\x38\x1C\x0E\x07\xE3\x81\xC0",
                "\xFC\x7E\x38\x1C\x0E\x07\xE3\x81\xF8",
                "\xFC\x7E\x38\x1C\x0E\x07\xE3\xF1\xC0",
                "\xFC\x7E\x38\x1C\x0E\x07\xE3\xF1\xF8",
                "\xFC\x7E\x38\x1C\x0F\xC7\x03\x81\xC0",
                "\xFC\x7E\x38\x1C\x0F\xC7\x03\x81\xF8",
                "\xFC\x7E\x38\x1C\x0F\xC7\x03\xF1\xC0",
                "\xFC\x7E\x38\x1C\x0F\xC7\x03\xF1\xF8",
                "\xFC\x7E\x38\x1C\x0F\xC7\xE3\x81\xC0",
                "\xFC\x7E\x38\x1C\x0F\xC7\xE3\x81\xF8",
                "\xFC\x7E\x38\x1C\x0F\xC7\xE3\xF1\xC0",
                "\xFC\x7E\x38\x1C\x0F\xC7\xE3\xF1\xF8",
                "\xFC\x7E\x38\x1F\x8E\x07\x03\x81\xC0",
                "\xFC\x7E\x38\x1F\x8E\x07\x03\x81\xF8",
                "\xFC\x7E\x38\x1F\x8E\x07\x03\xF1\xC0",
                "\xFC\x7E\x38\x1F\x8E\x07\x03\xF1\xF8",
                "\xFC\x7E\x38\x1F\x8E\x07\xE3\x81\xC0",
                "\xFC\x7E\x38\x1F\x8E\x07\xE3\x81\xF8",
                "\xFC\x7E\x38\x1F\x8E\x07\xE3\xF1\xC0",
                "\xFC\x7E\x38\x1F\x8E\x07\xE3\xF1\xF8",
                "\xFC\x7E\x38\x1F\x8F\xC7\x03\x81\xC0",
                "\xFC\x7E\x38\x1F\x8F\xC7\x03\x81\xF8",
                "\xFC\x7E\x38\x1F\x8F\xC7\x03\xF1\xC0",
                "\xFC\x7E\x38\x1F\x8F\xC7\x03\xF1\xF8",
                "\xFC\x7E\x38\x1F\x8F\xC7\xE3\x81\xC0",
                "\xFC\x7E\x38\x1F\x8F\xC7\xE3\x81\xF8",
                "\xFC\x7E\x38\x1F\x8F\xC7\xE3\xF1\xC0",
                "\xFC\x7E\x38\x1F\x8F\xC7\xE3\xF1\xF8",
                "\xFC\x7E\x3F\x1C\x0E\x07\x03\x81\xC0",
                "\xFC\x7E\x3F\x1C\x0E\x07\x03\x81\xF8",
                "\xFC\x7E\x3F\x1C\x0E\x07\x03\xF1\xC0",
                "\xFC\x7E\x3F\x1C\x0E\x07\x03\xF1\xF8",
                "\xFC\x7E\x3F\x1C\x0E\x07\xE3\x81\xC0",
                "\xFC\x7E\x3F\x1C\x0E\x07\xE3\x81\xF8",
                "\xFC\x7E\x3F\x1C\x0E\x07\xE3\xF1\xC0",
                "\xFC\x7E\x3F\x1C\x0E\x07\xE3\xF1\xF8",
                "\xFC\x7E\x3F\x1C\x0F\xC7\x03\x81\xC0",
                "\xFC\x7E\x3F\x1C\x0F\xC7\x03\x81\xF8",
                "\xFC\x7E\x3F\x1C\x0F\xC7\x03\xF1\xC0",
                "\xFC\x7E\x3F\x1C\x0F\xC7\x03\xF1\xF8",
                "\xFC\x7E\x3F\x1C\x0F\xC7\xE3\x81\xC0",
                "\xFC\x7E\x3F\x1C\x0F\xC7\xE3\x81\xF8",
                "\xFC\x7E\x3F\x1C\x0F\xC7\xE3\xF1\xC0",
                "\xFC\x7E\x3F\x1C\x0F\xC7\xE3\xF1\xF8",
                "\xFC\x7E\x3F\x1F\x8E\x07\x03\x81\xC0",
                "\xFC\x7E\x3F\x1F\x8E\x07\x03\x81\xF8",
                "\xFC\x7E\x3F\x1F\x8E\x07\x03\xF1\xC0",
                "\xFC\x7E\x3F\x1F\x8E\x07\x03\xF1\xF8",
                "\xFC\x7E\x3F\x1F\x8E\x07\xE3\x81\xC0",
                "\xFC\x7E\x3F\x1F\x8E\x07\xE3\x81\xF8",
                "\xFC\x7E\x3F\x1F\x8E\x07\xE3\xF1\xC0",
                "\xFC\x7E\x3F\x1F\x8E\x07\xE3\xF1\xF8",
                "\xFC\x7E\x3F\x1F\x8F\xC7\x03\x81\xC0",
                "\xFC\x7E\x3F\x1F\x8F\xC7\x03\x81\xF8",
                "\xFC\x7E\x3F\x1F\x8F\xC7\x03\xF1\xC0",
                "\xFC\x7E\x3F\x1F\x8F\xC7\x03\xF1\xF8",
                "\xFC\x7E\x3F\x1F\x8F\xC7\xE3\x81\xC0",
                "\xFC\x7E\x3F\x1F\x8F\xC7\xE3\x81\xF8",
                "\xFC\x7E\x3F\x1F\x8F\xC7\xE3\xF1\xC0",
                "\xFC\x7E\x3F\x1F\x8F\xC7\xE3\xF1\xF8"];
// This string holds three "zero" bytes [0,0,0]; clears a pixel when written to the frame
const clearString = "\xE0\x70\x38\x1C\x0E\x07\x03\x81\xC0\xE0\x70\x38\x1C\x0E\x07\x03\x81\xC0\xE0\x70\x38\x1C\x0E\x07\x03\x81\xC0";

/* CLASS AND FUNCTION DEFINITIONS --------------------------------------------*/

class neoPixels {
    spi = null;
    frameSize = null;
    frame = null;

    // _spi - A configured spi (MSB_FIRST, 7.5MHz)
    // _frameSize - Number of Pixels per frame
    constructor(_spi, _frameSize) {
        this.spi = _spi;
        this.frameSize = _frameSize;
        this.frame = blob(frameSize*27 + 1);
        
        clearFrame();
        writeFrame();
    }

    // sets a pixel in the frame buffer
    // but does not write it to the pixel strip
    // color is an array of the form [r, g, b]
    function writePixel(p, color) {
        frame.seek(p*BYTESPERPIXEL);
        // red and green are swapped for some reason, so swizzle them back 
        frame.writestring(bits[color[1]]);
        frame.writestring(bits[color[0]]);
        frame.writestring(bits[color[2]]);    
    }
    
    // Clears the frame buffer
    // but does not write it to the pixel strip
    function clearFrame() {
        frame.seek(0);
        for (local p = 0; p < frameSize; p++) frame.writestring(clearString);
        frame.writen(0x00,'c');
    }
    
    // writes the frame buffer to the pixel strip
    // ie - this function changes the pixel strip
    function writeFrame() {
        spi.write(frame);
    }
}

/////////////////////////////////
//////////// Stranger Things ///////////
/////////////////////////////////


// Setup our NeoPixel Strip
spi.configure(MSB_FIRST, SPICLK);
pixelStrip <- neoPixels(spi, NUMPIXELS);


/*
 * getBulbColor(bulb_number)
 *
 * Returns which color to make the neopixel so the light matches the C9 cover
 */
function getBulbColor(bulb_number){
    local remainer = bulb_number % 5;
    local color;
    
    switch(remainer){
        case 0:
            color = RED;
            break;
        case 1:
            color = WHITE;
            break;
        case 2:
            color = ORANGE;
            break;
        case 3:
            color = BLUE;
            break;
        case 4:
            color = GREEN;
            break;            
    }
    return color;
}

/*
 * setColor(color)
 *
 * Sets all NeoPixels to the color passed in
 */
function setColor(color) {
    pixelStrip.clearFrame();
    pixelStrip.writeFrame();
    for (local i=0; i<NUMPIXELS; i++) {
        pixelStrip.writePixel(i, color);
    }
    pixelStrip.writeFrame();
}

/*
 * setRanBulb()
 *
 * Turns off all Neopixels, then turns one random one on
 */
function setRanBulb() {
    pixelStrip.clearFrame();
    pixelStrip.writeFrame();
    local i = ran(NUMPIXELS);
    pixelStrip.writePixel(i, getBulbColor(i));
    pixelStrip.writeFrame();
}

/*
 * ran(max)
 *
 * A useful random number generator function (max should be our number of neopixels)
 */
function ran(max) {
  local roll = 1.0 * math.rand() / RAND_MAX;
  roll = roll * max;
  return roll.tointeger();
}

/*
 * fadeOnOff(led)
 *
 * Fades on then off the neopixel above a letter on the board
 * Pass in the pixel number (so this is after you lookup which pixel to light)
 */
function fadeOnOff(led){
    local fadetime = 0.02;
    local x = 0;
    local bulbcolor;
    
    bulbcolor = getBulbColor(led);
    local r, g, b;
    r = bulbcolor[0];
    g = bulbcolor[1];
    b = bulbcolor[2];
    
    startBulbSound();
    
            
    for(; x < 200; x=x+10){
        local this_r = r * x / 200;
        local this_g = g * x / 200;
        local this_b = b * x / 200;
        
        pixelStrip.writePixel(led, [this_r,this_g,this_b]);
        pixelStrip.writeFrame();
        imp.sleep(fadetime); 
        stopBulbSound();
    }
    
    
    imp.sleep(LETTERDELAY);
    
    for(; x >= 0; x=x-10){
        local this_r = r * x / 200;
        local this_g = g * x / 200;
        local this_b = b * x / 200;
        
        pixelStrip.writePixel(led, [this_r,this_g,this_b]);
        pixelStrip.writeFrame();
        imp.sleep(fadetime);        
    }    

}

/*
 * addMsg(msg)
 *
 * This gets called to handle new remote messages which are passed in.
 * Save them to a queue in case we're already displaying a message.
 */
function addMsg(msg){
    if (MESSAGES.len() < MAX_MSGS){
        if (msg.len() < MAX_MSG_SIZE){
            MESSAGES.push(msg); 
            server.log("Msg Added: " + msg)
            checkMsgQueue();
            return true;
        }
    }
    server.log("ERROR - MSG Rejected: " + msg)
    return false;
}

/*
 * displayMsg(msg)
 *
 * Called with the MESSAGES queue is popped. This handles looping over the
 * message string, looking up the neopixel light number, and delays.
 */
function displayMsg(msg){
    MSG_IS_TYPING = true;
    server.log("START DISPLAY: " + msg)
    
    blinkLights();
    
    
    foreach(letter in msg){
        setColor(BLACK);
        imp.sleep(DELAY);
        
        // This will limit us to A-Z
        local i = -1;
        if((letter >= 65) && (letter <= 90)){
            i = LOOKUP[letter.tochar()];
        } 
        
        
        if ((i >= 0) && (i < NUMPIXELS )){
            fadeOnOff(i)            
        } else {
            imp.sleep(LETTERDELAY);
        }

    }
    
    imp.sleep(1);
    flickerLights();
    
    MSG_IS_TYPING = false;
}

/*
 * blinkLights()
 *
 * Blink some random neopixels.
 */
function blinkLights(){
    startMsgSound();
    for(local y = 0; y < 30; y++){
        setRanBulb();
        imp.sleep(0.1); 
    }
    quickStopMsgSound();
    setColor(BLACK);
    imp.sleep(1.9)
}

/*
 * flickerLights()
 *
 * Flicker all the neopixels.
 */
function flickerLights(){
    startFlickerSound();
    for(local y = 0; y < 3; y++){
        setColor([0x88,0x88,0x88]);
        imp.sleep(0.07); 
        setColor([0x28,0x28,0x28]);
        imp.sleep(0.05); 
        setColor([0x58,0x58,0x58]);
        imp.sleep(0.11);  
        setColor([0x28,0x28,0x28]);
        imp.sleep(0.05);
        setColor([0x02,0x02,0x02]);
        
        if (y == 5) {
            imp.sleep(0.8)
        }
    }
    stopFlickerSound();
    setColor(BLACK);
    imp.sleep(1.9);
    
}


/*
 * checkMsgQueue()
 *
 * Display the next message if there is one.
 */
function checkMsgQueue(){
    if ((MESSAGES.len() > 0) && (MSG_IS_TYPING == false)){
        displayMsg(MESSAGES[0]);
        MESSAGES.remove(0);
    }
}

/*
 * autoCheckMsgQueue()
 *
 * In case a message came in while we handling displying another message,
 * this will cause the Imp to recheck the message after a set number of seconds
 */
function autoCheckMsgQueue(){
    checkMsgQueue();
    imp.wakeup(CHECKEVERY,autoCheckMsgQueue); 
}
imp.wakeup(CHECKEVERY,autoCheckMsgQueue);


// Handle the request from the Agent to add a new message
agent.on("addMsg", addMsg);


/////////////Extra Audio Code///////////

/*
 * You probably don't want this code. We wrote it really quickly and
 * probably didn't really understand the Adafruit SoundFX board. It worked
 * for our clips, but was really picky about how long we trigged the sounds
 * for without repeating or cutting off the event.  
 */

SOUNDOFF <- 1;
LASTSOUNDTIME <- 0;
FLICKERSOUNDOFF <- 1;
FLICKERLASTSOUNDTIME <- 0;

function startBulbSound(){
    if (SOUNDOFF){
        audio.write(0);
        LASTSOUNDTIME = hardware.millis();
        SOUNDOFF = 0;
    }
}
function stopBulbSound(){
    if (!SOUNDOFF){
        local sleep = (500 - (hardware.millis() - LASTSOUNDTIME) * 1.00 )/1000;
        if (sleep > 0) {
            // This will screw up if calledoutside of the fade on function.
            if (sleep > 0.05){
                return;
            }
            imp.sleep(sleep);
        }
        audio.write(1);
        SOUNDOFF = 1;
    }
}

function startMsgSound(){
    if (SOUNDOFF){
        audioStartMsg.write(0);
        LASTSOUNDTIME = hardware.millis();
        SOUNDOFF = 0;
    }
}
function quickStopMsgSound(){
    if (!SOUNDOFF){
        audioStartMsg.write(1);
        SOUNDOFF = 1;
    }
}

function startFlickerSound(){
    if (FLICKERSOUNDOFF){
        audioFlicker.write(0);
        FLICKERLASTSOUNDTIME = hardware.millis();
        FLICKERSOUNDOFF = 0;
    }
}
function stopFlickerSound(){
    if (!FLICKERSOUNDOFF){
        audioFlicker.write(1);
        FLICKERSOUNDOFF = 1;
    }
}

function endSound(){
    audio.write(1);
    SOUNDOFF = 1;
}
/////////////////////////////////


