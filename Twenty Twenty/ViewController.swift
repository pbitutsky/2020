//
//  ViewController.swift
//  TwentyTwenty2
//
//  Created by Paul Bitutsky on 6/5/17.
//  Copyright © 2017 Paul Bitutsky. All rights reserved.
//

import Cocoa

//voices in these languages are allowed because I can count in them
let allowedPrefixes = ["en", "it", "fr", "de", "he", "es", "ru"]
func filterVoices(x: String) -> Bool{
    let locale = NSSpeechSynthesizer.attributes(forVoice: x)["VoiceLocaleIdentifier"] as! String
    let prefix: String = locale.substring(to: locale.index(locale.startIndex, offsetBy: 2))
    return allowedPrefixes.contains(prefix)
}

//20 minutes open, 20 seconds closed
let eyesOpenSeconds = 20 * 60
let eyesClosedSeconds = 20

class ViewController: NSViewController {

    @IBOutlet weak var timerLabel: NSTextField!
    
    var seconds = eyesOpenSeconds
    var timer = Timer()
    var isTimerRunning = false
    var defaultBackgroundColor: CGColor? = nil
    var defaultNSBackgroundColor: NSColor? = nil
    var eyesOpen: Bool = true
    var synthesizer: NSSpeechSynthesizer = NSSpeechSynthesizer()
    let allowedVoices = NSSpeechSynthesizer.availableVoices().filter(filterVoices)
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            if eyesOpen{
                enterFullScreenModal()
                NSApp.activate(ignoringOtherApps: true)
                seconds = eyesClosedSeconds
                timerLabel.stringValue = timeString(time: TimeInterval(seconds))
                speakTime(time: String(seconds))
                eyesOpen = false
                runTimer()
            }else{
                exitFullScreenModal()
                NSApp.hide(nil)
                seconds = eyesOpenSeconds
                timerLabel.stringValue = timeString(time: TimeInterval(seconds))
                eyesOpen = true
                runTimer()
            }
        } else {
            seconds -= 1
            timerLabel.stringValue = timeString(time: TimeInterval(seconds))
            if !eyesOpen{
                speakTime(time:String(seconds))
            }
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        //let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02im %02is",  minutes, seconds)
    }
    
    @IBAction func start(_ sender: Any) {
        runTimer()
    }
    @IBAction func stop(_ sender: Any) {
        timer.invalidate()
        seconds = eyesOpenSeconds
        timerLabel.stringValue = timeString(time: TimeInterval(seconds))
        isTimerRunning = false
        exitFullScreenModal()
        eyesOpen = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func enterFullScreenModal(){
        //configure Synthesizer. He's the little guy in the computer that talks
        let array = allowedVoices
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        synthesizer = NSSpeechSynthesizer(voice: array[randomIndex])!
        
        
        defaultBackgroundColor = self.view.layer?.backgroundColor
        defaultNSBackgroundColor = timerLabel.backgroundColor
        self.view.layer?.backgroundColor = NSColor.black.cgColor
        timerLabel.textColor = NSColor.white
        
        timerLabel.backgroundColor = NSColor.black
        
        
        let presOptions: NSApplicationPresentationOptions = [
            //----------------------------------------------
            // These are all the options for the NSApplicationPresentationOptions
            // BEWARE!!!
            // Some of the Options may conflict with each other
            //----------------------------------------------
            
            //  .Default                   |
            //  .AutoHideDock              |   // Dock appears when moused to
            //  .AutoHideMenuBar           |   // Menu Bar appears when moused to
            //  .DisableForceQuit          |   // Cmd+Opt+Esc panel is disabled
            //  .DisableMenuBarTransparency|   // Menu Bar's transparent appearance is disabled
            //  .FullScreen                |   // Application is in fullscreen mode
            .hideDock                  ,   // Dock is entirely unavailable. Spotlight menu is disabled.
            .hideMenuBar               ,   // Menu Bar is Disabled
            .disableAppleMenu          ,   // All Apple menu items are disabled.
            .disableProcessSwitching   ,   // Cmd+Tab UI is disabled. All Exposé functionality is also disabled.
            .disableSessionTermination ,   // PowerKey panel and Restart/Shut Down/Log Out are disabled.
            .disableHideApplication    ,   // Application "Hide" menu item is disabled.
            .autoHideToolbar
            
        ]
        //        let optionsDictionary = [NSFullScreenModeApplicationPresentationOptions :
        //            NSNumber(unsignedLong: presOptions.rawValue)]
        //
        //        self.view.enterFullScreenMode(NSScreen.main()!, withOptions:optionsDictionary)
        //        self.view.wantsLayer = true
        
        if let screen = NSScreen.main() {
            view.enterFullScreenMode(screen,
                                     withOptions: [NSFullScreenModeApplicationPresentationOptions:
                                        CUnsignedLong(presOptions.rawValue)])
        }
    }
    
    func exitFullScreenModal(){
        if view.isInFullScreenMode{
            view.exitFullScreenMode(options: nil)
            self.view.layer?.backgroundColor = defaultBackgroundColor
            timerLabel.textColor = NSColor.white
            timerLabel.backgroundColor = defaultNSBackgroundColor
            timerLabel.textColor = NSColor.black
        }
    }
    
    func speakTime(time:String){
        synthesizer.startSpeaking(time)
    }
}

