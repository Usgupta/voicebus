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
class TextToAudio: NSObject, CanSpeakDelegate {
    
    var speechRecognizer = SpeechRecognizer()
    
    var busStopCode = "not yet retrieved from bus api"
    var busTimings = "NIL"
    
    var busStopName = "NIL"
    
//    var showPopup: Binding<Bool>
//    @Published var showPopup: Bool = false
    
//    var showPopup = false
    
    
    var isfinished = false
    
    var verifybusstopbutton = false
    
    var isValidBusNo = false // to check if the transcript obtained is a bus number
    
    var BusNoExists = true //to check if the requested bus number exists for the bus stop
    
    var callpopup = true // to check whether to launch the popup or not
    
    var popupspeak = false // to check if we have to execute text to audio for speaking the content on the popup
    
    var timer = Timer.init()
    
    var busservices: [String] = []
    
    var invalidresp = false
    
    let canSpeak = CanSpeak()
    
    @State private var feedback = UINotificationFeedbackGenerator()
    
    
    
    

    
//    var voicereply = ""
    
    var utterance = AVSpeechUtterance(string: "What bus number are you waiting for?")
    
    let sysvoice = AVSpeechSynthesisVoice(language: "en-GB")
    
    let TTSques: String = "What bus number are you waiting for?" // text to ask user his desired bus stop number
    
    override init() {
        
        print("i am initialising text to speech")
        
        super.init()
        self.canSpeak.delegate = self
//        self.voicereply = ""
        self.isValidBusNo = false
        self.BusNoExists = true
        self.callpopup = true
        self.busservices = ["NIL"]
        self.invalidresp = false
        self.busStopName = "--"

//        self.showPopup = false
       
        
//        self.busStopCode = ""
        
        print("init speechrecog obj")
        
//        self.speechRecognizer = SpeechRecognizer()
        
        
        print("done init tts")
        
        
    }
    
    func initutterance(voiceouttext: String) {

        
        utterance = AVSpeechUtterance(string: voiceouttext)
        utterance.rate = 0.45
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 1
        utterance.voice = sysvoice
        
    }
    
    func WaitSpeechtoFinishTimer() {
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // 5 seconds timer, speech recognition stops after 5 seconds
        self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
            
            print("transcript to be stopped 5 secs are finished")
            print(self.speechRecognizer.transcript)
            
            let ValidBusNo: Int? = Int(self.speechRecognizer.transcript) // check if the bus number is a number
            
            if(ValidBusNo == nil){
                print("invalid input, pls press the button and try again")//speak this using texttoaudio and dont call bus api
                
                self.invalidresp = true // set invalid response to true
                self.callpopup = false
                self.canSpeak.sayThis("invalid input, please press the button and try again") // speak out that the user gave an invalid response
                
            }
            
            else{
                
                self.isValidBusNo = true
                // add the given bus number to our bus number array
                self.busservices.append(self.speechRecognizer.transcript)
                print(self.busservices, " bus no array")
                
            }
            
            
            print("destroying speech recognition task")
            self.speechRecognizer.reset()
            self.speechRecognizer.task?.finish()
            self.speechRecognizer.task?.cancel()
            
            print("re-initialiaing audio")
            
            // reinitialising audio for voiceover to continue working, as while destroying speech recognition, we destroy audio engine object as well,
            
            do{
                let _ = try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback,
                                                                        options: .duckOthers)
              }catch{
                  print(error)
              }

//            self.initutterance(voiceouttext: "")
            
      
            
            print("bus stop api is being invoked")
            print(self.busStopCode," bus stop code b4 bus api")
            
            BusArrivalApi().loadData(busStopCode: self.busStopCode, busServices: self.busservices) { item in
                  //                self.busArrivalResponses = item
                  //                self.busSvcNum = item.services[0].svcNum

                self.busTimings = ""
                print("inside bus api printing item",item)
                
                  for svc in self.busservices {
                      self.busTimings += "Bus \(svc) is coming in \(item[svc] ?? "NIL") minutes..\n"
                      
                      if (Int(item[svc] ?? "10") != 0) {
                          var notifytime = Double(item[svc] ?? "10")
                          notifytime = (notifytime ?? 10)*60
                          
                        print("HERE PRINT TIME \(String(describing: item[svc]))",notifytime)
                          
                          
                          
                          self.feedback.prepare()
                        
                          
                          
                          
                          let content = UNMutableNotificationContent()
                          content.title = "Your Bus is Arriving RIGHT NOW!"
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
                content.title = "Your Bus is Arriving!"
                content.subtitle = self.busTimings
    
                content.sound = UNNotificationSound.default //  default //plays sound
                self.feedback.notificationOccurred(.success) //vibrates buzz

                // show this notification five seconds from now


                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // add our notification request
                UNUserNotificationCenter.current().add(request)
                
                // to check if the bus number exists at your current location
//                if(item.isEmpty){
//
//                    self.invalidresp = true // set invalid response to true
//                    self.callpopup = false
//                    self.canSpeak.sayThis("bus number \(self.busservices) doesn't exist at \(self.busStopName), please press the button and try again") // speak out that the user gave an invalid response
//
//
//
//                }

            }
            
            print("setting popup cond to true")
            
//            self.showPopup = true
            
                              
            
        })
        
        print("outside timer loop")
        
    }
    
    
   // This function will be called every time a speech finishes
   func speechDidFinish() {
//       print(self.isfinished)
//       self.isfinished = true
//       print(self.isfinished)
       
       print("speech did finish invoked")
       
       if (popupspeak == true){
           
        // dont execute speech recognition
           
       }
       
       if(verifybusstopbutton == false && invalidresp == false){
           
           self.busservices = []
           
           DispatchQueue.main.async {
               
               
//               print(self.speechRecognizer.task?.state)
//               self.speechRecognizer.task?.finish()
               self.speechRecognizer.reset()
//               self.speechRecognizer = SpeechRecognizer()
               self.speechRecognizer.transcribe()
               self.WaitSpeechtoFinishTimer()


           }

       }
       
       else{
           verifybusstopbutton = false
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

