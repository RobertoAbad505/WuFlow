# 🌊 WuFlow

<p align="center">
  <img src="Screenshots/dashboard.png" alt="WuFlow Dashboard" width="300">
</p>

<p align="center">
A native iOS habit tracker that reduces friction through automation.<br>
Built with <strong>SwiftUI</strong>, <strong>SwiftData</strong>, <strong>CoreLocation</strong>, <strong>HealthKit</strong>, and modern Apple frameworks.
</p>

---

# Overview

WuFlow is a native iOS application designed around a simple idea:

> **The easiest habit to maintain is the one you don't have to remember.**

Rather than relying entirely on manual interaction, WuFlow integrates with Apple system frameworks to automate habit tracking whenever possible.

Examples include:

- 📍 Detecting when you arrive at the gym using geofencing
- ❤️ Reading health data from HealthKit
- 🔔 Triggering interactive notifications
- ✅ Recording progress directly from a notification without opening the app

The project is inspired by the Taoist concept of **Wu Wei (無為)**—often translated as *effortless action*—encouraging consistent progress while minimizing friction.

---

# Features

## Activity Management

- Create and organize activities
- Multiple measurement types
- Custom goals
- Progress history
- Statistics dashboard
- Rich activity details

---

## Location Automation

WuFlow supports background location automation using **CoreLocation Geofencing**.

Users can:

- Create reusable Places
- Configure a geofence radius
- Associate activities with locations
- Receive notifications upon entering a region
- Record progress directly from the notification

### Automation Flow

```
Enter Gym

      ↓

CoreLocation Region Event

      ↓

LocationAutomationEngine

      ↓

ActivityRepository

      ↓

Interactive Notification

      ↓

User taps "Done"

      ↓

Progress saved

      ↓

Confirmation notification
```

No need to manually open the application.

---

## HealthKit Integration

WuFlow can integrate with HealthKit to automate activities based on Apple Health data.

Current integrations include:

- Daily Steps
- Workout tracking

The architecture allows additional HealthKit metrics to be added with minimal changes.

---

## Statistics

Track your consistency with:

- Daily progress
- Weekly summaries
- Monthly trends
- Goal completion
- Activity history

---

# Screenshots

## Dashboard

<p align="center">
<img src="Screenshots/dashboard.png" width="250">
</p>

---

## Activity Detail

<p align="center">
<img src="Screenshots/activity-detail.png" width="250">
</p>

---

## Location Automation

<p align="center">
<img src="Screenshots/location-map.png" width="250">
<img src="Screenshots/location-notification.png" width="250">
</p>

---

## Statistics

<p align="center">
<img src="Screenshots/statistics.png" width="250">
</p>

---

# Architecture

WuFlow follows a layered architecture focused on separation of concerns.

```
SwiftUI Views
        │
        ▼
 ViewModels
        │
        ▼
 ActivityRepository (@ModelActor)
        │
        ▼
    SwiftData
```

Background automation is isolated from persistence through dedicated automation engines.

```
CoreLocation
        │
        ▼
LocationService
        │
        ▼
LocationAutomationEngine
        │
        ▼
ActivityRepository
        │
        ▼
NotificationManager
        │
        ▼
NotificationActionHandler
```

This separation keeps system frameworks independent from business logic while making new automation providers easy to introduce.

---

# Technologies

## Language

- Swift 6

---

## UI

- SwiftUI
- NavigationStack
- Charts
- Observation
- SF Symbols

---

## Persistence

- SwiftData
- ModelActor
- Repository Pattern

---

## Apple Frameworks

### CoreLocation

Used for:

- Region monitoring
- Geofencing
- Background location events

---

### HealthKit

Used for:

- Step counting
- Workout synchronization
- Health-based automations

---

### UserNotifications

Used for:

- Interactive notifications
- Notification actions
- Background progress recording

---

### MapKit

Used to visualize Places and monitored regions.

---

### Swift Concurrency

- async/await
- Actors
- Structured concurrency

---

# Engineering Highlights

This project demonstrates:

- Modern SwiftUI architecture
- Feature-oriented design
- Dependency Injection
- Repository Pattern
- Background execution
- Interactive notifications
- SwiftData with @ModelActor
- HealthKit integration
- CoreLocation geofencing
- Clean separation of concerns
- Reusable SwiftUI components
- Async/Await throughout the application

---

# Project Structure

```
WuFlow

├── Features
│   ├── Activities
│   ├── Places
│   ├── Statistics
│   └── Settings
│
├── Components
│
├── Services
│   ├── LocationService
│   ├── NotificationManager
│   └── HealthKitSyncService
│
├── Automation
│   ├── LocationAutomationEngine
│   └── NotificationActionHandler
│
├── Persistence
│   ├── ActivityRepository
│   └── SwiftData Models
│
└── Resources
```

---

# Why WuFlow?

Most habit trackers depend on users remembering to record every activity.

WuFlow explores a different approach.

Instead of asking users to constantly interact with the application, it leverages Apple's native frameworks to reduce friction through automation.

The goal isn't simply to track habits.

The goal is to make maintaining them feel effortless.

---

# Future Ideas

Some ideas currently being explored:

- Apple Watch companion app
- Widgets
- Live Activities
- Shortcuts integration
- CloudKit synchronization
- Additional automation providers
- Motion-based activities

---

# Author

**Roberto Abad**

Senior Software Engineer

- Native iOS Development
- SwiftUI
- SwiftData
- CoreLocation
- HealthKit
- .NET

Portfolio

https://roberto-abad.web.app/

LinkedIn

https://www.linkedin.com/in/robertoabad95/

GitHub

https://github.com/RobertoAbad505
