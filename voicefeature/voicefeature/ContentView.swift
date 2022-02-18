//
//  ContentView.swift
//  voice reply
//
//  Created by Umang Gupta on 7/2/22.
//

import SwiftUI


struct ContentView: View {
    
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    var transcript: String?
    @State var tts = texttospeech()
//    var tts: texttospeech
    
    
    
    var body: some View {
        
      
        
        VStack {
           
            Button {
                tts.initutterance(voiceouttext: "hello")
                tts.speechsynthesiser()
                print("What bus number are you waiting for")
                speechRecognizer.reset()
                speechRecognizer.transcribe()
                isRecording = true
//              print(isRecording)
                print(speechRecognizer.transcript)

            } label: {
                HStack {
                    Image("gps")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Text("VERIFY BUS STOP")
                        .foregroundColor(Color.purple)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 30)).padding()
                }
                .padding(.all)
            }
            
            Spacer()
            
            Button {
                tts.initutterance(voiceouttext: "hello")
                tts.speechsynthesiser()
                print("What bus number are you waiting for")
                speechRecognizer.reset()
                speechRecognizer.transcribe()
                isRecording = true
//              print(isRecording)
                print(speechRecognizer.transcript)

            } label: {
                HStack {
                    Image("clock")
                        .resizable()
                    .aspectRatio(contentMode: .fit)
                    Text("VERIFY BUS TIME")
                        .foregroundColor(Color.purple)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 30)).padding()
                }
                .padding(.all)
      
            }
            

            Spacer()
            Image("voicebus_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 130.0, height: 130.0)
            
            
        VStack {
            Button("Verify Bus Timing", action: {

                    print("what bus number are you waiting for")
                    speechRecognizer.reset()
                    speechRecognizer.transcribe()
                    isRecording = true
    //              print(isRecording)
                    print(speechRecognizer.transcript)

            })
            
            Button("stop", action: {

                print("stopped")

                speechRecognizer.stopTranscribing()
                isRecording = false
//                print(isRecording)
                print(speechRecognizer.transcript)

            })


        }
            
           
        }
                
            }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}
