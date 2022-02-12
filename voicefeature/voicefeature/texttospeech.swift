//
//  texttospeech.swift
//  voicefeature
//
//  Created by Umang Gupta on 12/2/22.
//

import Foundation
import AVKit
import AVFoundation

class texttospeech: AVSpeechUtterance {
    
    let utterance = AVSpeechUtterance(string: "The quick brown fox jumped over the lazy dog.")
    
    let sysvoice = AVSpeechSynthesisVoice(language: "en-GB")
    
    func initutterance() {
        
        utterance.rate = 0.45
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        
        utterance.voice = sysvoice
        
    }
    
    func speechsynthesiser() {
        
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(self.utterance)
        
        
    }
    
    
    
}






//
//let utterance = AVSpeechUtterance(string: "The quick brown fox jumped over the lazy dog.")
//
//// Configure the utterance.
//utterance.rate = 0.57
//utterance.pitchMultiplier = 0.8
//utterance.postUtteranceDelay = 0.2
//utterance.volume = 0.8
//
//// Retrieve the British English voice.
//let voice = AVSpeechSynthesisVoice(language: "en-GB")
//
//// Assign the voice to the utterance.
//utterance.voice = voice
//
//// Create a speech synthesizer.
//let synthesizer = AVSpeechSynthesizer()
//
//// Tell the synthesizer to speak the utterance.
//synthesizer.speak(utterance)

