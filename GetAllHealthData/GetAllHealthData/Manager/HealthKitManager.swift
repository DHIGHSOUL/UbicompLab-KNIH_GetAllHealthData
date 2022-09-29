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
    var stepStringDataArray: [String] = []
    var stepStringToUpload = ""
    var stepStringArray: [String] = []
    var stepCSVIndex: Int = 0
    
    // 활성 에너지 수 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startDate, endTime, data) 배열, 업로드를 위한 문자열
    var energyDataArray: [HKSample] = []
    var energyStringDataArray: [String] = []
    var energyStringToUpload = ""
    var energyStringArray: [String] = []
    var energyCSVIndex: Int = 0
    
    // 걷고 뛴 거리 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startDate, endTime, data) 배열, 업로드를 위한 문자열
    var distanceDataArray: [HKSample] = []
    var distanceStringDataArray: [String] = []
    var distanceStringToUpload = ""
    var distanceStringArray: [String] = []
    var distanceCSVIndex: Int = 0
    
    // 수면 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startDate, endTime, data) 배열, 업로드를 위한 문자열
    var sleepDataArray: [HKCategorySample] = []
    var sleepStringDataArray: [String] = []
    var sleepStringToUpload = ""
    var sleepStringArray: [String] = []
    var sleepCSVIndex: Int = 0
    
    // 심박수 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startDate, endTime, data) 배열, 업로드를 위한 문자열
    var heartRateDataArray: [HKSample] = []
    var heartRateStringDataArray: [String] = []
    var heartRateStringToUpload = ""
    var heartRateStringArray: [String] = []
    var heartRateCSVIndex: Int = 0
    
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
    func writeHealthCSV(healthData: String, dataType: String, index: Int) {
        let fileManager = FileManager.default
        
        print("\(dataType)_\(index).csv 파일 생성됨")
        let folderName = "healthCSVFolder"
        let csvFileName = "\(dataType)_\(index).csv"
        
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
                self.stepStringDataArray.append(errorStepString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if result?.count == 0 {
                    print("Step Query Count(No Data) Error, Set Error String")
                    let errorStepString = "\(Int(startTime.timeIntervalSince1970)),\(Int(endTime.timeIntervalSince1970)),iPhone,0"
                    self.stepStringDataArray.append(errorStepString)
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
                    
                    let newStepData = "\(startCollectTime),\(endCollectTime),\(collectDevice!),\(collectedStepData)"
                    
                    self.stepStringDataArray.append(newStepData)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // 사용한 활성에너지(cal)를 얻는 메소드
    func getActiveEnergyPerDay(startDate: Date, endDate: Date) {
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let startDate = Calendar.current.startOfDay(for: endDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: activeEnergyType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (_, result, error) in
            if let error = error {
                print("Energy Query Error, Set Error String : \(error.localizedDescription)")
                let errorEnergyString = "\(Int(startDate.timeIntervalSince1970)),\(Int(endDate.timeIntervalSince1970)),iPhone,-1"
                self.energyStringDataArray.append(errorEnergyString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if result?.count == 0 {
                    print("Energy Query Count(No Data) Error, Set Error String")
                    let errorEnergyString = "\(Int(startDate.timeIntervalSince1970)),\(Int(endDate.timeIntervalSince1970)),iPhone,0"
                    self.energyStringDataArray.append(errorEnergyString)
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
                    
                    let newEnergyData = "\(startCollectTime),\(endCollectTime),\(collectDevice!),\(collectedEnergyData)"
                    
                    self.energyStringDataArray.append(newEnergyData)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // 걷고 뛴 거리(meter)를 얻는 메소드
    func getDistanceWalkAndRunPerDay(startDate: Date, endDate: Date) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        let startDate = Calendar.current.startOfDay(for: endDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: distanceType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (_, result, error) in
            if let error = error {
                print("Distance Query Error, Set Error String : \(error.localizedDescription)")
                let errorDistanceString = "\(Int(startDate.timeIntervalSince1970)),\(Int(endDate.timeIntervalSince1970)),iPhone,-1"
                self.distanceStringDataArray.append(errorDistanceString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if result?.count == 0 {
                    print("Distance Query Count(No Data) Error, Set Error String")
                    let errorDistanceString = "\(Int(startDate.timeIntervalSince1970)),\(Int(endDate.timeIntervalSince1970)),iPhone,0"
                    self.distanceStringDataArray.append(errorDistanceString)
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
                    
                    let newDistanceData = "\(startCollectTime),\(endCollectTime),\(collectDevice!),\(collectedDistanceData)"
                    
                    self.distanceStringDataArray.append(newDistanceData)
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
                self?.sleepStringDataArray.append(errorSleepString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if result?.count == 0 {
                    print("Sleep Query Count(No Data) Error, Set Error String")
                    let errorSleepString = "\(Int(start.timeIntervalSince1970)),\(Int(endDate.timeIntervalSince1970)),iPhone,0"
                    self?.sleepStringDataArray.append(errorSleepString)
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
                    } else if collectDeviceNumber == 1 {
                        collectDevice = "Watch"
                    }
                    let collectedSleepTimeData =  Int(newData.endDate.timeIntervalSince(newData.startDate))
                    let newSleepData = "\(startCollectTime),\(endCollectTime),\(collectDevice),\(collectedSleepTimeData)"
                    
                    self?.sleepStringDataArray.append(newSleepData)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // 어제 하루의 심박 수를 가져오는 메소드
    func getHeartRatePerDay(startDate: Date, endDate: Date) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let startDate = Calendar.current.startOfDay(for: endDate)
        print(startDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (_, result, error) in
            if let error = error {
                print("HeartRate Query Error, Set Error String : \(error.localizedDescription)")
                let errorHeartRateString = "\(Int(startDate.timeIntervalSince1970)),\(Int(endDate.timeIntervalSince1970)),iPhone,-1"
                self.heartRateStringDataArray.append(errorHeartRateString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if result?.count == 0 {
                    print("HeartRate Query Count(No Data) Error, Set Error String")
                    let errorHeartRateString = "\(startDate.timeIntervalSince1970),\(endDate.timeIntervalSince1970),iPhone,0"
                    self.heartRateStringDataArray.append(errorHeartRateString)
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
                    
                    let newHeartRateData = "\(startCollectTime),\(endCollectTime),\(collectDevice!),\(collectedHeartRateData)"
                    
                    self.heartRateStringDataArray.append(newHeartRateData)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // Health CSV 파일을 만들고 업로드하는 메소드
    func makeHealthCSVFileAndUpload(startDate: Date, endDate: Date) {
        print("Start save and upload health data")
        print("Test start date = \(startDate) | Test end date = \(endDate)")
        
//        self.getStepCountPerDay(startDate: startDate, endDate: endDate)
//        self.getActiveEnergyPerDay(startDate: startDate, endDate: endDate)
//        self.getDistanceWalkAndRunPerDay(startDate: startDate, endDate: endDate)
        self.getHeartRatePerDay(startDate: startDate, endDate: endDate)
//        self.getSleepPerDay(start: startDate, endDate: endDate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            for array in self.healthContainerNameArray {
//                self.makeHealthDataCSV(dataType: array)
//            }
            self.makeHealthDataCSV(dataType: "HR")
            
//            self.stepStringToUpload = ""
//            self.energyStringToUpload = ""
//            self.distanceStringToUpload = ""
            self.heartRateStringToUpload = ""
//            self.sleepStringToUpload = ""
        }
    }
    
    // 받아온 건강 정보들을 CSV 파일(문자열)로 만드는 메소드
    func makeHealthDataCSV(dataType: String) {
        if dataType == "steps" {
            print("StepStringArray = \(stepStringDataArray.count)")
            
            if stepStringDataArray.count > 0 {
                for dataIndex in 0..<self.stepStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        self.stepStringArray.append(stepStringToUpload)
                        stepStringToUpload = ""
                    }
                    
                    if dataIndex == self.stepStringDataArray.count-1 {
                        self.stepStringToUpload += self.stepStringDataArray[dataIndex]
                        break
                    }
                    
                    self.stepStringToUpload += self.stepStringDataArray[dataIndex] + ","
                }
            }
            
            if stepStringArray.count > 0 {
                for i in 0..<self.stepStringArray.count {
                    self.writeHealthCSV(healthData: self.stepStringArray[i], dataType: "steps", index: i)
                }
            }
            
            stepDataArray.removeAll()
            stepStringDataArray.removeAll()
            stepStringArray.removeAll()
        } else if dataType == "calories" {
            print("EnergyStringArray = \(energyStringDataArray.count)")
            
            if energyStringDataArray.count > 0 {
                for dataIndex in 0..<self.energyStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        self.energyStringArray.append(energyStringToUpload)
                        energyStringToUpload = ""
                    }
                    
                    if dataIndex == self.energyStringDataArray.count-1 {
                        self.energyStringToUpload += self.energyStringDataArray[dataIndex]
                        break
                    }
                    
                    self.energyStringToUpload += self.energyStringDataArray[dataIndex] + ","
                }
            }
            
            if energyStringArray.count > 0 {
                for i in 0..<energyStringArray.count {
                    self.writeHealthCSV(healthData: self.energyStringArray[i], dataType: "calories", index: i)
                }
            }
            
            energyDataArray.removeAll()
            energyStringDataArray.removeAll()
            energyStringArray.removeAll()
        } else if dataType == "distance" {
            print("DistanceStringArray = \(distanceStringDataArray.count)")
            
            if distanceStringDataArray.count > 0 {
                for dataIndex in 0..<self.distanceStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        self.distanceStringArray.append(distanceStringToUpload)
                        distanceStringToUpload = ""
                    }
                    
                    if dataIndex == self.distanceStringDataArray.count-1 {
                        self.energyStringToUpload += self.distanceStringDataArray[dataIndex]
                        break
                    }
                    
                    self.distanceStringToUpload += self.distanceStringDataArray[dataIndex] + ","
                }
            }
            
            if distanceStringArray.count > 0 {
                for i in 0..<distanceStringArray.count {
                    self.writeHealthCSV(healthData: self.distanceStringArray[i], dataType: "distance", index: i)
                }
            }
            
            distanceDataArray.removeAll()
            distanceStringDataArray.removeAll()
            distanceStringArray.removeAll()
        } else if dataType == "sleep" {
            print("SleepStringArray = \(sleepStringDataArray.count)")
            
            if sleepStringDataArray.count > 0 {
                for dataIndex in 0..<self.sleepStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        self.sleepStringArray.append(sleepStringToUpload)
                        sleepStringToUpload = ""
                    }
                    
                    if dataIndex == self.sleepStringDataArray.count-1 {
                        self.sleepStringToUpload += self.sleepStringDataArray[dataIndex]
                        break
                    }
                    
                    self.sleepStringToUpload += self.sleepStringDataArray[dataIndex] + ","
                }
            }
            
            if sleepStringArray.count > 0 {
                for i in 0..<sleepStringArray.count {
                    self.writeHealthCSV(healthData: sleepStringArray[i], dataType: "sleep", index: i)
                }
            }
            
            sleepDataArray.removeAll()
            sleepStringDataArray.removeAll()
            sleepStringArray.removeAll()
        } else if dataType == "HR" {
            print("HeartRateStringArray = \(heartRateStringDataArray.count)")
            
            if heartRateStringDataArray.count > 0 {
                for dataIndex in 0..<self.heartRateStringDataArray.count {
                    if dataIndex % 4000 == 0 {
                        self.heartRateStringArray.append(heartRateStringToUpload)
                        heartRateStringToUpload = ""
                    }
                    
                    if dataIndex == self.heartRateStringDataArray.count-1 {
                        self.heartRateStringToUpload += self.heartRateStringDataArray[dataIndex]
                        break
                    }
                    
                    self.heartRateStringToUpload += self.heartRateStringDataArray[dataIndex] + ","
                }
            }
            
            if heartRateStringArray.count > 0 {
                for i in 0..<heartRateStringArray.count {
                    self.writeHealthCSV(healthData: heartRateStringArray[i], dataType: "HR", index: i)
                }
            }
            
            heartRateDataArray.removeAll()
            heartRateStringDataArray.removeAll()
            heartRateStringArray.removeAll()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}
