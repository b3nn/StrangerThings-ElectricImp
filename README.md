# StrangerThings-ElectricImp
Electric Imp agent and device code for WS2811 lights arranged like the wall from the Stranger Things Netflix show

The Agent code will listen for HTTP GET requests with a "msg" parameter of the string to display on the lights. It will also monitor Twitter for a Hash tag and display tweets which match.

The Device code needs to know the number of the WS2811 light over each letter and the order in which your bulbs are colored (ours were Red, White, Orange, Blue, Green repeating). Optionally, an Adafruit SoundFX board can be connected to play back audio files to match events like turning on the lights and flicking the strand.

You will need to use a level shifter to convert the 3.3 Volt signal from the Electric Imp to 5 Volts for the neopixel strip.
https://electricimp.com/docs/resources/neopixels/
