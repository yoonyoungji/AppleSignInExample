//
//  LogInViewController.swift
//  SignInWithAppleDemo
//
//  Created by youngji Yoon on 2019/11/14.
//  Copyright © 2019 youngji Yoon. All rights reserved.
//

import UIKit
import AuthenticationServices

class LogInViewController: UIViewController {

    @IBOutlet weak private var loginProviderStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeSignInBtn()
    }
    
    //애플로그인 버튼 만들기
    func makeSignInBtn(){
        //AppleSignin 버튼은 반드시 System이 제공해주는 버튼 사용
        //-Apple이 승인한 폰트, 컬러, 타이틀, 스타일 사용 보장 폰트
        
        //Type -  .Signin/ .Default/ .Continue
        // DefaultType = .Signin
        // Style - .black/ .White/ .WhiteOutLine
        
        let isDark = view.traitCollection.userInterfaceStyle == .dark
        let style : ASAuthorizationAppleIDButton.Style = isDark ? .white : .black
        
        let authorizeBtnSigninPhoneStyle = ASAuthorizationAppleIDButton.init(type: .signIn, style: style)
        authorizeBtnSigninPhoneStyle.addTarget(self, action: #selector(handleLoginWithApple), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizeBtnSigninPhoneStyle)
        
        let authorizeBtnContinueBlack = ASAuthorizationAppleIDButton.init(type: .continue, style: .black)
        authorizeBtnContinueBlack.addTarget(self, action: #selector(handleLoginWithApple), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizeBtnContinueBlack)
        
        let authorizeBtnDefaultWhite = ASAuthorizationAppleIDButton.init(type: .default, style: .white)
       authorizeBtnDefaultWhite.addTarget(self, action: #selector(handleLoginWithApple), for: .touchUpInside)
      self.loginProviderStackView.addArrangedSubview(authorizeBtnDefaultWhite)
        
        let authorizeBtnDefaultWhiteOutLine = ASAuthorizationAppleIDButton.init(type: .default, style: .whiteOutline)
        authorizeBtnDefaultWhiteOutLine.addTarget(self, action: #selector(handleLoginWithApple), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizeBtnDefaultWhiteOutLine)
    }
    
    //AppleSignIn 버튼 클릭했을 때 액션
    @objc func handleLoginWithApple(){
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        //요구 할 수 있는 데이터는 fullname, Email밖에 없음
//        @available(iOS 13.0, *)
//        public static let fullName: ASAuthorization.Scope
//
//        @available(iOS 13.0, *)
//        public static let email: ASAuthorization.Scope
        
        let authorizeController = ASAuthorizationController(authorizationRequests: [request])
        authorizeController.delegate = self
        authorizeController.presentationContextProvider = self
        authorizeController.performRequests()
    }

}


//MARK: - ASAuthorizationControllerDelegate
extension LogInViewController : ASAuthorizationControllerDelegate {
    //Error발생시 handling
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
    
    
    //Signin Response
    //UserId - Unique, stable, team-scoped userID
    //Verification data - Identity token, code
    //Account Information - Name, verified email
    //Real User indicator - High confidence indicator that likely real user
    //IdentityToken - A JSON Web Token(JWT) that Securely communicates information about the user to your app.

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      
            //재 로그인 시에도 변하지 않는 데이터
            //로그인 - userId 비교 - 없으면 등록 - 있으면 로그인 처리
            print("User Id - \(appleIDCredential.user)")
            print("User Name - \(appleIDCredential.fullName?.description ?? "N/A")")
            print("User Email - \(appleIDCredential.email ?? "N/A")")
            print("Real User Status - \(appleIDCredential.realUserStatus.rawValue)")
            
            if let identityTokenData = appleIDCredential.identityToken,
                let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
                print("Identity Token \(identityTokenString)")
                
                let saveInfo =
                              ["userIdentifier" : appleIDCredential.user,
                               "givenName" : appleIDCredential.fullName?.givenName ?? "N/A",
                               "familyName" : appleIDCredential.fullName?.familyName ?? "N/A",
                               "email" : appleIDCredential.email ?? "Do not Have Email",
                               "realUserState" : "\(appleIDCredential.realUserStatus.rawValue)",
                               "identityToken" : identityTokenString] as [String : String]
                
                UserDefaults.standard.set(saveInfo, forKey: "AppleSignInUserInfo")
                          
            }

            //Show Home View Controller
            HomeViewController.Push()
        }
        
    }
}


//MARK: - ASAuthorizationControllerPresentationContextProviding
extension LogInViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
