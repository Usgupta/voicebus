//
//  TextToSpeech.swift
//  VoiceBus
//
//  Created by Umang Gupta on 5/5/22.
//

import AVFoundation
import SwiftUI

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
        
        
        print("say this func beg")
        
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = voiceToUse
        utterance.rate = 0.5
        utterance.volume = 0.8

        voiceSynth.speak(utterance)
        
        print("speaking completed, spoken text: ", utterance)
        
        do{
            let _ = try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback,
                                                                    options: .duckOthers)
          }catch{
              print(error)
          }
        
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        print("speech synthesizer func invoked")
        
        self.delegate.speechDidFinish()
       
   }
}

/// Describe what the class does
class TextToAudio: NSObject, CanSpeakDelegate {
    
    /// Speechrecognizer instance used to recognize all speech input
    var speechRecognizer = SpeechRecognizer()
    
    var busStopCode = "not yet retrieved from bus api"
    var busTimings = "NIL"
    
    var busStopName = "NIL"
    
    var isfinished = false
        
    var isValidBusNo = false // to check if the transcript obtained is a bus number
    
    var BusNoExists = true //to check if the requested bus number exists for the bus stop
    
    var timer = Timer.init()
    
    var busservices: [String] = []
    
    var verifybusStop : Void
    // put the verify bus stop code here
    var invalidresp = false // to check if they gave an invalid input
    
    let canSpeak = CanSpeak()
    
    @State private var feedback = UINotificationFeedbackGenerator() // for bus timing notifications

    var utterance = AVSpeechUtterance(string: "What bus number are you waiting for?")
    
    let sysvoice = AVSpeechSynthesisVoice(language: "en-GB")
    
    let TTSques: String = "What bus number are you waiting for?" // text to ask user his desired bus stop number
    
    override init() {
        
        super.init()
        self.canSpeak.delegate = self
        self.isValidBusNo = false
        self.BusNoExists = true
        self.busservices = ["NIL"]
        self.invalidresp = false
        self.busStopName = "--"
        
        print("done init tts")
        
        
    }
    
    fileprivate func createQueuedNotifcationFrom(dictionary item: [String : String], named service: String) {
        if (Int(item[service] ?? "10") != 0) {
            var notifytime = Double(item[service] ?? "10")
            notifytime = (notifytime ?? 10)*60
            
            print("HERE PRINT TIME \(String(describing: item[service])) \(String(describing: notifytime))")
            
            
            self.feedback.prepare()
            
            let content = UNMutableNotificationContent()
            content.title = "VoiceBus"
            content.subtitle = "Your Bus is Arriving RIGHT NOW!"
            //                          content.subtitle = self.busTimings
            content.sound = UNNotificationSound.default //plays sound
            self.feedback.notificationOccurred(.success) //vibrates buzz
            
            // schedule a 5 min alert, * min * 60
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notifytime ?? 60, repeats: false)
            
            // choose a random identifier
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            // add our notification request
            UNUserNotificationCenter.current().add(request)
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
                
            }
        }
        
        self.feedback.prepare()
        let content = UNMutableNotificationContent()
        content.title = "VoiceBus"
        content.subtitle = self.busTimings
        
        content.sound = UNNotificationSound.default //  default //plays sound
        self.feedback.notificationOccurred(.success) //vibrates buzz
        
        // show this notification five seconds from now
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request)
        
    }
    
    fileprivate func busApiFindBusTiming() {
        BusArrivalApi().loadData(busStopCode: self.busStopCode, busServices: self.busservices) { item in
            self.busTimings = ""

            
            for busService in self.busservices {
                self.busTimings += "Bus \(busService) is coming in \(item[busService] ?? "NIL") minutes..\n"
                if(item.isEmpty && self.invalidresp == false){
                    
                    self.invalidresp = true // set invalid response to true
                    self.canSpeak.sayThis("bus number \(self.busservices) either doesn't exist at \(self.busStopName), or is currently unavailable") // speak out that the user gave an invalid response
                    
                    self.busservices = ["NIL"]
                }
                
                else{
                    self.createQueuedNotifcationFrom(dictionary:item, named:busService)
                }
                
            }
            
        }
    }
    
    fileprivate func validresponse() {
        self.isValidBusNo = true
        // add the given bus number to our bus number array
        self.busservices.append(self.speechRecognizer.transcript)

    }
    
    fileprivate func invalidresponse() {

        
        self.invalidresp = true // set invalid response to true
        self.canSpeak.sayThis("invalid input, please press the button and try again")
    }
    
    fileprivate func reinitialiseAudio() {
        // reinitialising audio for voiceover to continue working, as while destroying speech recognition, we destroy audio engine object as well,
        
        do {
            let _ = try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback,
                                                                    options: .duckOthers)
        } catch {
            print(error)
        }
    }

    
    fileprivate func resetSpeechSynthesizer() {

        self.speechRecognizer.reset()
        self.speechRecognizer.task?.finish()
        self.speechRecognizer.task?.cancel()
    }
    
    fileprivate func buildtimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in

            print(self.speechRecognizer.transcript)

            defer {
                self.resetSpeechSynthesizer()
                self.reinitialiseAudio()
            }
            
            guard Int(self.speechRecognizer.transcript) != nil // check if the bus number is a number
            else {
                self.invalidresponse() // speak out that the user gave an invalid response
                return
            }
            
            self.validresponse()
            

            print(self.busStopCode," bus stop code b4 bus api")
            
            self.busApiFindBusTiming()
        })
    }
    func waitSpeechtoFinishTimer() -> Void{
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // 5 seconds timer, speech recognition stops after 5 seconds
        self.timer = buildtimer()
        
    }
    
// This function will be called every time a speech finishes
   func speechDidFinish() {

        if (invalidresp == false) {
           self.busservices = []
           DispatchQueue.main.async {
               self.speechRecognizer.reset()
               self.speechRecognizer.transcribe()
               self.waitSpeechtoFinishTimer()

           }
       }
   }
}
