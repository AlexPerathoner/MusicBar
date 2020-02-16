//
//  Speaker.swift
//  MusicBar
//
//  Created by Alex Perathoner on 28/12/2019.
//

import Foundation
import AVFoundation


class Speaker: NSObject {
    let synth = AVSpeechSynthesizer()
	var oldState: MusicState?
	var oldVolume: Int
    override init() {
		oldVolume = 100
        super.init()
        synth.delegate = self
    }
	
	init(_ state: MusicState?, _ volume: Int) {
		oldState = state
		oldVolume = volume
        super.init()
        synth.delegate = self
	}
	
    func speak(_ string: String) {
        let utterance = AVSpeechUtterance(string: string)
		utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        synth.speak(utterance)
    }
}

extension Speaker: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Finished speaking")
		if(oldState == .some(.playing)) {
			iTunesPlay()
			riseVolume(oldVolume)
		}
    }
	
}
