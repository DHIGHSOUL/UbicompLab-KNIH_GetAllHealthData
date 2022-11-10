//
//  UploadViewController.swift
//  GetAllHealthData
//
//  Created by ROLF J. on 2022/09/28.
//

import UIKit
import NVActivityIndicatorView

class UploadViewController: UIViewController {
    
    static let uploadViewController = UploadViewController()
    
    // MARK: - Instance member
    private var startDate = Date()
    private var endDate = Date()
    private var startDateString = String()
    private var endDateString = String()
    private var userID = String()
    
    private let startDateLabel = UILabel()
    private let endDateLabel = UILabel()
    
    private let userIDLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.textColor = .white
        return label
    }()
    
    private let uploadStepCountButton: UIButton = {
        let button = UIButton()
        button.setTitle(LanguageChange.UploadViewWord.uploadStepButton, for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .systemBlue
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    private let uploadburnedEnergyButton: UIButton = {
        let button = UIButton()
        button.setTitle(LanguageChange.UploadViewWord.uploadEnergyButton, for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .systemBlue
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    private let uploadDistanceButton: UIButton = {
        let button = UIButton()
        button.setTitle(LanguageChange.UploadViewWord.uploadDistanceButton, for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .systemBlue
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    private let uploadSleepButton: UIButton = {
        let button = UIButton()
        button.setTitle(LanguageChange.UploadViewWord.uploadSleepButton, for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .systemBlue
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    private let uploadHRButton: UIButton = {
        let button = UIButton()
        button.setTitle(LanguageChange.UploadViewWord.uploadHRButton, for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .systemBlue
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getDatas()
        setButtonActivation()
        uploadViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setButtonActivation()
    }
    
    // MARK: - Method
    private func setButtonActivation() {
        if (UserDefaults.standard.value(forKey: "stepUploaded") != nil) == true {
            var buttonConfiguration = UIButton.Configuration.filled()
            buttonConfiguration.baseBackgroundColor = .lightGray
            buttonConfiguration.baseForegroundColor = .white
            uploadStepCountButton.configuration = buttonConfiguration
            uploadStepCountButton.isEnabled = false
        }
        if (UserDefaults.standard.value(forKey: "energyUploaded") != nil) == true {
            var buttonConfiguration = UIButton.Configuration.filled()
            buttonConfiguration.baseBackgroundColor = .lightGray
            buttonConfiguration.baseForegroundColor = .white
            uploadburnedEnergyButton.configuration = buttonConfiguration
            uploadburnedEnergyButton.isEnabled = false
        }
        if (UserDefaults.standard.value(forKey: "distanceUploaded") != nil) == true {
            var buttonConfiguration = UIButton.Configuration.filled()
            buttonConfiguration.baseBackgroundColor = .lightGray
            buttonConfiguration.baseForegroundColor = .white
            uploadDistanceButton.configuration = buttonConfiguration
            uploadDistanceButton.isEnabled = false
        }
        if (UserDefaults.standard.value(forKey: "sleepUploaded") != nil) == true {
            var buttonConfiguration = UIButton.Configuration.filled()
            buttonConfiguration.baseBackgroundColor = .lightGray
            buttonConfiguration.baseForegroundColor = .white
            uploadSleepButton.configuration = buttonConfiguration
            uploadSleepButton.isEnabled = false
        }
        if (UserDefaults.standard.value(forKey: "heartRateUploaded") != nil) == true {
            var buttonConfiguration = UIButton.Configuration.filled()
            buttonConfiguration.baseBackgroundColor = .lightGray
            buttonConfiguration.baseForegroundColor = .white
            uploadHRButton.configuration = buttonConfiguration
            uploadHRButton.isEnabled = false
        }
    }
    
    private func getDatas() {
        startDate = Date.init(timeIntervalSince1970: UserDefaults.standard.value(forKey: "testStartDate") as! TimeInterval)
        endDate = Date.init(timeIntervalSince1970: UserDefaults.standard.value(forKey: "testEndDate") as! TimeInterval)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd - HH:mm:ss"
        formatter.locale = Locale(identifier: "ko-KR")
        startDateLabel.textAlignment = .center
        endDateLabel.textAlignment = .center
        startDateLabel.text = formatter.string(from: startDate)
        endDateLabel.text = formatter.string(from: endDate)
        userID = UserDefaults.standard.value(forKey: "UserID") as! String
        userIDLabel.text = userID
    }
    
    private func uploadViewLayout() {
        view.backgroundColor = .black
        
        let views = [userIDLabel, startDateLabel, endDateLabel, uploadStepCountButton, uploadburnedEnergyButton, uploadDistanceButton, uploadSleepButton, uploadHRButton]
        
        for newView in views {
            view.addSubview(newView)
            newView.clipsToBounds = true
            newView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        userIDLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(30)
        }
        
        uploadDistanceButton.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        uploadDistanceButton.addTarget(self, action: #selector(pressUploadDistnaceCountButton), for: .touchUpInside)
        
        uploadburnedEnergyButton.snp.makeConstraints { make in
            make.bottom.equalTo(uploadDistanceButton.snp.top).offset(-10)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        uploadburnedEnergyButton.addTarget(self, action: #selector(pressUploadEnergyCountbutton), for: .touchUpInside)
        
        uploadStepCountButton.snp.makeConstraints { make in
            make.bottom.equalTo(uploadburnedEnergyButton.snp.top).offset(-10)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        uploadStepCountButton.addTarget(self, action: #selector(pressUploadStepCountButton), for: .touchUpInside)
        
        uploadSleepButton.snp.makeConstraints { make in
            make.top.equalTo(uploadDistanceButton.snp.bottom).offset(10)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        uploadSleepButton.addTarget(self, action: #selector(pressUploadSleepButton), for: .touchUpInside)
        
        uploadHRButton.snp.makeConstraints { make in
            make.top.equalTo(uploadSleepButton.snp.bottom).offset(10)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        uploadHRButton.addTarget(self, action: #selector(pressUploadHRButton), for: .touchUpInside)
        
        endDateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.equalTo(view)
            make.height.equalTo(30)
        }
        
        startDateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(endDateLabel.snp.top).offset(-20)
            make.width.equalTo(view)
            make.height.equalTo(30)
        }
    }
    
    // MARK: - @objc Method
    @objc private func pressUploadStepCountButton() {
        print("Upload stepCount\nstartDate = \(startDate), endDate = \(endDate)")
        let indicator = NVActivityIndicatorView(frame: CGRect(x: view.frame.midX - 50, y: view.frame.midY - 50, width: 100, height: 100), type: .ballSpinFadeLoader, color: .lightGray, padding: 0)
        view.addSubview(indicator)
        indicator.bounds = view.frame
        indicator.startAnimating()
        HealthKitManager.shared.queryingStepCount(startDate: startDate, endDate: endDate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            indicator.stopAnimating()
            UserDefaults.standard.set(true, forKey: "stepUploaded")
            self.setButtonActivation()
        }
    }
    
    @objc private func pressUploadEnergyCountbutton() {
        print("Upload activeEnergyBurned\nstartDate\(startDate), endDate = \(endDate)")
        let indicator = NVActivityIndicatorView(frame: CGRect(x: view.frame.midX - 50, y: view.frame.midY - 50, width: 100, height: 100), type: .ballSpinFadeLoader, color: .lightGray, padding: 0)
        view.addSubview(indicator)
        indicator.bounds = view.frame
        indicator.startAnimating()
        HealthKitManager.shared.queryingEnergyCount(startDate: startDate, endDate: endDate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            indicator.stopAnimating()
            UserDefaults.standard.set(true, forKey: "energyUploaded")
            self.setButtonActivation()
        }
    }
    
    @objc private func pressUploadDistnaceCountButton() {
        print("Upload distanceWalkingRunning\nstartDate = \(startDate), endDate = \(endDate)")
        print("Upload activeEnergyBurned\nstartDate\(startDate), endDate = \(endDate)")
        let indicator = NVActivityIndicatorView(frame: CGRect(x: view.frame.midX - 50, y: view.frame.midY - 50, width: 100, height: 100), type: .ballSpinFadeLoader, color: .lightGray, padding: 0)
        view.addSubview(indicator)
        indicator.bounds = view.frame
        indicator.startAnimating()
        HealthKitManager.shared.queryingDistanceCount(startDate: startDate, endDate: endDate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            indicator.stopAnimating()
            UserDefaults.standard.set(true, forKey: "distanceUploaded")
            self.setButtonActivation()
        }
    }
    
    @objc private func pressUploadSleepButton() {
        print("Upload sleepAnalysis\nstartDate = \(startDate), endDate = \(endDate)")
        let indicator = NVActivityIndicatorView(frame: CGRect(x: view.frame.midX - 50, y: view.frame.midY - 50, width: 100, height: 100), type: .ballSpinFadeLoader, color: .lightGray, padding: 0)
        view.addSubview(indicator)
        indicator.bounds = view.frame
        indicator.startAnimating()
        HealthKitManager.shared.queryingSleepCount(startDate: startDate, endDate: endDate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            indicator.stopAnimating()
            UserDefaults.standard.set(true, forKey: "sleepUploaded")
            self.setButtonActivation()
        }
    }
    
    @objc private func pressUploadHRButton() {
        print("Upload heartRate\nstartDate = \(startDate), endDate = \(endDate)")
        let indicator = NVActivityIndicatorView(frame: CGRect(x: view.frame.midX - 50, y: view.frame.midY - 50, width: 100, height: 100), type: .ballSpinFadeLoader, color: .lightGray, padding: 0)
        view.addSubview(indicator)
        indicator.bounds = view.frame
        indicator.startAnimating()
        HealthKitManager.shared.queryingHRCount(startDate: startDate, endDate: endDate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            indicator.stopAnimating()
            UserDefaults.standard.set(true, forKey: "heartRateUploaded")
            self.setButtonActivation()
        }
    }
}
