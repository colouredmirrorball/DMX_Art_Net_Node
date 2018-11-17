# DMX_Art_Net_Node
Sketch that converts Art-Net to DMX, OSC controlled

The sketch is described here: https://text2laser.be/blog/2018/11/17/turning-ultra-dmx-micro-into-art-net-node/

This sketch will listen to Art-Net messages and send them on to a compatible USB to DMX device. This device must be compatible with the Enttec Usb Pro protocol. 

The parameters of the sketch (Art-Net universe and subnet) can be controlled by OSC.

 ## USAGE
 
 OSC commands:
 
  * /status: retrieves the status with some information
  * /universe: expects two integers, first integer is device index and second integer is universe
  * /subnet: expects two integers, first integer is device index and second integer is subnet
 
 A Processing sketch that implements these messages can be found here: https://github.com/colouredmirrorball/DMX_Art_Net_Master
 
 ## BUILD
  
Download Processing from https://processing.org onto your platform of choice and open DMX_Art_Net_Node.pde in the editor. Then either run directly from the PDE or export as a standalone app.

Hint: if you're running on a Raspberry Pi, you can use the Upload to Pi tool to easily install the sketch and make it run on startup: https://github.com/gohai/processing-uploadtopi
