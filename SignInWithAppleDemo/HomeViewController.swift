//
//  HomeViewController.swift
//  SignInWithAppleDemo
//
//  Created by youngji Yoon on 2019/11/14.
//  Copyright © 2019 youngji Yoon. All rights reserved.
//

import UIKit
import AuthenticationServices

class HomeViewController: UIViewController {

    @IBOutlet weak private var userIdentifierLabel: UILabel!
    @IBOutlet weak private var firstNameLabel: UILabel!
    @IBOutlet weak private var lastNameLabel: UILabel!
    @IBOutlet weak private var emailLabel: UILabel!
    @IBOutlet weak var realUserState: UILabel!
    
    
    //userDefaults 에 저장
    let defaultsData = UserDefaults.standard
    
    private var credentialRevokedNotification: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userInfoDic = defaultsData.value(forKey: "AppleSignInUserInfo") as? [String : String]

        userIdentifierLabel.text = userInfoDic?["userIdentifier"]
        firstNameLabel.text = userInfoDic?["givenName"]
        lastNameLabel.text = userInfoDic?["familyName"]
        emailLabel.text = userInfoDic?["email"]
        realUserState.text = userInfoDic?["realUserState"]

    }
    
    static func Push() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            return
        }
        guard let navigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController else {
            return
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    
    @IBAction func logoutButtonPressAction(_ sender: UIButton) {
        defaultsData.set(nil, forKey: "AppleSignInUserInfo")
        
        guard let navigationController = view.window?.rootViewController as? UINavigationController else {
            return    
        }
        navigationController.popViewController(animated: true)
    }
}
