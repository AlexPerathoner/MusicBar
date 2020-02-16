//
//  StatusMenuController.swift
//  MusicBar
//
//  Created by Alex Perathoner on 10/07/2018.
//  Copyright © 2018 Alex. All rights reserved.
//

import Cocoa
import ServiceManagement
import AVFoundation

var fnObserver: Any?

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
        key = UserDefaults.standard.integer(forKey: "functionKeyShort")
		setupFnMonitor(key)
		//volume changes are in MediApplication.swift
	}
}

func setupFnMonitor(_ key: Int) {
	if (fnObserver != nil) {
		NSEvent.removeMonitor(fnObserver!)
	}
	let enabled = UserDefaults.standard.bool(forKey: "enabledFbtn")
	if (enabled && key != -1) {
		print("Adding fn monitor for keyCode \(key)")
		fnObserver = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { (event) in
			if event.keyCode == key {
				DispatchQueue.global(qos: .background).async {
					//background thread to not block UI with sleep()
					let info = getSongInfo()
					let oldState = getPlayingState()
					let oldVolume = lowerVolume(0)
					let speaker = Speaker(oldState, oldVolume)
					iTunesPause()
					speaker.speak("\(info.name) by \(info.artist)")
					sleep(7)
				}
			}
		}
	}
}


