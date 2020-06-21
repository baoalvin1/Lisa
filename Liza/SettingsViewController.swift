//
//  SettingsViewController.swift
//  Liza
//
//  Created by Alvin Bao on 6/21/20.
//  Copyright © 2020 Alvin Bao. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
class SettingsViewController: UIViewController {
    var aT = AccessToken.current
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        let loginManager = LoginManager()
        
        if let _ = AccessToken.current {
         // Access token available -- user already logged in
         // Perform log out
         self.performSegue(withIdentifier: "toLogin", sender: self)
            // 2
            loginManager.logOut()
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toLogin"){
            var vc = segue.destination as! LoginViewController
        }
       
    }
}
