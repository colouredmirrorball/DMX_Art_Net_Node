import netP5.*;
import oscP5.*;
import dmxP512.*;
import processing.serial.*;
import ch.bildspur.artnet.*;

ArtNetClient artnet;

OscP5 osc;

//byte array that will contain the incoming art-net message
byte[] dmxData = new byte[512];

//the dmx device
//DmxP512 dmxOutput;

//String DMXPRO_PORT;//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE=115000;

byte[] dataBuffer = new byte[512];

ArrayList<DmxOutput> outputs = new ArrayList();

int outputHeight = 70;

StringList status = new StringList();

void setup() 
{

  size(800, 600, JAVA2D);  
  surface.setResizable(true);

  int y = 0;

  //find the connected devices, if on Raspi, the device will be called "/dev/ttyUSBX" which we can use to distinguish it from the other serial devices
  //on windows, there should be only one (if you only have the dmx dongle connected)
  for (String s : Serial.list())
  {
    if (s.contains("USB") || (System.getProperty("os.name").startsWith("Windows"))) outputs.add(new DmxOutput(this, s, 20+y++*outputHeight));
  }

  //initialise the art-net node

  artnet = new ArtNetClient();
  artnet.start();

  osc = new OscP5(this, 9009);

  status.append("Started. " + outputs.size() + " devices added. Listening for Art-Net...");
}

void draw() {    
  background(0);


  for (DmxOutput output : outputs)
  {
    output.update();
  }

  displayStatus();
}

void oscEvent(OscMessage message)
{
  println("Rx'd message from ", message.address().substring(1, message.address().length()), message.port());
  NetAddress replyAddress = new NetAddress(message.address().substring(1, message.address().length()), message.port());
  OscMessage reply = new OscMessage("/reply");
  if (message.checkAddrPattern("/status"))
  {
    status.clear();
    status.append("Status poll request received");
    reply.add("Devices " + outputs.size());
    int i = 0;
    for (DmxOutput output : outputs)
    {
      reply.add("Output " + i++);
      reply.add("Universe " + output.universe);
      reply.add("Subnet " + output.subnet);
      reply.add("Universe size " + output.universeSize);
      reply.add("Error " + output.error);
    }
  } else if (message.checkAddrPattern("/universe"))
  {
    if (message.checkTypetag("ii")) 
    {
      int output = message.get(0).intValue();
      if (output < outputs.size())
      {
        outputs.get(output).universe = message.get(1).intValue();
        reply.add("Set output " + output + " to universe " + outputs.get(output).universe);
      } else
      {
        reply.add("Error: not enough outputs. Connected DMX dongles: " + outputs.size() + ", attempted output: " + output);
      }
    }
  }
  else if (message.checkAddrPattern("/subnet"))
    {
      if (message.checkTypetag("ii")) 
      {
        int output = message.get(0).intValue();
        if (output < outputs.size())
        {
          outputs.get(output).subnet = message.get(1).intValue();
          reply.add("Set output " + output + " to subnet " + outputs.get(output).subnet);
        } else
        {
          reply.add("Error: not enough outputs. Connected DMX dongles: " + outputs.size() + ", attempted output: " + output);
        }
      }
    }
    osc.send(reply, replyAddress);
  }

  void displayStatus() //Displays some information, such as the strings in the status arraylist, fps, file header etc
  {
    fill(255);
    textAlign(LEFT);

    for (int i = 0; i < status.size (); i++)
    {
      fill(255);
      if (textWidth(status.get(i)) > width-10) 
      {
        String[] brokenText = splitTokens(status.get(i));
        String str1 = "";
        String str2 = "";
        int k = 0;
        if (!(textWidth(brokenText[0]) > width-10))
        {
          for (int j = 0; j < brokenText.length; j++)
          {      
            if (textWidth(str1 + brokenText[j] + " ") > width-10)
            {

              k = j;
              j = brokenText.length;
            } else str1 += brokenText[j] + " ";
          }
          status.set(i, str1);
          for (int j = k; j < brokenText.length; j++)
          {      
            str2 += brokenText[j] + " ";
          }
          status.insert(i+1, str2);
        }
      }

      text(status.get(i), 10, height-20*status.size()+20*i);
    }
  }
