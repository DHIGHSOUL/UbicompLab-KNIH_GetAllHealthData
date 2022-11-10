//
//  HealthKitManager.swift
//  GetAllHealthData
//
//  Created by ROLF J. on 2022/09/22.
//

import Foundation
import HealthKit

class HealthKitManager {
    
    static let shared = HealthKitManager()
    
    let healthStore = HKHealthStore()
    
    // MARK: - Instance member
    // 걸음 수 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startDate, endTime, data) 배열, 업로드를 위한 문자열
    var stepDataArray: [HKSample] = []
    var iPhoneStepStringDataArray: [String] = []
    var AWatchStepStringDataArray: [String] = []
    var iPhoneStepStringToUpload = ""
    var AWatchStepStringToUpload = ""
    var iPhoneStepStringArray: [String] = []
    var AWatchStepStringArray: [String] = []
    var iPhoneStepCSVIndex: Int = 0
    var AWatchStepCSVIndex: Int = 0
    
    // 활성 에너지 수 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startDate, endTime, data) 배열, 업로드를 위한 문자열
    var energyDataArray: [HKSample] = []
    var iPhoneEnergyStringDataArray: [String] = []
    var AWatchEnergyStringDataArray: [String] = []
    var iPhoneEnergyStringToUpload = ""
    var AWatchEnergyStringToUpload = ""
    var iPhoneEnergyStringArray: [String] = []
    var AWatchEnergyStringArray: [String] = []
    var iPhoneEnergyCSVIndex: Int = 0
    var AWatchEnergyCSVIndex: Int = 0
    
    // 걷고 뛴 거리 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startDate, endTime, data) 배열, 업로드를 위한 문자열
    var distanceDataArray: [HKSample] = []
    var iPhoneDistanceStringDataArray: [String] = []
    var AWatchDistanceStringDataArray: [String] = []
    var iPhoneDistanceStringToUpload = ""
    var AWatchDistanceStringToUpload = ""
    var iPhoneDistanceStringArray: [String] = []
    var AWatchDistanceStringArray: [String] = []
    var iPhoneDistanceCSVIndex: Int = 0
    var AWatchDistanceCSVIndex: Int = 0
    
    // 수면 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startDate, endTime, data) 배열, 업로드를 위한 문자열
    var sleepDataArray: [HKCategorySample] = []
    var iPhoneSleepStringDataArray: [String] = []
    var AWatchSleepStringDataArray: [String] = []
    var iPhoneSleepStringToUpload = ""
    var AWatchSleepStringToUpload = ""
    var iPhoneSleepStringArray: [String] = []
    var AWatchSleepStringArray: [String] = []
    var iPhoneSleepCSVIndex: Int = 0
    var AWatchSleepCSVIndex: Int = 0
    
    // 심박수 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startDate, endTime, data) 배열, 업로드를 위한 문자열
    var heartRateDataArray: [HKSample] = []
    var iPhoneHeartRateStringDataArray: [String] = []
    var AWatchHeartRateStringDataArray: [String] = []
    var iPhoneHeartRateStringToUpload = ""
    var AWatchHeartRateStringToUpload = ""
    var iPhoneHeartRateStringArray: [String] = []
    var AWatchHeartRateStringArray: [String] = []
    var iPhoneHeartRateCSVIndex: Int = 0
    var AWatchHeartRateCSVIndex: Int = 0
    
    // Health 데이터의 컨테이너 이름 배열
    let healthContainerNameArray: [String] = ["steps", "calories", "distance", "sleep", "HR"]
    
    // MARK: - Method
    // 건강 데이터를 저장할 CSV 폴더를 생성하는 메소드
    func createHealthCSVFolder() {
        print(getDocumentsDirectory())
        let fileManager = FileManager.default
        
        let folderName = "healthCSVFolder"
        
        let documentUrl: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentUrl)
        let directoryUrl: URL = documentUrl.appendingPathComponent(folderName)
        
