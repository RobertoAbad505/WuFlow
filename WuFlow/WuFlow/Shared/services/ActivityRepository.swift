//
//  ActivityRepository.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/3/26.
//
import Foundation
import SwiftData

@ModelActor
actor ActivityRepository {
    
    func activity(id: UUID) throws -> Activity? {
        let descriptor = FetchDescriptor<Activity>(
            predicate: #Predicate {
                $0.id == id
            }
        )
        return try modelContext.fetch(descriptor).first
    }
    func activities(placeIdentifier: String) throws -> [Activity] {
        let descriptor = FetchDescriptor<Activity>()
        return try modelContext.fetch(descriptor)
            .filter {
                $0.trackingType == .location &&
                $0.place?.identifier == placeIdentifier
            }
    }
    func createActivity(from draft: ActivityDraft) throws {
        let activity = Activity(
            name: "",
            unitType: .count,
            goalValue: 1
        )
        apply(
            draft: draft,
            to: activity
        )
        modelContext.insert(activity)
        try modelContext.save()
    }
    
    func updateActivity(id: UUID, from draft: ActivityDraft) throws {
        guard let activity = try activity(id: id) else {
            return
        }
        apply(
            draft: draft,
            to: activity
        )
        modelContext.insert(activity)
        try modelContext.save()
    }
    func deleteActivity(id: UUID) throws {
        guard let activity = try activity(id: id) else {
            return
        }
        modelContext.delete(activity)
        try modelContext.save()
    }
    func togglePinned(id: UUID) throws {
        guard let activity = try activity(id: id) else {
            return
        }
        activity.isPinned.toggle()
        activity.pinPriority = activity.isPinned ? 1:0        
        try modelContext.save()
    }
    func enableNotifications(id: UUID) throws {
        guard let activity = try activity(id: id) else {
            return
        }
        activity.remindersEnabled.toggle()
        try modelContext.save()
    }
    func syncHealthSteps(totalSteps: Double) throws {
        guard totalSteps > 0 else {
            print("No steps today, sync skipped")
            return
        }
        
        guard let activity = try automatedActivity(trackingType: .healthSteps) else {
            print("No healt activity found for \(TrackingType.healthSteps.title)")
            return
        }
        let imported = importedSteps(activity)
        let difference = totalSteps - imported
        guard difference > 0 else {
            print("✅ STEPS synchronized")
            return
        }
        try addProgress(
            activity: activity,
            value: difference,
            source: .healthSteps
        )
        print("🔄 HealthKit Synchronization ─────────────────────────")
        print("Activity:", activity.name)
        print("Provider:", activity.trackingType.rawValue)
        print("HealthKit total steps:", totalSteps)
        print("Already imported steps:", imported)
        print("Total new steps:", difference)

    }
    func addProgress(
        activityId: UUID,
        value: Double,
        source: TrackingType
    ) throws {
        guard let activity = try activity(id: activityId) else {
            return
        }
        try addProgress(
            activity: activity,
            value: value,
            source: source
        )
    }

    private func addProgress(activity: Activity, value: Double, source: TrackingType) throws {
        let record = ProgressRecord(
            value: value,
            source: source,
            activity: activity
        )
        modelContext.insert(record)
        try modelContext.save()
    }
    
    func automatedActivity(trackingType: TrackingType) throws -> Activity? {
        let type = trackingType.rawValue
        let descriptor = FetchDescriptor<Activity>(
            predicate: #Predicate<Activity> {
                $0.trackingTypeRaw == type
            }
        )
        do {
            return try modelContext.fetch(descriptor).first
        } catch let error {
            throw error
        }
    }
    
    func importedSteps(_ activity: Activity) -> Double {
        let importedSteps = activity.progressRecords
            .filter {
                Calendar.current.isDateInToday($0.date)
                &&
                $0.source == .healthSteps
            }
            .reduce(0) {
                $0 + $1.value
            }
        return importedSteps
    }
    
    func resetTodayHealthStepSync(_ activity: Activity) throws {
        let calendar = Calendar.current

        let records = activity.progressRecords.filter {
            calendar.isDateInToday($0.date) && $0.source == .healthSteps
        }

        records.forEach {
            modelContext.delete($0)
        }
        try modelContext.save()
        print("✅ Today's imported HealthKit steps removed. Total affected: \(records.count)")
    }
    func completeReminder(activityId: UUID) throws -> Activity? {
        guard let activity = try activity(id: activityId) else {
            return nil
        }
        guard !hasRecentProgress(activity: activity, source: .reminder, within: 300) else {
            return nil
        }
        try addProgress(
            activity: activity,
            value: activity.defaultIncrement,
            source: .reminder
        )
        return activity
    }
    private func hasRecentProgress(
        activity: Activity,
        source: TrackingType,
        within interval: TimeInterval
    ) -> Bool {

        let threshold = Date().addingTimeInterval(-interval)
        return activity.progressRecords.contains {
            $0.source == source &&
            $0.date >= threshold
        }
    }
    private func apply(
        draft: ActivityDraft,
        to activity: Activity
    ) {
        activity.name = draft.name
        activity.unitType = draft.unitType
        activity.goalValue = draft.goalValue
        activity.trackingType = draft.trackingType
        activity.iconName = draft.iconName
        activity.motivationDescription = draft.motivationDescription
        activity.expectedOutcomeDescription = draft.expectedOutcomeDescription
        activity.imagePath = draft.imagePath
        activity.type = draft.type
        activity.lifeArea = draft.lifeArea
        activity.secondaryNote = draft.secondaryNote
        activity.measurementRaw = draft.measurementTypeRaw
        activity.goalPeriodRaw = draft.goalPeriodRaw
        try? assignPlace(
            withID: draft.placeID,
            to: activity
        )
    }
    func assignPlace(
        withID id: Place.ID?,
        to activity: Activity
    ) throws {
        guard let id else {
            activity.place = nil
            return
        }
        activity.place = try place(id: id)
    }
}
extension ActivityRepository {
    // MARK: - Places
    func createPlace(
        identifier: String,
        name: String,
        latitude: Double,
        longitude: Double,
        radius: Double = 100,
        isMonitored: Bool = true
    ) throws -> Place {
        let place = Place(
            identifier: identifier,
            name: name,
            latitude: latitude,
            longitude: longitude,
            isMonitored: isMonitored,
            radius: radius
        )
        modelContext.insert(place)
        try modelContext.save()
        return place
    }
    
