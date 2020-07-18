//
//  ViewModel.swift
//  Zones WatchKit Extension
//
//  Created by Steph Ananth on 7/17/20.
//  Copyright © 2020 Steph K. Ananth. All rights reserved.
//

import Foundation
import HealthKit

class ViewModel: ObservableObject {

    let healthStore = HKHealthStore()

    func authorizeHealthKit() {
        print("ViewModel.authorizeHealthKit()")
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        let healthKitTypes: Set<HKSampleType> = [heartRateType]
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (success, error) in
            if let error = error {
                print("ViewModel.authorizeHealthKit() > error: \(error.localizedDescription)")
            } else {
                print("ViewModel.authorizeHealthKit() > success: \(success)")
            }
        }
    }

}
