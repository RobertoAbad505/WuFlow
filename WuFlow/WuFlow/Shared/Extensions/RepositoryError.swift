//
//  RepositoryError.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/21/26.
//


import Foundation

enum RepositoryError: LocalizedError {

    case placeNotFound(String)
    case activeSessionNotFound(String)
    case duplicateActiveSession(String)
    case saveFailed(Error)
    case activityNotFound(UUID)
    case placeSessionNotFound(UUID)
    case activeSessionNotFinished(UUID)

    var errorDescription: String? {
        switch self {

        case .placeNotFound(let regionIdentifier):
            return "No place found for region identifier '\(regionIdentifier)'."

        case .activeSessionNotFound(let regionIdentifier):
            return "No active session found for region '\(regionIdentifier)'."

        case .duplicateActiveSession(let regionIdentifier):
            return "An active session already exists for region '\(regionIdentifier)'."

        case .saveFailed(let error):
            return "Failed to save changes: \(error.localizedDescription)"
        case .activityNotFound(_):
            return "RepositoryError - Activity not found"
        case .placeSessionNotFound(_):
            return "RepositoryError - PlaceSession not found"
        case .activeSessionNotFinished(_):
            return "RepositoryError - ActiveSession not finished"
        }
    }
}
