//
//  ContentView.swift
//  voice reply
//
//  Created by Umang Gupta on 7/2/22.
//

import SwiftUI
import InstantSearchVoiceOverlay

struct ContentView: View {
    
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    var transcript: String?
    @State var tts = texttospeech()
//    var tts: texttospeech
    
    
    
    var body: some View {
        
        VStack {
            Button("Verify Bus Timing", action: {
                
                print("what bus number are you waiting for")
                
                tts.initutterance()
                tts.speechsynthesiser()

                
                speechRecognizer.reset()
                speechRecognizer.transcribe()
                isRecording = true
                
//                print(isRecording)
                print(speechRecognizer.transcript)
                
            })
            
            
            Button("Stop recording", action: {
                
                print("stopped")
                
                speechRecognizer.stopTranscribing()
                isRecording = false
//                print(isRecording)
                print(speechRecognizer.transcript)
                
            })
        }
        
        
        
        

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}