        do {
            if #available(iOS 16.0, *) {
                try fileManager.createDirectory(atPath: directoryUrl.path(percentEncoded: true), withIntermediateDirectories: true, attributes: nil)
            } else {
                try fileManager.createDirectory(atPath: directoryUrl.path, withIntermediateDirectories: true, attributes: nil)
            }
        }
        catch let error as NSError {
            print("폴더 생성 에러: \(error)")
            return
        }
        
        print("Health Data용 CSV 폴더 생성됨")
    }
    
    // 건강 데이터를 CSV 파일에 저장하는 메소드
    func writeHealthCSV(healthData: String, deviceType: String, dataType: String, index: Int) {
        let fileManager = FileManager.default
        
        print("\(deviceType)_\(dataType)_\(index).csv 파일 생성됨")
        let folderName = "healthCSVFolder"
        let csvFileName = "\(deviceType)_\(dataType)_\(index).csv"
        
        let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryUrl = documentUrl.appendingPathComponent(folderName)
        
        let fileUrl: URL = directoryUrl.appendingPathComponent(csvFileName)
        let fileData = healthData.data(using: .utf8)
        
        do {
            try fileData?.write(to: fileUrl)
            print("Writing CSV to: \(fileUrl.path)")
        }
        catch let error as NSError {
            print("CSV파일 생성 에러: \(error)")
        }
        
//        do {
//            let dataFromPath: Data = try Data(contentsOf: fileUrl)
//            let text: String = String(data: dataFromPath, encoding: .utf8) ?? "문서 없음"
//            print(text)
//        } catch let error {
//            print(error.localizedDescription)
//        }
    }
    
    // 건강 정보를 읽기 위해 사용자의 허가를 얻는 메소드
    func requestHealthDataAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            let read = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!, HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, HKObjectType.quantityType(forIdentifier: .stepCount)!, HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!, HKQuantityType.quantityType(forIdentifier: .heartRate)!])
            let share = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!, HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, HKObjectType.quantityType(forIdentifier: .stepCount)!, HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!, HKQuantityType.quantityType(forIdentifier: .heartRate)!])
            
            healthStore.requestAuthorization(toShare: share, read: read) { (success, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "HealthKit Error")
                    self.requestHealthDataAuthorization()
                } else {
                    if success {
                        print("HealthKit 권한이 허가되었습니다.")
                    } else {
                        print("HealthKit 권한이 없습니다.")
                        self.requestHealthDataAuthorization()
                    }
                }
            }
        }
    }
    
    // 걸음 수를 얻는 메소드
    func getStepCountPerDay(startDate: Date, endDate: Date) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let startTime = Calendar.current.startOfDay(for: startDate)
        let endDateAdding = Calendar.current.date(byAdding: .day, value: +1, to: endDate)
        let endTime = Calendar.current.startOfDay(for: endDateAdding ?? Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: endTime, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (_, result, error) in
            if let error = error {
                print("Step Query Error, Set Error String : \(error.localizedDescription)")
                let errorStepString = "\(Int(startTime.timeIntervalSince1970)),\(Int(endTime.timeIntervalSince1970)),iPhone,-1"
                self.iPhoneStepStringDataArray.append(errorStepString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                if result?.count == 0 {
                    print("Step Query Count(No Data) Error, Set Error String")
                    let errorStepString = "\(Int(startTime.timeIntervalSince1970)),\(Int(endTime.timeIntervalSince1970)),iPhone,0"
                    self.iPhoneStepStringDataArray.append(errorStepString)
                    return
                } else if let results = result {
                    print("Step Query No Error, Start Appending Results In Array")
                    for newResult in results {
                        self.stepDataArray.append(newResult)
                    }
                }
                
                print("No Error, Start Convert Step Data To String")
                for newData in self.stepDataArray {
                    let startCollectTime = Int(newData.startDate.timeIntervalSince1970)
                    let endCollectTime = Int(newData.endDate.timeIntervalSince1970)
                    let collectDevice = newData.device?.model
                    let printResultToQuantity: HKQuantitySample = newData as! HKQuantitySample
                    let collectedStepData = Int(printResultToQuantity.quantity.doubleValue(for: .count()))
                    if collectDevice == "iPhone" {
                        let newStepData = "\(startCollectTime),\(endCollectTime),\(collectDevice ?? "Error"),\(collectedStepData)"
                        self.iPhoneStepStringDataArray.append(newStepData)
                    } else if collectDevice == "Watch" {
                        let newStepData = "\(startCollectTime),\(endCollectTime),\(collectDevice ?? "Error"),\(collectedStepData)"
                        self.AWatchStepStringDataArray.append(newStepData)
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // 사용한 활성에너지(cal)를 얻는 메소드
    func getActiveEnergyPerDay(startDate: Date, endDate: Date) {
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let startDate = Calendar.current.startOfDay(for: startDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: activeEnergyType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (_, result, error) in
            if let error = error {
                print("Energy Query Error, Set Error String : \(error.localizedDescription)")
                let errorEnergyString = "\(Int(startDate.timeIntervalSince1970)),\(Int(endDate.timeIntervalSince1970)),iPhone,-1"
                self.iPhoneEnergyStringDataArray.append(errorEnergyString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                if result?.count == 0 {
                    print("Energy Query Count(No Data) Error, Set Error String")
                    let errorEnergyString = "\(Int(startDate.timeIntervalSince1970)),\(Int(endDate.timeIntervalSince1970)),iPhone,0"
                    self.iPhoneEnergyStringDataArray.append(errorEnergyString)
                    return
                } else if let results = result {
                    print("Energy Query No Error, Start Appending Results In Array")
                    for newResult in results {
                        self.energyDataArray.append(newResult)
                    }
                }
                
                print("No Error, Start Convert Energy Data To String")
                for newData in self.energyDataArray {
                    let startCollectTime = Int(newData.startDate.timeIntervalSince1970)
                    let endCollectTime = Int(newData.endDate.timeIntervalSince1970)
                    let collectDevice = newData.device?.model
                    let printResultToQuantity: HKQuantitySample = newData as! HKQuantitySample
                    let collectedEnergyData = Int(printResultToQuantity.quantity.doubleValue(for: .smallCalorie()))
                    if collectDevice == "iPhone" {
                        let newEnergyData = "\(startCollectTime),\(endCollectTime),\(collectDevice ?? "Error"),\(collectedEnergyData)"
                        self.iPhoneEnergyStringDataArray.append(newEnergyData)
                    } else if collectDevice == "Watch" {
                        let newEnergyData = "\(startCollectTime),\(endCollectTime),\(collectDevice ?? "Error"),\(collectedEnergyData)"
                        self.AWatchEnergyStringDataArray.append(newEnergyData)
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // 걷고 뛴 거리(meter)를 얻는 메소드
    func getDistanceWalkAndRunPerDay(startDate: Date, endDate: Date) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        let startDate = Calendar.current.startOfDay(for: startDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: distanceType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (_, result, error) in
            if let error = error {
                print("Distance Query Error, Set Error String : \(error.localizedDescription)")
                let errorDistanceString = "\(Int(startDate.timeIntervalSince1970)),\(Int(endDate.timeIntervalSince1970)),iPhone,-1"
                self.iPhoneDistanceStringDataArray.append(errorDistanceString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                if result?.count == 0 {
                    print("Distance Query Count(No Data) Error, Set Error String")
                    let errorDistanceString = "\(Int(startDate.timeIntervalSince1970)),\(Int(endDate.timeIntervalSince1970)),iPhone,0"
                    self.iPhoneDistanceStringDataArray.append(errorDistanceString)
                    return
                } else if let results = result {
                    print("Distance Query No Error, Start Appending Results In Array")
                    for newResult in results {
                        self.distanceDataArray.append(newResult)
                    }
                }
                
                print("No Error, Start Convert Distance Data To String")
                for newData in self.distanceDataArray {
                    let startCollectTime = Int(newData.startDate.timeIntervalSince1970)
                    let endCollectTime = Int(newData.endDate.timeIntervalSince1970)
                    let collectDevice = newData.device?.model
                    let printResultToQuantity: HKQuantitySample = newData as! HKQuantitySample
                    let collectedDistanceData = Int(printResultToQuantity.quantity.doubleValue(for: .meter()) * 1000)
                    if collectDevice == "iPhone" {
                        let newDistanceData = "\(startCollectTime),\(endCollectTime),\(collectDevice ?? "Error"),\(collectedDistanceData)"
                        self.iPhoneDistanceStringDataArray.append(newDistanceData)
                    } else if collectDevice == "Watch" {
                        let newDistanceData = "\(startCollectTime),\(endCollectTime),\(collectDevice ?? "Error"),\(collectedDistanceData)"
                        self.AWatchDistanceStringDataArray.append(newDistanceData)
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // 작일 10:00:00 ~ 금일 09:59:59까지 24시간의 수면 데이터를 얻는 메소드
    func getSleepPerDay(start: Date, endDate: Date) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { [weak self] (_, result, error) -> Void in
            if let error = error {
                print("Sleep Query Error, Set Error String : \(error.localizedDescription)")
                let errorSleepString = "\(Int(start.timeIntervalSince1970)),\(Int(endDate.timeIntervalSince1970)),iPhone,-1"
                self?.iPhoneSleepStringDataArray.append(errorSleepString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                if result?.count == 0 {
                    print("Sleep Query Count(No Data) Error, Set Error String")
                    let errorSleepString = "\(Int(start.timeIntervalSince1970)),\(Int(endDate.timeIntervalSince1970)),iPhone,0"
                    self?.iPhoneSleepStringDataArray.append(errorSleepString)
                    return
                } else if let results = result {
                    print("Sleep Query No Error, Start Appending Results In Array")
                    for newResult in results {
                        self?.sleepDataArray.append(newResult as! HKCategorySample)
                    }
                }
                
                print("No Error, Start Convert Sleep Data To String")
                for newData in self!.sleepDataArray {
                    let startCollectTime = Int(newData.startDate.timeIntervalSince1970)
                    let endCollectTime = Int(newData.endDate.timeIntervalSince1970)
                    let collectDeviceNumber = newData.value
                    var collectDevice = ""
                    if collectDeviceNumber == 0 {
                        collectDevice = "iPhone"
                        let collectedSleepTimeData =  Int(newData.endDate.timeIntervalSince(newData.startDate))
                        let newSleepData = "\(startCollectTime),\(endCollectTime),\(collectDevice),\(collectedSleepTimeData)"
                        self?.iPhoneSleepStringDataArray.append(newSleepData)
                    } else if collectDeviceNumber == 1 {
                        collectDevice = "Watch"
                        let collectedSleepTimeData =  Int(newData.endDate.timeIntervalSince(newData.startDate))
                        let newSleepData = "\(startCollectTime),\(endCollectTime),\(collectDevice),\(collectedSleepTimeData)"
                        self?.AWatchSleepStringDataArray.append(newSleepData)
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // 어제 하루의 심박 수를 가져오는 메소드
    func getHeartRatePerDay(startDate: Date, endDate: Date) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let startDate = Calendar.current.startOfDay(for: startDate)
        print(startDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (_, result, error) in
            if let error = error {
                print("HeartRate Query Error, Set Error String : \(error.localizedDescription)")
                let errorHeartRateString = "\(Int(startDate.timeIntervalSince1970)),\(Int(endDate.timeIntervalSince1970)),iPhone,-1"
                self.iPhoneHeartRateStringDataArray.append(errorHeartRateString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                if result?.count == 0 {
                    print("HeartRate Query Count(No Data) Error, Set Error String")
                    let errorHeartRateString = "\(startDate.timeIntervalSince1970),\(endDate.timeIntervalSince1970),iPhone,0"
                    self.iPhoneHeartRateStringDataArray.append(errorHeartRateString)
                    return
                } else if let results = result {
                    print("HeartRate Query No Error, Start Appending Results In Array")
                    for newResult in results {
                        self.heartRateDataArray.append(newResult)
                    }
                }
                
                print("No Error, Start Convert HeartRate Data To String")
                for newData in self.heartRateDataArray {
                    let startCollectTime = Int(newData.startDate.timeIntervalSince1970)
                    let endCollectTime = Int(newData.endDate.timeIntervalSince1970)
                    let collectDevice = newData.device?.model
                    let printResultToQuantity: HKQuantitySample = newData as! HKQuantitySample
                    let collectedHeartRateData = Int(printResultToQuantity.quantity.doubleValue(for: .count().unitDivided(by: .minute())))
                    if collectDevice == "iPhone" {
                        let newHeartRateData = "\(startCollectTime),\(endCollectTime),\(collectDevice ?? "Error"),\(collectedHeartRateData)"
                        self.iPhoneHeartRateStringDataArray.append(newHeartRateData)
                    } else if collectDevice == "Watch" {
                        let newHeartRateData = "\(startCollectTime),\(endCollectTime),\(collectDevice ?? "Error"),\(collectedHeartRateData)"
                        self.AWatchHeartRateStringDataArray.append(newHeartRateData)
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func queryingStepCount(startDate: Date, endDate: Date) {
        print("Get stepCount data with health query")
        print("Test start date = \(startDate) | Test end date = \(endDate)")
        self.getStepCountPerDay(startDate: startDate, endDate: endDate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
            self.makeHealthDataCSV(dataType: "steps")
        }
    }
    
    func queryingEnergyCount(startDate: Date, endDate: Date) {
        print("Get activeEnergyBurned data with health query")
        print("Test start date = \(startDate) | Test end date = \(endDate)")
        self.getActiveEnergyPerDay(startDate: startDate, endDate: endDate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
            self.makeHealthDataCSV(dataType: "calories")
        }
    }
    
    func queryingDistanceCount(startDate: Date, endDate: Date) {
        print("Get distanceWalkingRunning data with health query")
        print("Test start date = \(startDate) | Test end date = \(endDate)")
        self.getDistanceWalkAndRunPerDay(startDate: startDate, endDate: endDate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
            self.makeHealthDataCSV(dataType: "distance")
        }
    }
    
    func queryingSleepCount(startDate: Date, endDate: Date) {
        print("Get sleepAnalysis data with health query")
        print("Test start date = \(startDate) | Test end date = \(endDate)")
        self.getSleepPerDay(start: startDate, endDate: endDate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
            self.makeHealthDataCSV(dataType: "sleep")
        }
    }
    
    func queryingHRCount(startDate: Date, endDate: Date) {
        print("Get heartRate data with health query")
        print("Test start date = \(startDate) | Test end date = \(endDate)")
        self.getHeartRatePerDay(startDate: startDate, endDate: endDate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
            self.makeHealthDataCSV(dataType: "HR")
        }
    }
    
    // 받아온 건강 정보들을 CSV 파일(문자열)로 만드는 메소드
    func makeHealthDataCSV(dataType: String) {
        if dataType == "steps" {
            print("iPhoneStepStringDataArray = \(iPhoneStepStringDataArray.count)")
            print("AWatchStepStringDataArray = \(AWatchStepStringDataArray.count)")
            
            if iPhoneStepStringDataArray.count > 0 {
                for dataIndex in 0..<self.iPhoneStepStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        if dataIndex==0 {
                            self.iPhoneStepStringToUpload += self.iPhoneStepStringDataArray[dataIndex] + ","
                            continue
                        }
                        self.iPhoneStepStringArray.append(iPhoneStepStringToUpload)
                        iPhoneStepStringToUpload = ""
                    }
                    
                    if dataIndex == self.iPhoneStepStringDataArray.count-1 {
                        self.iPhoneStepStringToUpload += self.iPhoneStepStringDataArray[dataIndex]
                        self.iPhoneStepStringArray.append(iPhoneStepStringToUpload)
                        iPhoneStepStringToUpload = ""
                        break
                    }
                    
                    self.iPhoneStepStringToUpload += self.iPhoneStepStringDataArray[dataIndex] + ","
                }
            }
            
            if AWatchStepStringDataArray.count > 0 {
                for dataIndex in 0..<self.AWatchStepStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        if dataIndex==0 {
                            self.AWatchStepStringToUpload += self.AWatchStepStringDataArray[dataIndex] + ","
                            continue
                        }
                        self.AWatchStepStringArray.append(AWatchStepStringToUpload)
                        AWatchStepStringToUpload = ""
                    }
                    
                    if dataIndex == self.AWatchStepStringDataArray.count-1 {
                        self.AWatchStepStringToUpload += self.AWatchStepStringDataArray[dataIndex]
                        self.AWatchStepStringArray.append(AWatchStepStringToUpload)
                        AWatchStepStringToUpload = ""
                        break
                    }
                    
                    self.AWatchStepStringToUpload += self.AWatchStepStringDataArray[dataIndex] + ","
                }
            }
            
            if iPhoneStepStringArray.count > 0 {
                for i in 0..<self.iPhoneStepStringArray.count {
                    self.writeHealthCSV(healthData: self.iPhoneStepStringArray[i], deviceType: "iphone", dataType: "steps", index: i)
                    uploadCSVDataToMobius(csvData: iPhoneStepStringArray[i], deviceType: "iphone", containerName: "steps", fileNumber: i)
                }
            }
            
            if AWatchStepStringArray.count > 0 {
                for i in 0..<self.AWatchStepStringArray.count {
                    self.writeHealthCSV(healthData: self.AWatchStepStringArray[i], deviceType: "watch", dataType: "steps", index: i)
                    uploadCSVDataToMobius(csvData: AWatchStepStringArray[i], deviceType: "watch", containerName: "steps", fileNumber: i)
                }
            }
            
            stepDataArray.removeAll()
            iPhoneStepStringDataArray.removeAll()
            AWatchStepStringDataArray.removeAll()
            iPhoneStepStringArray.removeAll()
            AWatchStepStringArray.removeAll()
            iPhoneStepStringToUpload = ""
            AWatchStepStringToUpload = ""
        } else if dataType == "calories" {
            print("iPhoneEnergyStringDataArray = \(iPhoneEnergyStringDataArray.count)")
            print("AWatchEnergyStringDataArray = \(AWatchEnergyStringDataArray.count)")
            
            if iPhoneEnergyStringDataArray.count > 0 {
                for dataIndex in 0..<self.iPhoneEnergyStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        if dataIndex==0 {
                            self.iPhoneEnergyStringToUpload += self.iPhoneEnergyStringDataArray[dataIndex] + ","
                            continue
                        }
                        self.iPhoneEnergyStringArray.append(iPhoneEnergyStringToUpload)
                        iPhoneEnergyStringToUpload = ""
                    }
                    
                    if dataIndex == self.iPhoneEnergyStringDataArray.count-1 {
                        self.iPhoneEnergyStringToUpload += self.iPhoneEnergyStringDataArray[dataIndex]
                        self.iPhoneEnergyStringArray.append(iPhoneEnergyStringToUpload)
                        iPhoneEnergyStringToUpload = ""
                        break
                    }
                    
                    self.iPhoneEnergyStringToUpload += self.iPhoneEnergyStringDataArray[dataIndex] + ","
                }
            }
            
            if AWatchEnergyStringDataArray.count > 0 {
                for dataIndex in 0..<self.AWatchEnergyStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        if dataIndex==0 {
                            self.AWatchEnergyStringToUpload += self.AWatchEnergyStringDataArray[dataIndex] + ","
                            continue
                        }
                        self.AWatchEnergyStringArray.append(AWatchEnergyStringToUpload)
                        AWatchEnergyStringToUpload = ""
                    }
                    
                    if dataIndex == self.AWatchEnergyStringDataArray.count-1 {
                        self.AWatchEnergyStringToUpload += self.AWatchEnergyStringDataArray[dataIndex]
                        self.AWatchEnergyStringArray.append(AWatchEnergyStringToUpload)
                        AWatchEnergyStringToUpload = ""
                        break
                    }
                    
                    self.AWatchEnergyStringToUpload += self.AWatchEnergyStringDataArray[dataIndex] + ","
                }
            }
            
            if iPhoneEnergyStringArray.count > 0 {
                for i in 0..<iPhoneEnergyStringArray.count {
                    self.writeHealthCSV(healthData: self.iPhoneEnergyStringArray[i], deviceType: "iphone", dataType: "calories", index: i)
                    uploadCSVDataToMobius(csvData: iPhoneEnergyStringArray[i], deviceType: "iphone", containerName: "calories", fileNumber: i)
                }
            }
            
            if AWatchEnergyStringArray.count > 0 {
                for i in 0..<self.AWatchEnergyStringArray.count {
                    self.writeHealthCSV(healthData: self.AWatchEnergyStringArray[i], deviceType: "watch", dataType: "calories", index: i)
                    uploadCSVDataToMobius(csvData: AWatchEnergyStringArray[i], deviceType: "watch", containerName: "calories", fileNumber: i)
                }
            }
            
            energyDataArray.removeAll()
            iPhoneEnergyStringDataArray.removeAll()
            AWatchEnergyStringDataArray.removeAll()
            iPhoneEnergyStringArray.removeAll()
            AWatchEnergyStringArray.removeAll()
            iPhoneEnergyStringToUpload = ""
            AWatchEnergyStringToUpload = ""
        } else if dataType == "distance" {
            print("iPhoneDistanceStringDataArray = \(iPhoneDistanceStringDataArray.count)")
            print("AWatchDistanceStringDataArray = \(AWatchDistanceStringDataArray.count)")
            
            if iPhoneDistanceStringDataArray.count > 0 {
                for dataIndex in 0..<self.iPhoneDistanceStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        if dataIndex==0 {
                            self.iPhoneDistanceStringToUpload += self.iPhoneDistanceStringDataArray[dataIndex] + ","
                            continue
                        }
                        self.iPhoneDistanceStringArray.append(iPhoneDistanceStringToUpload)
                        iPhoneDistanceStringToUpload = ""
                    }
                    
                    if dataIndex == self.iPhoneDistanceStringDataArray.count-1 {
                        self.iPhoneDistanceStringToUpload += self.iPhoneDistanceStringDataArray[dataIndex]
                        self.iPhoneDistanceStringArray.append(iPhoneDistanceStringToUpload)
                        iPhoneDistanceStringToUpload = ""
                        break
                    }
                    
                    self.iPhoneDistanceStringToUpload += self.iPhoneDistanceStringDataArray[dataIndex] + ","
                }
            }
            
            if AWatchDistanceStringDataArray.count > 0 {
                for dataIndex in 0..<self.AWatchDistanceStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        if dataIndex==0 {
                            self.AWatchDistanceStringToUpload += self.AWatchDistanceStringDataArray[dataIndex] + ","
                            continue
                        }
                        self.AWatchDistanceStringArray.append(AWatchDistanceStringToUpload)
                        AWatchDistanceStringToUpload = ""
                    }
                    
                    if dataIndex == self.AWatchDistanceStringDataArray.count-1 {
                        self.AWatchDistanceStringToUpload += self.AWatchDistanceStringDataArray[dataIndex]
                        self.AWatchDistanceStringArray.append(AWatchDistanceStringToUpload)
                        AWatchDistanceStringToUpload = ""
                        break
                    }
                    
                    self.AWatchDistanceStringToUpload += self.AWatchDistanceStringDataArray[dataIndex] + ","
                }
            }
            
            if iPhoneDistanceStringArray.count > 0 {
                for i in 0..<iPhoneDistanceStringArray.count {
                    self.writeHealthCSV(healthData: self.iPhoneDistanceStringArray[i], deviceType: "iphone", dataType: "distance", index: i)
                    uploadCSVDataToMobius(csvData: iPhoneDistanceStringArray[i], deviceType: "iphone", containerName: "distance", fileNumber: i)
                }
            }
            
            if AWatchDistanceStringArray.count > 0 {
                for i in 0..<AWatchDistanceStringArray.count {
                    self.writeHealthCSV(healthData: self.AWatchDistanceStringArray[i], deviceType: "watch", dataType: "distance", index: i)
                    uploadCSVDataToMobius(csvData: AWatchDistanceStringArray[i], deviceType: "watch", containerName: "distance", fileNumber: i)
                }
            }
            
            distanceDataArray.removeAll()
            iPhoneDistanceStringDataArray.removeAll()
            AWatchDistanceStringDataArray.removeAll()
            iPhoneDistanceStringArray.removeAll()
            AWatchDistanceStringArray.removeAll()
            iPhoneDistanceStringToUpload = ""
            AWatchDistanceStringToUpload = ""
        } else if dataType == "sleep" {
            print("iPhoneSleepStringDataArray = \(iPhoneSleepStringDataArray.count)")
            print("AWatchSleepStringDataArray = \(AWatchSleepStringDataArray.count)")
            
            
            if iPhoneSleepStringDataArray.count > 0 {
                for dataIndex in 0..<self.iPhoneSleepStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        if dataIndex==0 {
                            self.iPhoneSleepStringToUpload += self.iPhoneSleepStringDataArray[dataIndex] + ","
                            continue
                        }
                        self.iPhoneSleepStringArray.append(iPhoneSleepStringToUpload)
                        iPhoneSleepStringToUpload = ""
                    }
                    
                    if dataIndex == self.iPhoneSleepStringDataArray.count-1 {
                        self.iPhoneSleepStringToUpload += self.iPhoneSleepStringDataArray[dataIndex]
                        self.iPhoneSleepStringArray.append(iPhoneSleepStringToUpload)
                        iPhoneSleepStringToUpload = ""
                        break
                    }
                    
                    self.iPhoneSleepStringToUpload += self.iPhoneSleepStringDataArray[dataIndex] + ","
                }
            }
            
            if AWatchSleepStringDataArray.count > 0 {
                for dataIndex in 0..<self.AWatchSleepStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        if dataIndex==0 {
                            self.AWatchSleepStringToUpload += self.AWatchSleepStringDataArray[dataIndex] + ","
                            continue
                        }
                        self.AWatchSleepStringArray.append(AWatchSleepStringToUpload)
                        AWatchSleepStringToUpload = ""
                    }
                    
                    if dataIndex == self.AWatchSleepStringDataArray.count-1 {
                        self.AWatchSleepStringToUpload += self.AWatchSleepStringDataArray[dataIndex]
                        self.AWatchSleepStringArray.append(AWatchSleepStringToUpload)
                        AWatchSleepStringToUpload = ""
                        break
                    }
                    
                    self.AWatchSleepStringToUpload += self.AWatchSleepStringDataArray[dataIndex] + ","
                }
            }
            
            if iPhoneSleepStringArray.count > 0 {
                for i in 0..<iPhoneSleepStringArray.count {
                    self.writeHealthCSV(healthData: iPhoneSleepStringArray[i], deviceType: "iphone", dataType: "sleep", index: i)
                    uploadCSVDataToMobius(csvData: iPhoneSleepStringArray[i], deviceType: "iphone", containerName: "sleep", fileNumber: i)
                }
            }
            
            if AWatchSleepStringArray.count > 0 {
                for i in 0..<AWatchSleepStringArray.count {
                    self.writeHealthCSV(healthData: AWatchSleepStringArray[i], deviceType: "watch", dataType: "sleep", index: i)
                    uploadCSVDataToMobius(csvData: AWatchSleepStringArray[i], deviceType: "watch", containerName: "sleep", fileNumber: i)
                }
            }
            
            sleepDataArray.removeAll()
            iPhoneSleepStringDataArray.removeAll()
            AWatchSleepStringDataArray.removeAll()
            iPhoneSleepStringArray.removeAll()
            AWatchSleepStringArray.removeAll()
            iPhoneSleepStringToUpload = ""
            AWatchSleepStringToUpload = ""
        } else if dataType == "HR" {
            print("iPhoneHeartRateStringDataArray = \(iPhoneHeartRateStringDataArray.count)")
            print("AWatchHeartRateStringDataArray = \(AWatchHeartRateStringDataArray.count)")
            
            if iPhoneHeartRateStringDataArray.count > 0 {
                for dataIndex in 0..<self.iPhoneHeartRateStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        if dataIndex==0 {
                            self.iPhoneHeartRateStringToUpload += self.iPhoneHeartRateStringDataArray[dataIndex] + ","
                            continue
                        }
                        self.iPhoneHeartRateStringArray.append(iPhoneHeartRateStringToUpload)
                        iPhoneHeartRateStringToUpload = ""
                    }
                    
                    if dataIndex == self.iPhoneHeartRateStringDataArray.count-1 {
                        self.iPhoneHeartRateStringToUpload += self.iPhoneHeartRateStringDataArray[dataIndex]
                        self.iPhoneHeartRateStringArray.append(iPhoneHeartRateStringToUpload)
                        iPhoneHeartRateStringToUpload = ""
                        break
                    }
                    
                    self.iPhoneHeartRateStringToUpload += self.iPhoneHeartRateStringDataArray[dataIndex] + ","
                }
            }
            
            if AWatchHeartRateStringDataArray.count > 0 {
                for dataIndex in 0..<self.AWatchHeartRateStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        if dataIndex==0 {
                            self.AWatchHeartRateStringToUpload += self.AWatchHeartRateStringDataArray[dataIndex] + ","
                            continue
                        }
                        self.AWatchHeartRateStringArray.append(AWatchHeartRateStringToUpload)
                        AWatchHeartRateStringToUpload = ""
                    }
                    
                    if dataIndex == self.AWatchHeartRateStringDataArray.count-1 {
                        self.AWatchHeartRateStringToUpload += self.AWatchHeartRateStringDataArray[dataIndex]
                        self.AWatchHeartRateStringArray.append(AWatchHeartRateStringToUpload)
                        AWatchHeartRateStringToUpload = ""
                        break
                    }
                    
                    self.AWatchHeartRateStringToUpload += self.AWatchHeartRateStringDataArray[dataIndex] + ","
                }
            }
            
            if iPhoneHeartRateStringArray.count > 0 {
                for i in 0..<iPhoneHeartRateStringArray.count {
                    self.writeHealthCSV(healthData: iPhoneHeartRateStringArray[i], deviceType: "iphone", dataType: "HR", index: i)
                    uploadCSVDataToMobius(csvData: iPhoneHeartRateStringArray[i], deviceType: "iphone", containerName: "HR", fileNumber: i)
                }
            }
            
            if AWatchHeartRateStringArray.count > 0 {
                for i in 0..<AWatchHeartRateStringArray.count {
                    self.writeHealthCSV(healthData: AWatchHeartRateStringArray[i], deviceType: "watch", dataType: "HR", index: i)
                    uploadCSVDataToMobius(csvData: AWatchHeartRateStringArray[i], deviceType: "watch", containerName: "HR", fileNumber: i)
                }
            }
            
            heartRateDataArray.removeAll()
            iPhoneHeartRateStringDataArray.removeAll()
            AWatchHeartRateStringDataArray.removeAll()
            iPhoneHeartRateStringArray.removeAll()
            AWatchHeartRateStringArray.removeAll()
            iPhoneHeartRateStringToUpload = ""
            AWatchHeartRateStringToUpload = ""
        }
    }
    
    // Mobius 서버에 CSV 파일을 업로드하는 메소드
    private func uploadCSVDataToMobius(csvData: String, deviceType: String, containerName: String, fileNumber: Int) {
        let semaphore = DispatchSemaphore (value: 0)
        
        let parameters = "{\n    \"m2m:cin\": {\n        \"con\": \"\(csvData)\"\n    }\n}"
        let postData = parameters.data(using: .utf8)
        
        let userID = UserDefaults.standard.string(forKey: "UserID")!
        
        let urlString = "http://114.71.220.59:7579/Mobius/\(userID)/health/\(deviceType)/\(containerName)"
        // 마지막 컨테이너 이름에 슬래시(/)를 추가하면 하위 디렉터리를 또 찾게 됨
        print(urlString)
        
        var request = URLRequest(url: URL(string: urlString)!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("12345", forHTTPHeaderField: "X-M2M-RI")
        request.addValue("SIWLTfduOpL", forHTTPHeaderField: "X-M2M-Origin")
        request.addValue("application/vnd.onem2m-res+json; ty=4", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard data != nil else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            
            // POST 성공 여부 체크, POST 실패 시 return
            let successsRange = 200..<300
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, successsRange.contains(statusCode)
            else {
                print("")
                print("====================================")
                print("[requestPOST : http post 요청 에러]")
                print("error : ", (response as? HTTPURLResponse)?.statusCode ?? 0)
                print("msg : ", (response as? HTTPURLResponse)?.description ?? "")
                print("====================================")
                print("")
                return
            }
            
            self.removeCSV(deviceType: deviceType, containerName: containerName, index: fileNumber)
            
            print("\(containerName) Data is served.")
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
    private func removeCSV(deviceType: String, containerName: String, index: Int) {
        let fileManager: FileManager = FileManager.default
        
        let folderName = "healthCSVFolder"
        
        let csvFileName = "\(deviceType)_\(containerName)_\(index).csv"
        
        let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let diretoryUrl = documentUrl.appendingPathComponent(folderName)
        let fileUrl = diretoryUrl.appendingPathComponent(csvFileName)
        
        do {
            try fileManager.removeItem(at: fileUrl)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
