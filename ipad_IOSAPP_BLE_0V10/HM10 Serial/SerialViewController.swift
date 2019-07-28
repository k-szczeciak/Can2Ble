//
//  SerialViewController.swift
//  HM10 Serial
//
//  Created by Alex on 10-08-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore

/// The option to add a \n or \r or \r\n to the end of the send message
enum MessageOption: Int {
    case noLineEnding,
         newline,
         carriageReturn,
         carriageReturnAndNewline
}

/// The option to add a \n to the end of the received message (to make it more readable)
enum ReceivedMessageOption: Int {
    case none,
         newline
}

var test_value = "0"
var value02_s = "0"
var test_value_old = "0"
var seconds = 0
var timer = Timer()
var seconds_s = ""
var seconds_u8 = [UInt8(12)]

final class SerialViewController: UIViewController, UITextFieldDelegate, BluetoothSerialDelegate {

//MARK: IBOutlets
    
    //@IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! // used to move the textField up when the keyboard is present
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var RCProcessData01: UILabel!
    @IBOutlet weak var RCProcessData02: UILabel!
    @IBOutlet weak var RCProcessData03: UILabel!
    @IBOutlet weak var RCProcessData04: UILabel!
    @IBOutlet weak var RCProcessData05: UILabel!
    @IBOutlet weak var RCProcessData06: UILabel!
    //@IBOutlet weak var RCProcessData07: UILabel!
    //@IBOutlet weak var RCProcessData08: UILabel!
    //@IBOutlet weak var RCProcessData09: UILabel!
    @IBOutlet weak var RCProcessDataBar01: UIProgressView!
    @IBOutlet weak var RCProcessDataBar02: UIProgressView!
    @IBOutlet weak var RCProcessDataBar03: UIProgressView!
    @IBOutlet weak var RCProcessDataBar04: UIProgressView!
    @IBOutlet weak var RCProcessDataBar05: UIProgressView!
    @IBOutlet weak var RCProcessDataBar06: UIProgressView!
    //RCProcessDataBar06.width=10
    //@IBOutlet weak var RCProcessDataBar07: UIProgressView!
    //@IBOutlet weak var RCProcessDataBar08: UIProgressView!
    
    //@IBOutlet weak var ActivateSection01Return: UISwitch!
    //@IBOutlet weak var PressureControlSection01Return: UISwitch!
    //@IBOutlet weak var ActivateSection02Return: UISwitch!
    //@IBOutlet weak var PressureControlSection02Return: UISwitch!
    
    //@IBOutlet weak var RCDataSlider01: UISlider!

    @IBAction func RCDataSliderOutput01(_ sender: UISlider) {
        //testpd.text = String(Int(sender.value))
        test_value = String(format:"%2X", Int(sender.value))
        //testpd.text = test_value
        serial.sendMessageToDevice("s" + test_value)
    }
    @IBAction func RCDataSliderOutput02(_ sender: UISlider) {
        value02_s = String(format:"%2X", Int(sender.value))
        //testpd.text = value02_s
        serial.sendMessageToDevice("p" + value02_s)
    }
    
    
    
    @IBOutlet weak var testpd: UILabel!
    
    @IBOutlet weak var przycisk: UIButton!
    @IBOutlet weak var testValue: UILabel!
    
    @IBAction func przyciskDotkniety(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(SerialViewController.counter), userInfo: nil, repeats: true)
        //serial.sendMessageToDevice(seconds_s)
        //serial.sendMessageToDevice("ppp")
        //serial.sendMessageToDevice("123")
    }
    
    
    @IBAction func PrzyciskStop(_ sender: Any) {
        timer.invalidate()
    }
    func counter() {
        seconds += 1
        //seconds_u8[0] = UInt8(seconds)
        if (seconds == 20) {
            seconds = 0
            //serial.sendMessageToDevice("s" +  test_value)
        }
         seconds_s = String(format:"%2X", Int(seconds))
        testValue.text = seconds_s
        
        //serial.sendBytesToDevice(seconds_u8)
        
    }
    @IBAction func wysylkaPrzycisk(_ sender: Any) {
        //serial.sendMessageToDevice("ppp")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ValveHub_background_v1.png"))
        // init serial
        serial = BluetoothSerial(delegate: self)
        serial.writeType = UserDefaults.standard.bool(forKey: WriteWithResponseKey) ? .withResponse : .withoutResponse

        
        
//        testValue.text = "comming..."

        // UI
        //mainTextView.text = ""
        RCProcessData01.text = "0"
        RCProcessData02.text = "0"
        RCProcessData03.text = "0"
        RCProcessData04.text = "0"
        RCProcessData05.text = "0"
        RCProcessData06.text = "0"
        //RCProcessData07.text = "0"
        //RCProcessData08.text = "0"
        //RCProcessData09.text = "0"
    
        RCProcessDataBar01.progress = 0
        RCProcessDataBar02.progress = 0
        RCProcessDataBar03.progress = 0
        RCProcessDataBar04.progress = 0
        RCProcessDataBar05.progress = 0
        RCProcessDataBar06.progress = 0
        //RCProcessDataBar07.progress = 0
        //RCProcessDataBar08.progress = 0
        
        reloadView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
        
        // we want to be notified when the keyboard is shown (so we can move the textField up)
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // to dismiss the keyboard if the user taps outside the textField while editing
        let tap = UITapGestureRecognizer(target: self, action: #selector(SerialViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // style the bottom UIView
//        bottomView.layer.masksToBounds = false
//        bottomView.layer.shadowOffset = CGSize(width: 0, height: -1)
//        bottomView.layer.shadowRadius = 0
//        bottomView.layer.shadowOpacity = 0.5
//        bottomView.layer.shadowColor = UIColor.gray.cgColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        // animate the text field to stay above the keyboard
        var info = (notification as NSNotification).userInfo!
        let value = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrame = value.cgRectValue
        
        //TODO: Not animating properly
        UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height
            }, completion: { Bool -> Void in
            //self.textViewScrollToBottom()
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        // bring the text field back down..
        UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.bottomConstraint.constant = 0
        }, completion: nil)

    }
    
    func reloadView() {
        // in case we're the visible view again
        serial.delegate = self
        
        if serial.isReady {
            navItem.title = serial.connectedPeripheral!.name
            barButton.title = "Disconnect"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
        } else if serial.centralManager.state == .poweredOn {
            navItem.title = "Bluetooth Serial"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = true
        } else {
            navItem.title = "Bluetooth Serial"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = false
        }
    }
    
    /*func textViewScrollToBottom() {
        let range = NSMakeRange(NSString(string: mainTextView.text).length - 1, 1)
        mainTextView.scrollRangeToVisible(range)
    }*/
    

