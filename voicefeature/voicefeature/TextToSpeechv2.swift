//
//  TextToSpeechv2.swift
//  voicefeature
//
//  Created by Umang Gupta on 18/2/22.
//


//import Foundation
//import AVKit
import AVFoundation

protocol CanSpeakDelegate {
   func speechDidFinish()
}

class CanSpeak: NSObject, AVSpeechSynthesizerDelegate {
    
    let voices = AVSpeechSynthesisVoice.speechVoices()
    let voiceSynth = AVSpeechSynthesizer()
    var voiceToUse: AVSpeechSynthesisVoice?
    
    var delegate: CanSpeakDelegate!
    
    override init(){
        
        super.init()
        
        voiceToUse = AVSpeechSynthesisVoice.speechVoices().filter({ $0.name == "Karen" }).first
        
        self.voiceSynth.delegate = self
        
    }
    
    func sayThis(_ phrase: String){
        
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = voiceToUse
        utterance.rate = 0.5
        voiceSynth.speak(utterance)
        
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        self.delegate.speechDidFinish()
       
   }
}

class TextToAudio: NSObject, CanSpeakDelegate {
    
    var speechRecognizer = SpeechRecognizer()
    
    var isfinished = false
    
    var verifybusstopbutton = false
    
    var popupspeak = false
    
    var timer = Timer.init()
    
    
    
    let canSpeak = CanSpeak()
    
    var voicereply = ""
    
    var utterance = AVSpeechUtterance(string: "What bus number are you waiting for?")
    
    let sysvoice = AVSpeechSynthesisVoice(language: "en-GB")
    
    override init() {
        super.init()
        self.canSpeak.delegate = self
        
    }
    
    func initutterance(voiceouttext: String) {

        
        utterance = AVSpeechUtterance(string: voiceouttext)
        utterance.rate = 0.45
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        utterance.voice = sysvoice
        
    }
    
    func WaitSpeechtoFinishTimer() {


        self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
            
            print("transcript to be stopped 5 secs are finished")
            print(self.speechRecognizer.transcript)
            self.speechRecognizer.reset()

        })
        
        print("outside timer loop")
    }
    
    
   // This function will be called every time a speech finishes
   func speechDidFinish() {
//       print(self.isfinished)
//       self.isfinished = true
//       print(self.isfinished)
       
       if (popupspeak == true){
           
           //invoke check bus timing functon
           
       }
       
       
       if(verifybusstopbutton == false || popupspeak == false){
           
        

           self.speechRecognizer.reset()
           DispatchQueue.main.async {
               self.speechRecognizer.transcribe()
               self.WaitSpeechtoFinishTimer()


           }

       }
           
   }
    
    
    

    
}
   
    
    

//class texttospeech: AVSpeechUtterance {
//
//    var utterance = AVSpeechUtterance(string: "What bus number are you waiting for?")
//
//    let sysvoice = AVSpeechSynthesisVoice(language: "en-GB")
//
//    var hasbeenspoken = true
//
//    func initutterance(voiceouttext: String) {
//
//
//        utterance = AVSpeechUtterance(string: voiceouttext)
//
////        didFinish utterance
//
//        print(utterance.speechString)
//
//        utterance.rate = 0.45
//        utterance.pitchMultiplier = 0.8
//        utterance.postUtteranceDelay = 0.2
//        utterance.volume = 0.8
//
//        utterance.voice = sysvoice
//
////        utterance.
//    }
//
//
//    func speechsynthesiser()-> Bool {
//
////        self.hasbeenspoken = false
//        let synthesizer = AVSpeechSynthesizer()
//        synthesizer.speak(self.utterance)
//
////        var timetospeak = utterance.rate * Float(lengthutterance.speechString)
//
////        synthesizer.(_:didFinish:)
//
////        print(timetospeak)
//
////        while(synthesizer.isSpeaking){
////
////            continue
////        }
////
////        print(synthesizer.isPaused)
//
//        return synthesizer.isSpeaking
//
//
//    }
//
//
//
//}
//
//
//
//
//
//
////
////let utterance = AVSpeechUtterance(string: "The quick brown fox jumped over the lazy dog.")
////
////// Configure the utterance.
////utterance.rate = 0.57
////utterance.pitchMultiplier = 0.8
////utterance.postUtteranceDelay = 0.2
////utterance.volume = 0.8
////
////// Retrieve the British English voice.
////let voice = AVSpeechSynthesisVoice(language: "en-GB")
////
////// Assign the voice to the utterance.
////utterance.voice = voice
////
////// Create a speech synthesizer.
////let synthesizer = AVSpeechSynthesizer()
////
////// Tell the synthesizer to speak the utterance.
////synthesizer.speak(utterance)
//