    func place(identifier: String) throws -> Place? {
        let descriptor = FetchDescriptor<Place>(
            predicate: #Predicate {
                $0.identifier == identifier
            })

        return try modelContext.fetch(descriptor).first
    }
    func place(id: Place.ID) throws -> Place? {
        let descriptor = FetchDescriptor<Place>()
        return try modelContext.fetch(descriptor)
            .first {
                $0.id == id
            }
    }
    func place(named name: String) throws -> Place? {
        let descriptor = FetchDescriptor<Place>(
            predicate: #Predicate {
                $0.name == name
            }
        )
        return try modelContext.fetch(descriptor).first
    }
    func places() throws -> [Place] {
        let descriptor = FetchDescriptor<Place>(
            sortBy: [
                SortDescriptor(\.name)
            ]
        )
        return try modelContext.fetch(descriptor)
    }
    func monitoredPlaces() throws -> [Place] {
        let descriptor = FetchDescriptor<Place>(
            predicate: #Predicate {
                $0.isMonitored
            },
            sortBy: [
                SortDescriptor(\.name)
            ]
        )
        return try modelContext.fetch(descriptor)
    }
    func updatePlace(
        _ place: Place,
        identifier: String,
        name: String,
        latitude: Double,
        longitude: Double,
        radius: Double,
        isMonitored: Bool
    ) throws {
        place.identifier = identifier
        place.name = name
        place.latitude = latitude
        place.longitude = longitude
        place.radius = radius
        place.isMonitored = isMonitored

        try modelContext.save()
    }
    func deletePlace(_ place: Place) throws {
        modelContext.delete(place)
        try modelContext.save()
    }
}
//Place persistance endpoints
extension ActivityRepository {
    func activePlaceSession(regionIdentifier: String) throws -> PlaceSession? {

        let sessions = try modelContext.fetch(
            FetchDescriptor<PlaceSession>()
        )

        print("================================")
        print("PlaceSessions found: \(sessions.count)")

        for session in sessions {
            print("""
            id: \(session.id)
            place: \(session.place.name)
            identifier: \(session.place.identifier)
            active: \(session.isActive)
            """)
        }

        print("================================")

        return sessions.first(where: \.isActive)
    }

    func createPlaceSession(regionIdentifier: String, trigger: SessionTrigger) throws -> PlaceSession {
        
        let descriptor = FetchDescriptor<Place>(
            predicate: #Predicate {
                $0.identifier == regionIdentifier
            }
        )

        guard let place = try modelContext.fetch(descriptor).first else {
            throw RepositoryError.placeNotFound(regionIdentifier)
        }

        let session = PlaceSession(
            place: place,
            trigger: trigger
        )

        modelContext.insert(session)

        try modelContext.save()
        let sessions = try modelContext.fetch(
            FetchDescriptor<PlaceSession>()
        )
        print("Sessions count After save: \(sessions.count)")
        return session
    }

    func endPlaceSession(
        regionIdentifier: String
    ) throws -> PlaceSession {
        guard let session = try activePlaceSession(regionIdentifier: regionIdentifier) else {
            throw RepositoryError.activeSessionNotFound(regionIdentifier)
        }
        session.end()
        do {
            try modelContext.save()
            return session
        } catch {
            throw RepositoryError.saveFailed(error)
        }
    }
    func placeSession(id: UUID) throws -> PlaceSession? {
        let descriptor = FetchDescriptor<PlaceSession>(
            predicate: #Predicate {
                $0.id == id
            }
        )

        return try modelContext.fetch(descriptor).first
    }
    func completePlaceSession(
        activityID: UUID,
        sessionID: UUID
    ) throws -> Activity {
        
        guard let activity = try activity(id: activityID) else {
            throw RepositoryError.activityNotFound(activityID)
        }
        
        let existing = activity.progressRecords.contains {
            $0.placeSession?.id == sessionID
        }

        guard !existing else {
            return activity
        }

        guard let session = try placeSession(id: sessionID) else {
            throw RepositoryError.placeSessionNotFound(sessionID)
        }

        guard session.endedAt != nil else {
            throw RepositoryError.activeSessionNotFinished(sessionID)
        }

        let record = ProgressRecord(
            value: activity.defaultIncrement,
            source: .location,
            activity: activity
        )
        record.placeSession = session
        modelContext.insert(record)

        try modelContext.save()

        return activity
    }
}
