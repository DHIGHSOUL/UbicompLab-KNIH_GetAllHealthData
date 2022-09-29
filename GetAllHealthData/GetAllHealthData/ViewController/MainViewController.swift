//
//  MainViewController.swift
//  GetAllHealthData
//
//  Created by ROLF J. on 2022/08/31.
//

import UIKit
import SnapKit
import HealthKit
import NVActivityIndicatorView

class MainViewController: UIViewController {
    
    static let shared = MainViewController()
    
    // MARK: - Instance member
    // SCH 로고
    private let schLogoImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.image = UIImage(named: "SCHLogo")
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    // '건강' 앱에 접근하는 인스턴스
    let healthStore = HKHealthStore()
    
    // 테스트 시작 일자 입력을 유도하는 Label
    private let testStartLabel: UILabel = {
        let label = UILabel()
        label.text = LanguageChange.MainViewWord.startTimeLabel
        label.textColor = .white
        
        return label
    }()
    // 테스트 시작 일자를 입력받을 TextField
    private let testStartTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .white
        field.textColor = .black
        field.textAlignment = .center
        field.tintColor = .clear
        
        return field
    }()
    
    // 테스 종료 일자 입력을 유도하는 Label
    private let testEndLabel: UILabel = {
        let label = UILabel()
        label.text = LanguageChange.MainViewWord.endTimeLabel
        label.textColor = .white
        
        return label
    }()
    // 테스트 종료 일자를 입력받을 TextField
    private let testEndTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .white
        field.textColor = .black
        field.textAlignment = .center
        field.tintColor = .clear
        
        return field
    }()
    
    // 파일 제작 및 업로드를 지시하는 Button
    private let makeAndUploadHealthDataButton: UIButton = {
        let button = UIButton()
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .systemBlue
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        button.setTitle(LanguageChange.MainViewWord.queryButton, for: .normal)
        
        return button
    }()
    
    // 테스트 시작 날짜를 입력받을 Date Picker
    private let startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .wheels
        picker.datePickerMode = .date
        
        return picker
    }()
    
    // 테스트 종료 날짜를 입력받을 Date Picker
    private let endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .wheels
        picker.datePickerMode = .date
        
        return picker
    }()
    
    // Date Picker에서 선택된 날짜(시작, 종료)
    var selectedStartDate: Date?
    var selectedEndDate: Date?

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HealthKitManager.shared.createHealthCSVFolder()
        mainViewLayout()
    }
    
    // MARK: - Override Method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Method
    
    // Main view의 레이아웃 지정
    private func mainViewLayout() {
        view.backgroundColor = .black
        
        startDatePicker.addTarget(self, action: #selector(startDatePickerValueDidChange(_ :)), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDatePickerValueDidChange(_ :)), for: .valueChanged)
        
        let views = [schLogoImageView, testStartTextField, testEndTextField, testStartLabel, testEndLabel, makeAndUploadHealthDataButton]
        
        for newView in views {
            view.addSubview(newView)
            newView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        schLogoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view)
            make.height.equalTo(100)
        }
        
        testStartTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(view.frame.width/6)
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        testStartTextField.inputView = startDatePicker
        
        testStartLabel.snp.makeConstraints { make in
            make.bottom.equalTo(testStartTextField.snp.top).offset(-10)
            make.centerX.equalTo(testStartTextField.snp.centerX)
        }
        
        testEndTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-(view.frame.width/6))
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        testEndTextField.inputView = endDatePicker
        
        testEndLabel.snp.makeConstraints { make in
            make.bottom.equalTo(testEndTextField.snp.top).offset(-10)
            make.centerX.equalTo(testEndTextField.snp.centerX)
        }
        
        makeAndUploadHealthDataButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
        makeAndUploadHealthDataButton.addTarget(self, action: #selector(pressUploadButton), for: .touchUpInside)
    }
    
    // MARK: - @objc Method
    // 테스트 시작 TextField를 눌렀을 때 보여질 DatePicker
    @objc private func startDatePickerValueDidChange(_ datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko-KR")
        self.selectedStartDate = startDatePicker.date
        self.testStartTextField.text = formatter.string(from: startDatePicker.date)
    }
    
    // 테스트 종료 TextField를 눌렀을 때 보여질 DatePicker
    @objc private func endDatePickerValueDidChange(_ datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko-KR")
        self.selectedEndDate = endDatePicker.date
        self.testEndTextField.text = formatter.string(from: endDatePicker.date)
    }
    
    // 업로드 버튼을 눌렀을 때 건강 데이터 업로드를 진행하는 메소드
    @objc private func pressUploadButton() {
        HealthKitManager.shared.makeHealthCSVFileAndUpload(startDate: selectedStartDate ?? Date(), endDate: selectedEndDate ?? Date())
    }
    
}
