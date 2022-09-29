//
//  SignInViewController.swift
//  GetAllHealthData
//
//  Created by ROLF J. on 2022/09/05.
//

import UIKit

class SignInViewController: UIViewController {
    
    // MARK: - Instance member
    // SCH 로고
    private let schLogoImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.image = UIImage(named: "SCHLogo")
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    // 유저번호 입력 유도 Label
    private let userIDLabel: UILabel = {
        let label = UILabel()
        label.text = LanguageChange.SignInViewWord.signInLabel
        label.textColor = .white
        
        return label
    }()
    
    // User ID를 입력받을 TextField
    private let userIDTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .white
        field.textColor = .black
        field.textAlignment = .center
        field.placeholder = LanguageChange.SignInViewWord.signInPlaceHolder
        
        return field
    }()
    
    // 로그인 버튼
    private let signInButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle(LanguageChange.SignInViewWord.signInButton, for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .systemBlue
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        signInViewLayout()
    }
    
    // MARK: - Override Method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Method
    // 뷰의 레이아웃 지정
    private func signInViewLayout() {
        view.backgroundColor = .black
        
        let views = [schLogoImageView, userIDLabel, userIDTextField, signInButton]
        
        for newView in views {
            view.addSubview(newView)
            newView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        schLogoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view)
            make.height.equalTo(100)
        }
        
        userIDTextField.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalTo(view.frame.width/3)
            make.trailing.equalTo(-(view.frame.width/3))
            make.height.equalTo(50)
        }
        userIDLabel.snp.makeConstraints { make in
            make.bottom.equalTo(userIDTextField.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        signInButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.frame.width/3)
            make.trailing.equalTo(-(view.frame.width/3))
            make.height.equalTo(40)
        }
        signInButton.addTarget(self, action: #selector(pressSignInButton), for: .touchUpInside)
    }
    
    // 아이디에 문자가 들어가 있는 경우
    private func idHaveString() -> Bool {
        if Int(userIDTextField.text ?? "numberOnly") == nil {
            let stringAlert = UIAlertController(title: LanguageChange.AlertWord.onlyNumber, message: LanguageChange.AlertWord.typeAgain, preferredStyle: .alert)
            let okButton = UIAlertAction(title: LanguageChange.AlertWord.alertConfirm, style: .default) { _ in
                self.userIDTextField.text = ""
            }
            stringAlert.addAction(okButton)
            present(stringAlert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    // 아이디가 3자리가 아닌 경우
    private func idLength0() -> Bool {
        if userIDTextField.text?.count != 3 {
            let lengthAlert = UIAlertController(title: LanguageChange.AlertWord.IDLength3, message: LanguageChange.AlertWord.typeAgain, preferredStyle: .alert)
            let okButton = UIAlertAction(title: LanguageChange.AlertWord.alertConfirm, style: .default) { _ in
                self.userIDTextField.text = ""
            }
            lengthAlert.addAction(okButton)
            present(lengthAlert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    // 아이디가 올바른지 확인하는 메소드
    private func checkIDCorrect() -> Bool {
        if idHaveString() == true && idLength0() == true {
            return true
        }
        return false
    }
    
    // MARK: - @objc Method
    // 로그인 버튼 클릭 시 메소드
    @objc private func pressSignInButton() {
        if checkIDCorrect() == false {
            return
        }
        
        let userID = "S\(userIDTextField.text ?? "997")"
        UserDefaults.standard.setValue(userID, forKey: "UserID")
        UserDefaults.standard.setValue(true, forKey: "appAuthorization")
        
        let successAlert = UIAlertController(title: LanguageChange.AlertWord.signInComplete, message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction(title: LanguageChange.AlertWord.alertConfirm, style: .default) { _ in
            print("Login complete, Set MainViewController")
            let mainViewController = MainViewController()
            mainViewController.modalPresentationStyle = .fullScreen
            self.present(mainViewController, animated: true, completion: nil)
        }
        successAlert.addAction(okButton)
        present(successAlert, animated: true, completion: nil)
    }
    
}
