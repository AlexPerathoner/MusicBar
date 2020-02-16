


import Cocoa


class MediaApplication: NSApplication {
	
	
	var pausedByApp = false
	
	
	override func sendEvent(_ event: NSEvent) {
		if (event.type == .systemDefined && event.subtype.rawValue == 8) {
            let keyCode = ((event.data1 & 0xFFFF0000) >> 16)
            let keyFlags = (event.data1 & 0x0000FFFF)
            // Get the key state. 0xA is KeyDown, OxB is KeyUp
            let keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA
			let keyRepeat = keyFlags & 0x1
			mediaKeyEvent(key: Int32(keyCode), state: keyState, keyRepeat: Bool(truncating: keyRepeat as NSNumber))
        }
        
        super.sendEvent(event)
    }
    
    func mediaKeyEvent(key: Int32, state: Bool, keyRepeat: Bool) {
        // Only send events on KeyDown. Without this check, these events will happen twice
        if (state) {
            switch(key) {
            case NX_KEYTYPE_SOUND_DOWN, NX_KEYTYPE_SOUND_UP, NX_KEYTYPE_MUTE:
				volumeChangeEvent()
                break
            default:
                break
            }
        }
    }
	
	func showNotification(title: String, text: String) {
		let notification = NSUserNotification()
		notification.title = title
		notification.informativeText = text
		//notification.soundName = NSUserNotificationDefaultSoundName
		//NSUserNotificationCenter.default.deliver(notification)
		NSUserNotificationCenter.default.scheduleNotification(notification)
	}
	

	func volumeChangeEvent() {
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
}

