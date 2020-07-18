//
//  ViewModel.swift
//  Zones WatchKit Extension
//
//  Created by Steph Ananth on 7/17/20.
//  Copyright © 2020 Steph K. Ananth. All rights reserved.
//

import Foundation
import HealthKit
import SwiftUI

class ViewModel: ObservableObject {

    private let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())

    @Published var heartRate: Double = 0.0
    @Published var heartRateZoneColor: Color = .gray

    private enum HeartRateZone: Int {
        case resting = 0
        case veryLight = 1
        case light = 2
        case moderate = 3
        case hard = 4
        case veryHard = 5

        func getColor() -> Color {
            print("ViewModel.HeartRateZone.getColor()")
            switch self {
            case .resting: return .gray
            case .veryLight: return .blue
            case .light: return .green
            case .moderate: return .yellow
            case .hard: return .orange
            case .veryHard: return .red
            }
        }
    }

    func authorizeHealthKit() {
        print("ViewModel.authorizeHealthKit()")
        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth) else {
            print("ViewModel.authorizeHealthKit() > could not unwrap date of birth characteristic type")
            return
        }
        guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("ViewModel.authorizeHealthKit() > could not unwrap heart rate quantity type")
            return
        }
        guard let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            print("ViewModel.authorizeHealthKit() > could not unwrap resting heart rate quantity type")
            return
        }
        let healthKitTypes: Set<HKObjectType> = [ dateOfBirth, heartRate, restingHeartRate ]
        HKHealthStore().requestAuthorization(toShare: nil, read: healthKitTypes) { (success, error) in
            if let error = error {
                print("ViewModel.authorizeHealthKit() > error: \(error.localizedDescription)")
                return
            }
            print("ViewModel.authorizeHealthKit() > success: \(success)")
        }
    }

    func refreshView() {
        print("ViewModel.refreshView()")
        fetchHeartRate { (newHeartRate) in
            guard let newHeartRate = newHeartRate else {
                print("ViewModel.refreshView() > could not unwrap heart rate")
                return
            }
            self.fetchHeartRateZone(heartRate: newHeartRate) { (heartRateZone) in
                guard let heartRateZone = heartRateZone else {
                    print("ViewModel.refreshView() > could not unwrap heart rate zone")
                    return
                }
                DispatchQueue.main.async {
                    self.heartRate = newHeartRate
                    self.heartRateZoneColor = heartRateZone.getColor()
                }
                print("ViewModel.refreshView() > heartRate: \(newHeartRate), heartRateZone: \(heartRateZone)")
            }
        }
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
            self.refreshView()
        }
    }

    private func fetchHeartRateZone(heartRate: Double, _ completion: @escaping (HeartRateZone?) -> Void) {
        print("ViewModel.fetchHeartRateZone(heartRate: \(heartRate))")
        fetchRestingHeartRate { (restingHeartRate) in
            guard let dateOfBirth = try? HKHealthStore().dateOfBirthComponents().date else {
                print("ViewModel.fetchHeartRateZone() > could not unwrap date of birth")
                completion(nil)
                return
            }
            let secondsInOneDay: Double = 24 * 60 * 60
            let daysSinceBirth = -dateOfBirth.timeIntervalSinceNow / secondsInOneDay
            let daysInOneYear = 365 + 0.25 - 0.01 + 0.0025 - 0.00025
            let yearsSinceBirth = daysSinceBirth / daysInOneYear

            print("ViewModel.fetchHeartRateZone() > yearsSinceBirth: \(yearsSinceBirth)")

            let maxHeartRate = 208 - 0.7 * yearsSinceBirth

            var fiftyPercent: Double
            var sixtyPercent: Double
            var seventyPercent: Double
            var eightyPercent: Double
            var ninetyPercent: Double

            if let restingHeartRate = restingHeartRate {
                let heartRateReserve = maxHeartRate - restingHeartRate
                fiftyPercent = restingHeartRate + heartRateReserve * 0.5
                sixtyPercent = restingHeartRate + heartRateReserve * 0.6
                seventyPercent = restingHeartRate + heartRateReserve * 0.7
                eightyPercent = restingHeartRate + heartRateReserve * 0.8
                ninetyPercent = restingHeartRate + heartRateReserve * 0.9
            }

            fiftyPercent = maxHeartRate * 0.5
            sixtyPercent = maxHeartRate * 0.6
            seventyPercent = maxHeartRate * 0.7
            eightyPercent = maxHeartRate * 0.8
            ninetyPercent = maxHeartRate * 0.9

            switch heartRate {
            case let restingRate where restingRate < fiftyPercent: completion(.resting)
            case let veryLightRate where veryLightRate < sixtyPercent: completion(.veryLight)
            case let lightRate where lightRate < seventyPercent: completion(.light)
            case let moderateRate where moderateRate < eightyPercent: completion(.moderate)
            case let hardRate where hardRate < ninetyPercent: completion(.hard)
            case let veryHardRate where veryHardRate >= ninetyPercent: completion(.veryHard)
            default: completion(nil)
            }
        }
    }

    private func fetchLatestSample(for typeIdentifier: HKQuantityTypeIdentifier,
                                   _ completion: @escaping (HKQuantitySample?) -> Void) {
        print("ViewModel.fetchLatestSample(for type: \(typeIdentifier))")
        guard let sampleType: HKSampleType = HKObjectType.quantityType(forIdentifier: typeIdentifier) else {
            print("ViewModel.fetchLatestSample() > could not unwrap sample type")
            return
        }
        let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: .distantPast, end: .distantFuture,
                                                                 options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1,
                                  sortDescriptors: [sortDescriptor]) { (_, samples, error) in
                                    if let error = error {
                                        print("ViewModel.fetchLatestSample() > error: \(error.localizedDescription)")
                                        completion(nil)
                                        return
                                    }
                                    guard let sample = samples?.first as? HKQuantitySample else {
                                        print("ViewModel.fetchLatestSample() > could not unwrap sample")
                                        completion(nil)
                                        return
                                    }
                                    completion(sample)
        }
        HKHealthStore().execute(query)
    }

    private func fetchHeartRate(_ completion: @escaping (_ heartRate: Double?) -> Void) {
        fetchLatestSample(for: .heartRate) { (sample) in
            guard let sample = sample else {
                print("ViewModel.fetchHeartRate() > could not unwrap heart rate")
                completion(nil)
                return
            }
            let newHeartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
            print("ViewModel.fetchHeartRate() > newHeartRate: \(newHeartRate)")
            completion(newHeartRate)
        }
    }

    private func fetchRestingHeartRate(_ completion: @escaping (_ restingHeartRate: Double?) -> Void) {
        fetchLatestSample(for: .restingHeartRate) { (sample) in
            guard let sample = sample else {
                print("ViewModel.fetchRestingHeartRate() > could not unwrap resting heart rate")
                completion(nil)
                return
            }
            let restingHeartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
            print("ViewModel.fetchRestingHeartRate() > restingHeartRate: \(restingHeartRate)")
            completion(restingHeartRate)
        }
    }
}
