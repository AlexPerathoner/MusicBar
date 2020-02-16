//
//  StatusMenuController.swift
//  MusicBar
//
//  Created by Alex Perathoner on 10/07/2018.
//  Copyright © 2018 Alex. All rights reserved.
//

import Cocoa
import AppKit
import LoginServiceKit

var key: Int = 0



// - MARK: CAUTION!
// This code is very bad and chaotic- you know spaghetti? Exactly.
// Somehow I got it to work, don't try to understand it



class StatusMenuController: NSObject {
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    var menuItem: NSMenuItem!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
	var menuItems: [NSMenuItem] = []
	
    @IBOutlet weak var giveAccessRightOutlet: NSMenuItem!
        
    override func awakeFromNib() {
        menuItems = [fn1btnu, fn2btnu, fn3btnu, fn4btnu, fn5btnu, fn5btnu, fn6btnu, fn6btnu, fn8btnu, fn9btnu, fn10btnu, fn11btnu, fn12btnu]
        if !UserDefaults.standard.bool(forKey: "firstStart") {
            UserDefaults.standard.set(true, forKey: "firstStart")
        }
		
		if(LoginServiceKit.isExistLoginItems()) {
			launchAtLoginOutlet.state = NSControl.StateValue.on
		} else {
			launchAtLoginOutlet.state = NSControl.StateValue.off
		}
		
		
		let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
		let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)
        if accessibilityEnabled{
            giveAccessRightOutlet.state = NSControl.StateValue.on
        } else {
            giveAccessRightOutlet.state = NSControl.StateValue.off
        }
		
		key = UserDefaults.standard.integer(forKey: "functionKeyShort")
		
		toggleAllItems(.off)
		
        if UserDefaults.standard.bool(forKey: "enabledFbtn") {
//            if !accessibilityEnabled {
//				alert(question: "In order to use the Speaked Info function you have to give Accessibility Rights")
//            }
			convertToMenuItem(key).state = .on
        } else {
            disableFbtnu.state = NSControl.StateValue.on
        }
        
        statusItem.menu = statusMenu
		if let button = statusItem.button {
			button.image = NSImage(named: "statusIcon")
			button.image?.isTemplate = true
		}
        menuItem = statusMenu.item(withTitle: "MusicBar")
        
	}

    @IBOutlet weak var launchAtLoginOutlet: NSMenuItem!
    @IBAction func launchAtLoginClicked(_ sender: Any) {
        NSSound(named: "Purr")?.play()
		if LoginServiceKit.isExistLoginItems() {
			LoginServiceKit.removeLoginItems()
			launchAtLoginOutlet.state = .off
		} else {
			LoginServiceKit.addLoginItems()
			launchAtLoginOutlet.state = .on
		}
    }
    
    @IBAction func accessibilityRightsClicked(_ sender: Any) {
		let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
		let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)
		
		//print(accessibilityEnabled)
    }
	
	func toggleAllItems(_ to: NSControl.StateValue) {
		for ite in menuItems {
			ite.state = to
		}
        disableFbtnu.state = to
	}
    
    func stateOnMenuItem(item: NSMenuItem) {
        NSSound(named: "Purr")?.play()
		let keyCode = convertToInt(item)
		UserDefaults.standard.set(keyCode, forKey: "functionKeyShort")
		if(item == disableFbtnu) {
			UserDefaults.standard.set(false, forKey: "enabledFbtn")
		} else {
			UserDefaults.standard.set(true, forKey: "enabledFbtn")
		}
		toggleAllItems(.off)
		setupFnMonitor(keyCode)
		
		item.state = .on
    }

	
	// - MARK: Outlets for fn keys
    
    @IBOutlet weak var fn1btnu: NSMenuItem!
    @IBOutlet weak var fn2btnu: NSMenuItem!
    @IBOutlet weak var fn3btnu: NSMenuItem!
    @IBOutlet weak var fn4btnu: NSMenuItem!
    @IBOutlet weak var fn5btnu: NSMenuItem!
    @IBOutlet weak var fn6btnu: NSMenuItem!
    @IBOutlet weak var fn7btnu: NSMenuItem!
    @IBOutlet weak var fn8btnu: NSMenuItem!
    @IBOutlet weak var fn9btnu: NSMenuItem!
    @IBOutlet weak var fn10btnu: NSMenuItem!
    @IBOutlet weak var fn11btnu: NSMenuItem!
    @IBOutlet weak var fn12btnu: NSMenuItem!
    @IBOutlet weak var disableFbtnu: NSMenuItem!
   
    
    @IBAction func fn1btn(_ sender: Any) {
        stateOnMenuItem(item: fn1btnu)
    }
    @IBAction func fn2btn(_ sender: Any) {
        stateOnMenuItem(item: fn2btnu)
    }
    @IBAction func f3btn(_ sender: Any) {
        stateOnMenuItem(item: fn3btnu)
    }
    @IBAction func f4btn(_ sender: Any) {
        stateOnMenuItem(item: fn4btnu)
    }
    @IBAction func f5btn(_ sender: Any) {
        stateOnMenuItem(item: fn5btnu)
    }
    @IBAction func f6btn(_ sender: Any) {
        stateOnMenuItem(item: fn6btnu)
    }
    @IBAction func f7btn(_ sender: Any) {
        stateOnMenuItem(item: fn7btnu)
    }
    @IBAction func f8btn(_ sender: Any) {
        stateOnMenuItem(item: fn8btnu)
    }
    @IBAction func f9btn(_ sender: Any) {
        stateOnMenuItem(item: fn9btnu)
    }
    @IBAction func f10btn(_ sender: Any) {
        stateOnMenuItem(item: fn10btnu)
    }
    @IBAction func f11btn(_ sender: Any) {
        stateOnMenuItem(item: fn11btnu)
    }
    @IBAction func f12btn(_ sender: Any) {
        stateOnMenuItem(item: fn12btnu)
    }
    @IBAction func disableFbtn(_ sender: Any) {
        stateOnMenuItem(item: disableFbtnu)
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
	
    func convertToMenuItem(_ code: Int) -> NSMenuItem {
		var item: NSMenuItem
		switch code {
		case 122:
			item = fn1btnu
		case 120:
			item = fn2btnu
		case 99:
			item = fn3btnu
		case 118:
			item = fn4btnu
		case 96:
			item = fn5btnu
		case 97:
			item = fn6btnu
		case 98:
			item = fn7btnu
		case 100:
			item = fn8btnu
		case 101:
			item = fn9btnu
		case 109:
			item = fn10btnu
		case 103:
			item = fn11btnu
		case 111:
			item = fn12btnu
		default:
			item = disableFbtnu
		}
		return item
	}
	
	func convertToInt(_ item: NSMenuItem) -> Int {
		var code: Int
		switch item {
		case fn1btnu:
			code = 122
		case fn2btnu:
			code = 120
		case fn3btnu:
			code = 99
		case fn4btnu:
			code = 118
		case fn5btnu:
			code = 96
		case fn6btnu:
			code = 97
		case fn7btnu:
			code = 98
		case fn8btnu:
			code = 100
		case fn9btnu:
			code = 101
		case fn10btnu:
			code = 109
		case fn11btnu:
			code = 103
		case fn12btnu:
			code = 111
		default:
			code = -1
		}
		return code
	}
}
