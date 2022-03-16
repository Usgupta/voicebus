//
//  SpeechRecognizer.swift
//  voicefeature
//
//  Created by Umang Gupta on 12/2/22.
//

import AVFoundation
import Foundation
import Speech
import SwiftUI

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
class SpeechRecognizer: ObservableObject {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    @Published var transcript: String = ""
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    
    /**
     Initializes a new speech recognizer. If this is the first time you've used the class, it
     requests access to the speech recognizer and the microphone.
     */
    init() {
        recognizer = SFSpeechRecognizer()
        
        Task(priority: .background) {
            do {
                guard recognizer != nil else {
                    throw RecognizerError.nilRecognizer
                }
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                speakError(error)
            }
        }
    }
    
    deinit {
        reset()
    }
    
    /**
        Begin transcribing audio.
     
        Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
        The resulting transcription is continuously written to the published `transcript` property.
     */
    func transcribe() {
       
        DispatchQueue(label: "Speech Recognizer Queue", qos: .background).async { [weak self] in
            guard let self = self, let recognizer = self.recognizer, recognizer.isAvailable else {
                self?.speakError(RecognizerError.recognizerIsUnavailable)
                return
            }
            
            var count = 0
            
            do {
                
                
                
                var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: "didFinishTalk", userInfo: nil, repeats: false)

                
                let (audioEngine, request) = try Self.prepareEngine()
                self.audioEngine = audioEngine
                self.request = request
                
                self.task = recognizer.recognitionTask(with: request) { result, error in
                    
                    
                    //trying to put a timer if no input  for 2 secs then stop accepting
//                    timer.invalidate()
//                    timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: "didFinishTalk", userInfo: nil, repeats: false)
                    
                    let receivedFinalResult = result?.isFinal ?? false
                    let receivedError = error != nil

                    var isFinal = false


                    if receivedFinalResult || receivedError {
                        audioEngine.stop()
                        audioEngine.inputNode.removeTap(onBus: 0)
                    }


//                    recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest,
//                    resultHandler: { (result, error) in
//
//                        var isFinal = false
//
//                        if result != nil {
//
//                            self.inputTextView.text = result?.bestTranscription.formattedString
//                            isFinal = (result?.isFinal)!
//                        }
//
//                        if let timer = self.detectionTimer, timer.isValid {
//                            if isFinal {
//                                self.inputTextView.text = ""
//                                self.textViewDidChange(self.inputTextView)
//                                self.detectionTimer?.invalidate()
//                            }
//                        } else {
//                            self.detectionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (timer) in
//                                self.handleSend()
//                                isFinal = true
//                                timer.invalidate()
//                            })
//                        }
//
//                    })
                    
                    timer.invalidate()
                    timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: "didFinishTalk", userInfo: nil, repeats: false)


                    if let result = result {
//                        count+=1
                        self.speak(result.bestTranscription.formattedString)
                        isFinal = result.isFinal
                        print(result)
                        print("before timer", result.bestTranscription.formattedString)
                        print("number",result.bestTranscription.formattedString.numericValue)
                        
//                        timer.invalidate()
//                        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: "didFinishTalk", userInfo: nil, repeats: false)
//
//                        print("after timer",result.bestTranscription.formattedString)

                        

//                        count 3 works for 1 input but not for some test cases like 125 or bigger numbers, also the issue of number is alphabets rather than digits

//                        if(count==4){
//                            print("we are stopping")
//                            print(result.bestTranscription.formattedString)
//
//                            self.reset()
//                        }
                        
//                        if  numberInput == "" {
//                            timer.invalidate()
//                            timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: "didFinishTalk", userInfo: nil, repeats: false)
//                        } else {
//                            // do your stuff using "strWord"
                            
                        }
//

                        // this is where the message of the transcript is stored can get the result from here to the screen,


                    


//                    if let timer = self.detectionTimer, timer.isValid {
//                        if isFinal {
//                            self.inputTextView.text = ""
//                            self.textViewDidChange(self.inputTextView)
//                            self.detectionTimer?.invalidate()
//
//                        }
//
//                    } else {
//                        self.detectionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (timer) in
////                            self.handleSend()
//                            isFinal = true
//                            timer.invalidate()
//
//                        }
//
//                    }
                    
                }
            } catch {
                self.reset()
                self.speakError(error)
            }
        }
    }
    
    /// Stop transcribing audio.
    func stopTranscribing() {
        reset()
    }
    
    /// Reset the speech recognizer.
    func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }
    
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    private func speak(_ message: String) {
        transcript = message
    }
    
    private func speakError(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        transcript = "<< \(errorMessage) >>"
    }
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}

extension String {

    var numericValue: NSNumber? {

        //init number formater
        let numberFormater = NumberFormatter()

        //check if string is numeric
        numberFormater.numberStyle = .decimal

        guard let number = numberFormater.number(from: self.lowercased()) else {

            //check if string is spelled number
            numberFormater.numberStyle = .spellOut

            //change language to spanish
            //numberFormater.locale = Locale(identifier: "es")

            return numberFormater.number(from: self.lowercased())
        }

        // return converted numeric value
        return number
    }
}
