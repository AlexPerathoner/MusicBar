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
	
	
	func showNotification(title: String, text: String) {
		let notification = NSUserNotification()
		notification.title = title
		notification.informativeText = text
		//notification.soundName = NSUserNotificationDefaultSoundName
		//NSUserNotificationCenter.default.deliver(notification)
		NSUserNotificationCenter.default.scheduleNotification(notification)
	}
	
	var pausedByApp = false
	
	@objc func volumeChangeEvent(_ evt: NSEvent) {
		print("Volume changed")
		if(isITunesRunning()) {
			if(isMuted()) {
				//should pause
				//but not if already paused
				if(getPlayingState() == .some(.playing)) {
					iTunesPause()
					pausedByApp = true
					let info = getSongInfo()
					showNotification(title: "Paused song", text: "\(info.name) - \(info.artist)")
					NSLog("Paused song")
				}
			} else {
				//should resume
				//but only if had paused
				if(pausedByApp) {
					iTunesPlay()
					let info = getSongInfo()
					showNotification(title: "Resumed song", text: "\(info.name) - \(info.artist)")
					pausedByApp = false
					NSLog("Resumed song")
				}
			}
		}
	}

	
	func applicationDidFinishLaunching(_ notification: Notification) {
		
        key = UserDefaults.standard.integer(forKey: "functionKeyShort")
        
		setupFnMonitor(key)
		DistributedNotificationCenter.default.addObserver(self,selector: #selector(volumeChangeEvent(_:)),name: NSNotification.Name(rawValue: "com.apple.sound.settingsChangedNotification"),object: nil)
		//DistributedNotificationCenter.default.addObserver(self, selector: #selector(volumeChangeEvent(_:)), name: NSNotification.Name(rawValue: "com.apple.sound.settingsChangedNotification"), object: nil)
		
		print("Now observing")
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