//MARK: BluetoothSerialDelegate
    
    func serialDidReceiveString(_ message: String) {
        // add the received text to the textView, optionally with a line break at the end
        //mainTextView.text! = message //KS mod "+="
        //KS mod: next 3 lines: "//"
        //let pref = UserDefaults.standard.integer(forKey: ReceivedMessageOptionKey)
        //if pref == ReceivedMessageOption.newline.rawValue { mainTextView.text! += "\n" }
        //textViewScrollToBottom()
        //var messageArr = message.components(separatedBy: ":")
        
        var messageArr: [String] = ["00","00","00","00","00","00","00","00"]
        let charcount = message.characters.count
        
        for i in 0...7 {
            if charcount >= 16 {
                //let startIndex = message.startIndex
                let startIndex = message.index(message.endIndex, offsetBy: -16 + (i*2))
                let endIndex = message.index(message.endIndex, offsetBy: -14 + (i*2))
                let stringVal = message[startIndex..<endIndex]
                var multiplier: (Int)
                if i<4 {
                    multiplier = 4
                } else {
                    multiplier = 2
                }
                
                let Value = Int(strtoul(stringVal, nil, 16)) * multiplier
                messageArr[i] = String(Value)
            } else {
                messageArr[i] = "0"
            }
            
        }
       
        
        
        RCProcessData01.text = messageArr[0]
        RCProcessData02.text = messageArr[1]
        RCProcessData03.text = messageArr[2]
        RCProcessData04.text = messageArr[3]
        RCProcessData05.text = messageArr[4]
        RCProcessData06.text = messageArr[5]
        //RCProcessData07.text = messageArr[6]
        //RCProcessData08.text = messageArr[7]
        RCProcessDataBar01.progress = ((messageArr[0] as NSString).floatValue)/1000
        RCProcessDataBar02.progress = ((messageArr[1] as NSString).floatValue)/1000
        RCProcessDataBar03.progress = ((messageArr[2] as NSString).floatValue)/1000
        RCProcessDataBar04.progress = ((messageArr[3] as NSString).floatValue)/1000
        RCProcessDataBar05.progress = ((messageArr[4] as NSString).floatValue)/42
        RCProcessDataBar06.progress = ((messageArr[5] as NSString).floatValue)/42
        //RCProcessDataBar07.progress = ((messageArr[6] as NSString).floatValue)/400
        //RCProcessDataBar08.progress = ((messageArr[7] as NSString).floatValue)/400
        //RCDataSlider01.value = ((messageArr[0] as NSString).floatValue)/200
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        reloadView()
        dismissKeyboard()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState() {
        reloadView()
        if serial.centralManager.state != .poweredOn {
            dismissKeyboard()
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
    
//MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !serial.isReady {
            let alert = UIAlertController(title: "Not connected", message: "What am I supposed to send this to?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { action -> Void in self.dismiss(animated: true, completion: nil) }))
            present(alert, animated: true, completion: nil)
            messageField.resignFirstResponder()
            return true
        }
        
        // send the message to the bluetooth device
        // but fist, aIOSAPP_BLE_0V7_ipaddd optionally a line break or carriage return (or both) to the message
        let pref = UserDefaults.standard.integer(forKey: MessageOptionKey)
        var msg = messageField.text!
        switch pref {
        case MessageOption.newline.rawValue:
            msg += "\n"
        case MessageOption.carriageReturn.rawValue:
            msg += "\r"
        case MessageOption.carriageReturnAndNewline.rawValue:
            msg += "\r\n"
        default:
            msg += ""
        }
        
        // send the message and clear the textfield
        serial.sendMessageToDevice(msg)
        messageField.text = ""
        return true
    }
    
    //serial.sendMessageToDevice(msg)
    
    
    
    
    
    
    
    func dismissKeyboard() {
        //messageField.resignFirstResponder()
    }
    
    
//MARK: IBActions

    @IBAction func barButtonPressed(_ sender: AnyObject) {
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }
}
