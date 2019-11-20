//
//  LogInViewController.swift
//  SignInWithAppleDemo
//
//  Created by youngji Yoon on 2019/11/14.
//  Copyright © 2019 youngji Yoon. All rights reserved.
//

import UIKit
import AuthenticationServices


//<App Apple 로그인 로직>
//1. Apple Login 태우기(등록되지 않은 경우 - 등록 로직 / 기존에 등록한 경우 FaceID/TouchID 사용해서 로그인)
//2. userId/ID Token Return
//3. Server에 UserId/ID Token 전송
//4. Server에서 가지고 있는 정보 비교 U
//5-1. serId/ID Token존재 하면 로그인 Success
//5-2. 존재하지 않으면 웹뷰로 던져서(?? - 어떻게 연결하는지 잘 모르겠음//)회원가입 시키기


//고려사항
//1. 기기에 Apple 계정이 로그인 안되어 있는 경우 설정으로 뛰어넘어감 - 설정에서 계정 로그인 후에 앱으로 다시 넘어와서 애플로그인 버튼 다시 눌러서 진행 해야 됨
//2. Apple Login 성공 시 Retrun되는 name은 입력하는 사용자 마음대로 변경 가능, email Hide하면 apple에서 임시 email 부여함

//참고 : https://zeddios.tistory.com/782


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

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        //Error발생시 handling
        print(error)
    }
    
    //Signin Response
    //UserId - Unique, stable, team-scoped userID
    //       - 해당앱을 다른 기기에서 설치 하고 이름, 이메일 다르게 설정하더라도 UserId/IdentityToken은 변하지 않음(동일 앱에서 같은 계정으로 로그인했을 때 불변)
    //Account Information - Name, verified email
    
    //Apple SignIn 성공시 호출
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      
            //재 로그인 시에도 변하지 않는 데이터
            //로그인 - userId 비교 - 없으면 등록 - 있으면 로그인 처리
            print("User Id - \(appleIDCredential.user)")
            //fullName - PersonalNameComponent
            //         - NamePrefix, NameSuffix(Dr., Mr., Ms. ...)/ givenName(youngji)/MiddleName/ familyName(yoon)/ nickName
            print("User Name - \(appleIDCredential.fullName?.description ?? "N/A")")
            //Email - String
            print("User Email - \(appleIDCredential.email ?? "N/A")")
            //Real User Status - High confidence indicator that likely real user
            //                    -  likelyReal(2) : 진짜 사람으로 판단함
            //                    -  unknown(1) : 진짜 사람인지 판단하지 못함(hasn't)
            //                    -  unsupported(0) : 진짜 사람인지 판단할 수 없음(can't)
            print("Real User Status - \(appleIDCredential.realUserStatus.rawValue)")
            
            if let identityTokenData = appleIDCredential.identityToken,
                let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
                //IdentityToken - A JSON Web Token(JWT) that Securely communicates information about the user to your app.
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
//로그인 context창을 어디에 띄울건지
extension LogInViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
