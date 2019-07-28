"""
    Simple test of a 128 x 64 pixel OLED display with an ssd1306 driver chip on a SPI bus
    |OLED |PYB |
    |VCC  |3V3 |
    |GND  |GND|
    |NC   |-- |
    |DIN  |Y8 MOSI |
    |CLK  |Y6 SCK |
    |CS   | --|
    |D/C  |Y2 |
    |RES  |Y1 |
    """
"""
Krzysztof Szczeciak modifications:
1. D/C lines from Y4 to Y2
2. RES from Y3 to Y1

"""

import pyb
import machine
from font import strtobit
from pyb import CAN
from pyb import UART

# from adafruit arduino
init_cmds = [0xAE, 0xD5, 0x80, 0xA8, 0x3F, 0xD3, 0x0, 0x40, 0x8D, 0x14, 0x20, 0x00, 0xA1, 0xC8,
             0xDA, 0x12, 0x81, 0xCF, 0xd9, 0xF1, 0xDB, 0x40, 0xA4, 0xA6, 0xAF]

display_cmds = [0x21, 0, 127, 0x22, 0, 7]


#uart1.init(9600, bits=8, parity=None, stop=1)

## set up SPI bus
rate = 8000000

spi = pyb.SPI(1, pyb.SPI.MASTER, baudrate=rate, polarity=0, phase=0)
dc  = pyb.Pin('Y2',  pyb.Pin.OUT_PP, pyb.Pin.PULL_DOWN)
res = pyb.Pin('Y1', pyb.Pin.OUT_PP, pyb.Pin.PULL_DOWN)

def write_command(cmd):
    """
        write single command byte to ssd1306
        """
    dc.low()
    spi.send(cmd)

filterMsgIDs = (123, 124, 125, 126)
#for i in range(0, 100, 1):
#   filterMsgIDs[i] = i+100

displayText = strtobit
accel = pyb.Accel()
#can1 = CAN(1, CAN.NORMAL, extframe=False, prescaler=16, sjw=1, bs1=14, bs2=6) #125kbps
can1 = CAN(1, CAN.NORMAL, extframe=False, prescaler=8, sjw=1, bs1=14, bs2=6) #250kbps
#can1 = CAN(1, CAN.NORMAL, extframe=False, prescaler=4, sjw=1, bs1=14, bs2=6) #500kbps
#can1 = CAN(1, CAN.NORMAL, extframe=False, prescaler=2, sjw=1, bs1=14, bs2=6) #1000kbps <- not wornikg


#can1 = CAN(1, CAN.LOOPBACK, extframe=False, prescaler=16, sjw=1, bs1=14, bs2=6)
can1.setfilter(0, CAN.LIST16, 0, filterMsgIDs)
recData_au8 = bytearray(8)
uart1 = UART(2, 115200)
uart1.init(115200,bits=8,parity=None,stop=1,timeout = 20, flow=0, timeout_char=20, read_buf_len = 8)
counterUart = str(uart1.read(1))
counterUart_s = ''
counterUart1_s = ''
var1=""
var2=""
var3=""
readLength=0
msgRec = ""
recBuffer = ""
buf = bytearray(8)
UART_rxBuffer = bytearray(4)
readText = ""
axis_x = 0
recievedValue = 0
recievedValue1 = 0
recievedValue_ba = bytearray(4)
readText = "00"
readText1 = "00"
radTextSum = "0000"
line5Len = 0
readTextAdd = ""

## power on
res.high()
pyb.delay(1)
res.low()
pyb.delay(10)
res.high()

## init display
for cmd in init_cmds:
    write_command(cmd)

## clear display
buffer = bytearray(1024)
for cmd in display_cmds:
    write_command(cmd)
dc.high()
spi.send(buffer)

####################### HERE IT COMES ##############################

