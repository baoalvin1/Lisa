//
//  PostViewController.swift
//  Liza
//
//  Created by Alvin Bao on 5/30/20.
//  Copyright © 2020 Alvin Bao. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import Speech
import AVFoundation
class PostViewController: UIViewController{
    var aT = AccessToken.current
    var getPostText = ""
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postText.text = getPostText
        self.setProfile()
        self.readText()
    }
    func readText() {
        let utterance = AVSpeechUtterance(string: self.postText.text!)
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    func setProfile(){
        let session = URLSession.shared
        var access = aT?.tokenString
        let url = URL(string: "https://graph.facebook.com/v7.0/104240324528205/picture")!
        let url2 = URL(string: "https://graph.facebook.com/v7.0/104240324528205/?access_token=" + access!)!
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
                do {
                    let downloadedImage = UIImage(data: data!)
                    DispatchQueue.main.async {
                        self.profilePicture.image = downloadedImage
                    }
                   
                    
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                }
            }
            
            task.resume()
        let task2 = session.dataTask(with: url2) { data, response, error in
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
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let object = json as? [String: Any] {
                               // json is a dictionary
                    print(object["name"]!)
                    DispatchQueue.main.async {
                        self.profileName.text = object["name"]! as! String
                    }
                }
               
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        
        task2.resume()
        }
    
}
