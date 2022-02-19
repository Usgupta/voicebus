//
//  ContentView.swift
//  voice reply
//
//  Created by Umang Gupta on 7/2/22.
//

import SwiftUI



struct ContentView: View {
    
    
//    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    var transcript: String?
//    @State var tts = texttospeech()
    
    @State var texttoaudio = TextToAudio()
    
    
//    var tts: texttospeech
    
    
    
    var body: some View {
        
      
        
        VStack {
           
            Button {
                
                texttoaudio.canSpeak.sayThis("Based on your current location, you are currently at <get bus stop from bus api>")
                
                
//                tts.initutterance(voiceouttext: "Based on your current location, you are currently at <get bus stop from bus api>")
//                tts.speechsynthesiser()
//                print("What bus number are you waiting for")
//                speechRecognizer.reset()
//                speechRecognizer.transcribe()
//                isRecording = true
////              print(isRecording)
//                print(speechRecognizer.transcript)

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
                
//                gs.initutterance(voiceouttext: "What bus number are you waiting for")
                
            texttoaudio.canSpeak.sayThis("What bus number are you waiting for")
                
                
//                var timer = Timer()
                
//                var th = NSCondition()
//
//                th.wait(texttoaudio.isfinished){
//
//                    print("wait done")
//                }
                
                
                
                
                
                
                

                
//                print("while loop done")
                
                
            
//                if(texttoaudio.speechDidFinish()){
//
//                    print("if executed")
//                }
                
                
                
//                tts.initutterance(voiceouttext: "What bus number are you waiting for")
//                var isspeaken = tts.speechsynthesiser()
//
//
//                print(isspeaken)
//
                
//                print("What bus number are you waiting for") //need to print on the screen
//
//                speechRecognizer.reset()
//                speechRecognizer.transcribe()
//                isRecording = true
////              print(isRecording)
//                print(speechRecognizer.transcript)
//                
//                Thread.sleep(forTimeInterval:1)
//
//                print("stopped")
//                speechRecognizer.stopTranscribing()
//                print(speechRecognizer.transcript)
                

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
//                    speechRecognizer.reset()
//                    speechRecognizer.transcribe()
//                    isRecording = true
//    //              print(isRecording)
//                    print(speechRecognizer.transcript)

            })
            
            Button("stop", action: {

                print("stopped")

//                speechRecognizer.stopTranscribing()
//                isRecording = false
////                print(isRecording)
//                print(speechRecognizer.transcript)

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
