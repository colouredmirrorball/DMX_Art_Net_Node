class DmxOutput
{
  DmxP512 dmxOut;
  int universe, subnet;
  int universeSize = 512;
  int y;
  boolean error = false;

  DmxOutput(PApplet parent, String s, int y)
  {
    dmxOut = new DmxP512(parent, universeSize, false);
    dmxOut.setupDmxPro(s, DMXPRO_BAUDRATE);
    this.y = y;
  }

  void setUniverse(int universe)
  {
    this.universe = universe;
  }

  void setSubnet(int subnet)
  {
    this.subnet = subnet;
  }

  void update()
  {
    //listen to art-net
    byte[] data = artnet.readDmxData(subnet, universe);  //args: subnet, universe

    //detect a new message
    boolean changed = false;
    for (int i = 0; i < 512; i++)
    {
      if (data[i] != dataBuffer[i])
      {
        changed = true;
        break;
      }
    }
    dataBuffer = data;

    boolean sending = false;

    //only resend dmx if the data has changed
    //also resend every 166 ms to avoid devices losing the dmx connection
    //most devices have a 1 second timeout
    if (changed || frameCount%10==0)
    {
      for (int i = 0; i < universeSize; i++)
      {
        //dmx channel offset: incoming art-net channel 0 will actually be dmx channel 1
        //the data will become signed, but it needs to be unsigned, this can be fixed with the "&0xff" code
        dmxOut.set(i+1, data[i] & 0xff);
        sending = true;
      }
    }


    if (changed)
    {
      fill(0, 255, 0);
    } else
    {
      fill(255, 0, 0);
    }
    rect(30, y+5, 30, 30);

    if (sending)
    {
      fill(0, 255, 0);
    } else
    {
      fill(255, 0, 0);
    }
    rect(30, y+40, 30, 30);


    fill(255);
    text("Art-Net subnet " + subnet + " universe " + universe, 70, y+20);
  }
}