c = [0] * 128
#can1.clearfilter(0)
"""
## line grid
b = [1] * 1024  # 8 horizontal lines

# set every  16th byte to 255
# should give 8 vertical lines
for i in range(0, 1024, 16):
    b[i] = 255

#color in the 1st block to see where it is
for i in range(0,16):
    b[i] = 255
"""
mfreq=machine.freq()
uart1.readinto(buf, 8)
while True:
    #counterUart += 1
    #uart1.write(str(counterUart))
	
    #axis_x = accel.x()
    #axis_y = accel.y()
    #axis_z = accel.z()
    axis_x+=1

    if axis_x > 128:
        axis_x = 0
    
    if can1.any(0):
        recArr = can1.recv(0, timeout=100)
        recData_au8 = recArr[3]
        recID = recArr[0]
		
        #LINE 2
        recID_s = str(recID)
        whSpcLenL2 = 16 - 7 - len(recID_s)
        whiteSpaceL2 = ' ' * whSpcLenL2
        Line2text = 'RX ID: ' + recID_s + whiteSpaceL2
        #LINE 3
        """
        Line3text = str(hex(recData_au8[0]))[2:] + '' + str(hex(recData_au8[1]))[2:] + ':' + str(hex(recData_au8[2]))[2:] + '' + str(hex(recData_au8[3]))[2:]  + ':' + str(hex(recData_au8[4]))[2:]  + '' + str(hex(recData_au8[5]))[2:]  + ':' + str(hex(recData_au8[6]))[2:]  + '' + str(hex(recData_au8[7]))[2:]
        """
        """
        Line3text = str(recData_au8[0]) + ':' + str(recData_au8[1]) + ':' + str(recData_au8[2]) + ':' + str(recData_au8[3])  + ':' + str(recData_au8[4])  + ':' + str(recData_au8[5])  + ':' + str(recData_au8[6])  + ':' + str(recData_au8[7])
        """
        Line3text = "%0.2X" % recData_au8[0] + "%0.2X" % recData_au8[1] + "%0.2X" % recData_au8[2] + "%0.2X" % recData_au8[3] + "%0.2X" % recData_au8[4] + "%0.2X" % recData_au8[5] + "%0.2X" % recData_au8[6] + "%0.2X" % recData_au8[7]

        
        #counterUart = recData_au8[0]
        message_send_s=Line3text
        UART_send_msg_s=str(recData_au8[0])
        whSpcLenL3 = len(Line3text)
        if whSpcLenL3 > 16:
            whiteSpaceL3 = ' ' * (32 - whSpcLenL3)
        else:
            whiteSpaceL3 = ' ' * (16 - whSpcLenL3)
    else:
        message_send_s='0000000000000000'
        Line2text='No message !!!                  '
        UART_send_msg_s=Line2text
        whiteSpaceL2=''
        whiteSpaceL3=''
        Line3text='                '
		
    #uart1.write(str(UART_send_msg_s))
    uart1.write(message_send_s)
    # LINE 1
    axis_x_s = str(axis_x)
    whSpcLenL1 = 7 - len(axis_x_s)
    whiteSpaceL1 = ' ' * whSpcLenL1
    Line1text = 'axis x = ' + axis_x_s + whiteSpaceL1
    
    # LINE 4
    for x in range(1, 128, 1):
        if ((recievedValue/2)) < x:
            c[x] = 0
        else:
            c[x] = 255

    LineBreak = "________________                "

    # LINE 5
    #bufferUartLength = uart1.any()
    #recievedValue = 20
    if uart1.any() > 2:
        #recievedValue = 100
        #recievedValue1 = 100
        uart1.readinto(buf, 3)
        if ( (chr(buf[0]) == "s") and (chr(buf[1]) != "s") and (chr(buf[2]) != "s")  and (chr(buf[1]) != "p") and (chr(buf[2]) != "p") ) :
            readText = chr(buf[1]) + chr(buf[2]) #+ chr(buf[3]) + chr(buf[4])
            recievedValue = int(readText, 16)
        if ( (chr(buf[0]) == "p") and (chr(buf[1]) != "p") and (chr(buf[2]) != "p") and (chr(buf[1]) != "s") and (chr(buf[2]) != "s") ) :
            readText1 = chr(buf[1]) + chr(buf[2]) #+ chr(buf[3]) + chr(buf[4])
            recievedValue1 = int(readText1, 16)
        radTextSum = readText + readText1
        recievedValue_ba[0] = recievedValue
        recievedValue_ba[1] = recievedValue1
        #uart1.sendbreak()
        #counterUart = str(uart1.read(4))
        #msgRec = str(uart1.readchar())
        #readLength = len(counterUart)
        #counterUart1_s = counterUart[-3:]
        #counterUart_s = counterUart1_s[:2]
        #msgRec = str(uart1.readchar())
        
        can1.send(recievedValue_ba, 126) #<---
        
        '''
		try:
            can1.send(readText, 126, timeout = 100)
            readTextAdd = " Send OK"
            break
        except:
            readTextAdd = " Send failed"
		'''



#uart1.sendbreak()
#counterUart = str(uart1.read(4))
    #msgRec = str(uart1.readchar())
#readLength = len(counterUart)
#counterUart1_s = counterUart[-3:]
#counterUart_s = counterUart1_s[:2]



    #else:
    #    counterUart = "nie ma niczego..."
    #counterUart = bufferUartLength
    line5Len = 16 - len(radTextSum) - len(readTextAdd)
    whspcL5 = ' ' * line5Len
    uart1.readinto(buf, 3)
    Line5text = radTextSum + readTextAdd + whspcL5 #+ chr(buf[0])
    #+ str(mfreq)

    textArray_axis_x = Line1text + LineBreak + Line2text + Line3text + whiteSpaceL3 + Line5text #+ str(buf[0])


    
    
    # function for formating text: l1 = , L2 = , ...

    textSpace = displayText(textArray_axis_x, 0)
    c_ar = bytearray(c)
    b = textSpace + c_ar
	
	


#################### SENDING BUFFER ################################
    buffer = bytearray(b)
    if uart1.any()>0:
        rec_data=uart1.readchar()
    else:
        rec_data='a'

    for cmd in display_cmds:
        write_command(cmd)
    dc.high()
    spi.send(buffer)
    
    #can1.send('a', 257)


    pyb.delay(10)

