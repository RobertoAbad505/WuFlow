//
//  EnvironmentValues.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/12/26.
//

import Foundation
import SwiftUI

extension EnvironmentValues {

    var repository: ActivityRepository? {
        get { self[ActivityRepositoryKey.self] }
        set { self[ActivityRepositoryKey.self] = newValue }
    }

}
private struct ActivityRepositoryKey: EnvironmentKey {
    static let defaultValue: ActivityRepository? = nil
}
