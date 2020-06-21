//
//  ViewController.swift
//  Liza
//
//  Created by Alvin Bao on 5/17/20.
//  Copyright © 2020 Alvin Bao. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import FBSDKCoreKit
class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    var aT = AccessToken.current
    var postText1 = ""
    var timer : Timer?
    @IBOutlet weak var textField: UILabel!
    @IBOutlet weak var lisaField: UILabel!
    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func startButtonTapped(_ sender: UIButton) {
        self.recordAndRecognizeSpeech()
        //self.callWit()
    }
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            return
        }
        if !myRecognizer.isAvailable {
                // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
                    print("timer fired")
                    self.audioEngine.stop()
                    self.audioEngine.inputNode.removeTap(onBus: 0)
                    self.recognitionTask?.cancel()
                    self.callWit()
                    timer.invalidate()
                }
                let bestString = result.bestTranscription.formattedString
                //let utterance = AVSpeechUtterance(string: bestString)
                //let synthesizer = AVSpeechSynthesizer()
                //synthesizer.speak(utterance)
                self.textField.text = bestString
            } else if let error = error {
                    print(error)
            }
            
        })
    }
    func callWit() {
        
        let config = URLSessionConfiguration.default
        let authString = "Bearer PTTLAEVTXUR5D2NCMXIJ6DJ6GX4QUTRH"
        config.httpAdditionalHeaders = ["Authorization" : authString]
        let session = URLSession(configuration: config)
        let question = self.textField.text
        let newQuestion = (question?.replacingOccurrences(of: " ", with: "%20"))!
        let url = URL(string: "https://api.wit.ai/message?v=20200523&q=" + newQuestion)!
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil || data == nil {
                   print("Client error!")
                   return
               }
            print(data)
            print(response)
            print(error)
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let object = json as? [String: Any] {
                // json is a dictionary
                    print(object["intents"])
                    if let object2 = object["intents"] as? [Any]{
                        print(object2[0])
                        if let object3 = object2[0] as? [String:Any]{
                            //print(object3["name"]!)
                            let intentStr = object3["name"] as? String
                            self.handleIntent(astr: intentStr!)
                        }
                    }
                    
                }
               
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    func handleIntent(astr: String) {
        print(astr)
        switch astr {
        case "read_facebook_post": self.readFacebook()
        case "greeting": self.greeting()
        case "joke": self.joke()
        default: print("not recognized")
        }
    }
    func joke() {
        let number = Int.random(in: 0 ... 3)
        let joke = ["I don't trust stairs. They're always up to something.", "Did you hear the rumor about butter? Well, I'm not going to spread it!", "If you see a crime at an Apple Store, does that make you an iWitness?", "5/4 of people admit that they’re bad with fractions"]
        DispatchQueue.main.async { // Correct
            self.lisaField.text = joke[number]
            self.readText()
        }
       
    }
    func greeting() {
        DispatchQueue.main.async { // Correct
            self.lisaField.text = "Hello"
            self.readText()
        }
        
    }
    func readFacebook() {
        let session = URLSession.shared
        //let url = URL(string: "https://example.com/post")!
        var access = aT?.tokenString
        let url = URL(string: "https://graph.facebook.com/v7.0/104240324528205/feed?access_token=" + access!)!
        
        
        
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil || data == nil {
                   print("Client error!")
                   return
               }
            print(data)
            print(response)
            print(error)
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                print(json)
                if let object = json as? [String: Any] {
                // json is a dictionary
                    print(object["data"])
                    if let object2 = object["data"] as? [Any]{
                        print(object2[0])
                        if let object3 = object2[0] as? [String:Any] {
                            print(object3["message"]!)
                            self.postText1 = object3["message"]! as! String
                            DispatchQueue.main.async{
                                 self.performSegue(withIdentifier: "toPost", sender: self)
                            }
                           
                        }
                    }
                    
                }
               
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
            
        }
        
        task.resume()
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toPost"){
            var vc = segue.destination as! PostViewController
            vc.aT = AccessToken.current
            print(self.postText1)
            vc.getPostText = self.postText1
        } else if (segue.identifier == "toSettings") {
            var vc = segue.destination as! SettingsViewController
            vc.aT = AccessToken.current
        }
            
    }
    func readText() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print(error)
//            print("hey")
//        }
        let utterance = AVSpeechUtterance(string: self.lisaField.text!)
        utterance.volume = 1.0
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    func restartSpeechTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (timer) in
            // Do whatever needs to be done when the timer expires
        })
        timer.invalidate()
    }
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.button.isEnabled = true
                case .denied:
                    self.button.isEnabled = false
                    self.textField.text = "User denied access to speech recognition"
                case .restricted:
                    self.button.isEnabled = false
                    self.textField.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.button.isEnabled = false
                    self.textField.text = "Speech recognition not yet authorized"
                @unknown default:
                    return
                }
            }
        }
    }
}
        
    


