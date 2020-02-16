//
//  ScriptingBridge.swift
//  MusicBar
//
//  Created by Alex Perathoner on 24/12/2019.
//


import ScriptingBridge

@objc protocol iTunesTrack {
    @objc optional var name: String {get}
    @objc optional var album: String {get}
    @objc optional var artist: String {get}
}
@objc protocol iTunesApplication {
    @objc optional var soundVolume: Int {get}
	@objc optional var currentTrack: iTunesTrack? {get}
	@objc optional func pause()
	@objc optional func playpause()
	@objc optional var playerState: MusicEPlS {get}
	@objc optional func setSoundVolume(_: Int)
	@objc optional var isRunning: Bool {get}
}



@objc public enum MusicEPlS : AEKeyword {
    case stopped = 0x6b505353 /* 'kPSS' */
    case playing = 0x6b505350 /* 'kPSP' */
    case paused = 0x6b505370 /* 'kPSp' */
    case fastForwarding = 0x6b505346 /* 'kPSF' */
    case rewinding = 0x6b505352 /* 'kPSR' */
}

enum MusicState {
	case stopped
	case playing
	case paused
	case fastForwarding
	case rewinding
}

func matchStates(input: UInt32) -> MusicState? {
	switch input {
	case 0x6b505353:
		return MusicState.stopped
	case 0x6b505350:
		return MusicState.playing
	case 0x6b505370:
		return MusicState.paused
	case 0x6b505346:
		return MusicState.fastForwarding
	case 0x6b505352:
		return MusicState.rewinding
	default:
		return nil
	}
}

extension SBApplication : iTunesApplication {}

let iTunesApp: iTunesApplication = SBApplication(bundleIdentifier: "com.apple.Music")!

func getPlayingState() -> MusicState? {
	//print(iTunesApp.playerState!.rawValue)
	if(!isITunesRunning()) {return nil}
	return matchStates(input: iTunesApp.playerState!.rawValue)
}

func getSongInfo() -> (name: String, artist: String, album: String) {
	if(!isITunesRunning()) {return ("", "", "")}
	let name = (iTunesApp.currentTrack)!?.name! ?? ""
	let artist = (iTunesApp.currentTrack)!?.artist! ?? ""
	let album = (iTunesApp.currentTrack)!?.album! ?? ""
	return (name, artist, album)
}


func lowerVolume(_ to: Int) -> Int {
	if(!isITunesRunning()) {return -1}
	let oldValue = iTunesApp.soundVolume!
	var i = oldValue
	while(i>to) {
		i -= 1
		iTunesApp.setSoundVolume!(i)
	}
	return oldValue
}

func riseVolume(_ to: Int) -> Int {
	if(!isITunesRunning()) {return -1}
	let oldValue = iTunesApp.soundVolume!
	var i = oldValue
	while(i<to) {
		i += 1
		iTunesApp.setSoundVolume!(i)
	}
	return oldValue
}

func iTunesPause() {
	if(!isITunesRunning()) {return}
	iTunesApp.pause?()
}

func iTunesPlay() {
	if(!isITunesRunning()) {return}
	if(getPlayingState() == .some(.paused)) {
		iTunesApp.playpause?()
	}
}

func isITunesRunning() -> Bool {
	return iTunesApp.isRunning ?? false
}
