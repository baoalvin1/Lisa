//
//  LoginViewController.swift
//  Liza
//
//  Created by Alvin Bao on 5/25/20.
//  Copyright © 2020 Alvin Bao. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
class LoginViewController: UIViewController {
    @IBOutlet weak var lisaLogo: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.09, green: 0.47, blue: 0.95, alpha: 1.00)
        updateButton(isLoggedIn: (AccessToken.current != nil))
        self.lisaLogo.alpha = 0.0
        if self.lisaLogo.alpha == 0.0 {
            UIView.animate(withDuration: 1.5, delay: 1.0, options: .curveEaseOut, animations: {self.lisaLogo.alpha = 1.0})}
        self.loginButton.alpha = 0.0
        if self.loginButton.alpha == 0.0 {
        UIView.animate(withDuration: 1.5, delay: 2.0, options: .curveEaseOut, animations: {self.loginButton.alpha = 1.0})}
        
    }
    func updateButton(isLoggedIn: Bool) {
        // 1
        let title = isLoggedIn ? "Continue with Facebook" : "Log in with Facebook"
        loginButton.setTitle(title, for: .normal)
    }
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // 1
           let loginManager = LoginManager()
           
           if let _ = AccessToken.current {
            // Access token available -- user already logged in
            // Perform log out
            self.performSegue(withIdentifier: "toHome", sender: self)
               // 2
               //loginManager.logOut()
               updateButton(isLoggedIn: false)
               
           } else {
               // Access token not available -- user already logged out
               // Perform log in
               
               // 3
               loginManager.logIn(permissions: ["public_profile", "email"], from: self) { [weak self] (result, error) in
                    
                   // 4
                   // Check for error
                   guard error == nil else {
                       // Error occurred
                       print(error!.localizedDescription)
                       return
                   }
                   
                   // 5
                   // Check for cancel
                   guard let result = result, !result.isCancelled else {
                       print("User cancelled login")
                       return
                   }
                   self?.updateButton(isLoggedIn: true)
                   // Successfully logged in
                   // 6xs
                self?.performSegue(withIdentifier: "toHome", sender: self)
    }
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! ViewController
        vc.aT = AccessToken.current
    }
    
}

