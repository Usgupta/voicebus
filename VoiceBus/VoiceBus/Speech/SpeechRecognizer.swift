//
//  SpeechRecognizer.swift
//  VoiceBus
//
//  Created by Umang Gupta on 5/5/22.
//

import AVFoundation
import Foundation
import Speech
import SwiftUI

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
class SpeechRecognizer: ObservableObject{
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
    public var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    
    public var count = 1

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
    
    
    /**
        Begin transcribing audio.
     
        Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
        The resulting transcription is continuously written to the published `transcript` property.
     */
        
    func transcribe() {
//        self.task?.cancel()
//        self.task?.finish()
        
        print("transribe invoked")

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let recognizer = self.recognizer, recognizer.isAvailable else {
                print("error in transcribe")
                self?.speakError(RecognizerError.recognizerIsUnavailable)
                return
            }
            
            do {
                let (audioEngine, request) = try
                SpeechRecognizer.prepareEngine()
                
                self.audioEngine = audioEngine
                self.request = request
                
                self.task = recognizer.recognitionTask(with: request) { result, error in
                                    
                    let receivedFinalResult = result?.isFinal ?? false
                    let receivedError = error != nil
                   
                    print("checkpt1")

                    if receivedFinalResult || receivedError {
                        
                        print("checkpt2 received final res", receivedFinalResult)
                        print("rec error", receivedError, "error ", error!)
//                        print(self.task?.state)
                        audioEngine.stop()
                        audioEngine.inputNode.removeTap(onBus: 0)
                    }

                    if let result = result {
                        
                        self.speak(result.bestTranscription.formattedString)
                        
                        print("i heard this ",result.bestTranscription.formattedString)
                    }
                    
                     print("checkpt4")
                    
                }
            } catch {
                print("checkpt3")
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
        request?.endAudio()
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

