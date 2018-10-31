//
//  LoginViewController.swift
//  presensesample
//
//  Created by Neo Ighodaro on 16/10/2018.
//  Copyright © 2018 TapSharp. All rights reserved.
//

import UIKit
import Alamofire
import PusherSwift
import NotificationBannerSwift

class LoginViewController: UIViewController {
    
    var user: User? = nil
    var users: [User] = []

    var pusher: Pusher!

    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        user = nil
        users = []
        
        navigationController?.isNavigationBarHidden = true
    }
    
    fileprivate func registerUser(_ params: [String : String], handler: @escaping(Bool) -> Void) {
        Alamofire.request("http://127.0.0.1:5000/users", method: .post, parameters: params)
            .validate()
            .responseJSON { resp in
                if resp.result.isSuccess,
                    let data = resp.result.value as? [String: Any],
                    let user = data["currentUser"] as? [String: String],
                    let users = data["users"] as? [String: [String: String]],
                    let id = user["id"],
                    let name = user["name"]
                {
                    for (uid, user) in users {
                        if let name = user["name"], id != uid {
                            self.users.append(User(id: uid, name: name))
                        }
                    }
                    
                    self.user = User(id: id, name: name)
                    self.nameTextField.text = nil
                    
                    return handler(true)
                }
                
                handler(false)
        }
    }
    
    @IBAction func startChattingButtonPressed(_ sender: Any) {
        if nameTextField.text?.isEmpty == false, let name = nameTextField.text {
            registerUser(["name": name.lowercased()]) { successful in
                guard successful else {
                    return StatusBarNotificationBanner(title: "Failed to login.", style: .danger).show()
                }

                self.performSegue(withIdentifier: "showmain", sender: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MainViewController {
            vc.viewControllers?.forEach {
                if let onlineVc = $0 as? OnlineTableViewController {
                    onlineVc.users = self.users
                    onlineVc.user = self.user
                }
            }
        }
    }

}
