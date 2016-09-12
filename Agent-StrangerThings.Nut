#require "Twitter.class.nut:1.2.1"

REQUEST_KEY <- "SeCrEtKeY"
server.log("Send Msg to: " + http.agenturl() + "?key=" + REQUEST_KEY +"&msg=Right+Here");

// Just follow the Electric Imp Twitter API document
// https://electricimp.com/docs/libraries/webservices/twitter/

const API_KEY = "YourTwitterAP_KEY";
const API_SECRET = "YourTwitterAPI_SECRET";
const AUTH_TOKEN = "YourTwitterAUTH_TOKEN";
const TOKEN_SECRET = "YourTwitterTOKEN_SECRET";
twitter <- Twitter(API_KEY, API_SECRET, AUTH_TOKEN, TOKEN_SECRET);

const TWITTER_HASH_TAG = "#StrangerThings";

/*
 * function cleanText(msg)
 * Remove some characters/strings from the messages 
 * that would be annoying to print or not on the wall 
 */

function cleanText(msg){

    local new_msg = blob(1024); 
    local x = 0;
    local lastLetter;
    
    // Sanity Check and no overflow
    if (msg.len() > 1024) { return new_msg.readstring(x); }
    
    // Strip URLs - regex could be better, but should work
    local expression = regexp(@"(HTTPS?:\/\/\S+ )");
    local match = expression.search(msg + " ");
    
    while (match){
        local subString = msg.slice(0, match.begin);
        subString = subString + msg.slice(match.end);
        msg = subString
        match = expression.search(msg);
    }
    
    
    foreach(letter in msg){
        // Only A-Z 
        if ((letter >= 65) && (letter <= 90)){
            new_msg[x++] = letter;
        }
        
        // Pause for .!?,
        if ((letter == 32)||(letter ==33)||(letter ==44)||(letter ==46)){
            if (lastLetter != 0x20) {
                new_msg[x++] = 0x20;
            }
        }
        
        lastLetter = new_msg[x];
    }
    
    return new_msg.readstring(x);
}

function sendMsgToDevice(msg){
    local cleanmsg = cleanText(msg.toupper());
    server.log("Clean is: " + cleanmsg);
    device.send("addMsg",cleanmsg);
}

function onTweet(tweetData) {
    // Callback function to log the Tweet
    // and who Tweeted it (there is a LOT more info in tweetData)
    server.log(format("%s - %s", tweetData.text, tweetData.user.screen_name));
    sendMsgToDevice(tweetData.text);
}

// Start the stream
twitter.stream(TWITTER_HASH_TAG, onTweet);


function requestHandler(request, response) {
  try {
    // check if the user sent led as a query parameter
    if ("msg" in request.query) {
      //Check for our Key
      if ("key" in request.query) {
          if (request.query.key == REQUEST_KEY ) {
      		user_string <- request.query.msg.toupper();
            server.log(user_string);
            sendMsgToDevice(user_string);
            response.send(200, "Message sent to the Upside Down");
          } else {
            server.log("WARNING: Bad key sent with request.");
            response.send(200, "I don't like your key");
          }
      }
      
    } else {
        response.send(200, "The spirits can't hear you.");
    }
    
  } catch (ex) {
    server.log("Error:" + ex);
    response.send(500, "Internal Server Error: " + ex);
  }
}

// register the HTTP handler
http.onrequest(requestHandler);
