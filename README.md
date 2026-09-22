# 🌊 WuFlow

<p align="center">
  <img src="Screenshots/dashboard.png" alt="WuFlow Dashboard" width="300">
</p>

<p align="center">
A native iOS app for observing, tracking, and understanding personal behavior.<br>
Built with <strong>SwiftUI</strong>, <strong>SwiftData</strong>, <strong>CoreLocation</strong>, <strong>HealthKit</strong>, and modern Apple frameworks.
</p>

---

## Overview

WuFlow started as a habit tracker, but evolved into something broader:

> **Observe behavior before trying to change it.**

Instead of focusing only on whether a habit was completed, WuFlow explores the relationship between:

- **Intention** — what the user wants to build, maintain, or reduce
- **Behavior** — what actually happens
- **Context** — where and when behavior occurs
- **Observation** — what the user notices about it
- **Insight** — patterns derived from recorded behavior

The goal is to reduce the friction of collecting this information while keeping the user in control of how it is interpreted.

WuFlow is also a technical exploration of modern native iOS development, combining system frameworks, local persistence, background automation, behavioral analysis, and testable domain logic.

---

# 🧘 Concept

WuFlow takes inspiration from the Taoist concept of **Wu Wei (無為)**, often translated as *effortless action*.

The project does not interpret this as eliminating effort. Instead, it explores how software can reduce unnecessary friction and encourage observation before intervention.

For example, instead of requiring a user to remember to record a gym session:

```text
Arrive at the gym
       ↓
CoreLocation detects the place
       ↓
WuFlow creates a session
       ↓
The user receives contextual feedback
       ↓
Behavior is recorded with minimal interaction
```

The same principle applies to HealthKit integrations and interactive notifications.

---

# ✨ Core Features

## Activity Tracking

Activities represent behaviors the user wants to:

- 🌱 **Build** — increase or develop
- 🌊 **Maintain** — preserve consistently
- 🔥 **Reduce** — decrease or move away from

Each activity can contain:

- Custom goals
- Measurement types
- Progress history
- Life-area classification
- Optional reminders
- Optional location automation
- Behavioral observations

---

## 📈 Progress Tracking

For activities that are built or maintained, WuFlow records progress over time.

Progress can be entered manually or generated automatically by system integrations.

The application provides:

- Daily progress
- Historical records
- Goal progress
- Activity summaries
- Progress charts
- Active-day visualization

Progress is stored as structured records rather than being derived from UI state.

---

# 👁️ Behavioral Observations

WuFlow separates **what happened** from **what the user noticed**.

An observation can contain:

- A timestamp
- A note
- Optional emotion
- Optional image
- An observation type

Observations currently support:

- `note`
- `incident`

This allows the same behavioral history to contain both normal reflections and meaningful events.

For example:

```text
Progress
    ↓
"I went to the gym for 45 minutes."

Observation
    ↓
"I noticed I had more energy after work today."
```

The goal is to preserve context that would otherwise be lost in a simple habit-completion system.

---

# 🔥 Decrease Activities

Decrease activities use a different behavioral model.

Instead of asking:

> "How much progress did I make?"

WuFlow can ask:

> "How long has it been since the last incident?"

Incidents are represented as structured observations rather than a separate data model.

The application calculates:

- Awareness duration
- Incident count
- Current incident-free duration
- Longest incident-free duration
- Average interval between incidents

This allows decrease-oriented behaviors to be analyzed without forcing them into the same progress model used for build/maintain activities.

---

# 📅 Behavior Calendar

WuFlow includes a calendar visualization designed to make behavioral patterns visible over time.

For **Build** and **Maintain** activities, the calendar visualizes days containing progress.

For **Reduce** activities, it visualizes days containing incidents.

The calendar is intentionally based on behavior rather than generic productivity metrics.

```text
SwiftData Records
       ↓
BehaviorDayCalculator
       ↓
BehaviorDay[]
       ↓
BehaviorCalendarCalculator
       ↓
CalendarDayPosition[]
       ↓
BehaviorCalendar
```

The calendar supports:

- Monthly navigation
- Progress mode
- Incident mode
- Day selection
- Detailed day inspection

Selecting a day opens the underlying progress and observation records for that date.

---

# 💡 Deterministic Insights

WuFlow does not rely on an AI model to perform basic behavioral analysis.

Instead, deterministic domain logic calculates meaningful patterns from structured data.

Current insights include:

### Typical Session Duration

Uses recorded location sessions to determine a typical amount of time spent at a place.

### Session Consistency

Compares session durations against the median and identifies when sessions remain relatively consistent.

### Life Area Attention

Measures how recorded progress is distributed across life areas.

### Life Area Trends

Compares two time periods and identifies changes in the distribution of activity across life areas.

These calculations live outside SwiftUI views and are independently testable.

---

# 📍 Location Automation

WuFlow uses **CoreLocation geofencing** to connect physical context with behavior.

Users can:

- Create reusable Places
- Configure a geofence radius
- Associate activities with locations
- Detect region entry
- Start activity sessions
- Receive contextual notifications

Example flow:

```text
Enter Gym
    ↓
CoreLocation Region Event
    ↓
LocationAutomationEngine
    ↓
Activity Session
    ↓
Live Activity / Notification
    ↓
Progress or session tracking
```

The location layer is separated from the persistence layer through dedicated services and automation logic.

---

# ❤️ HealthKit Integration

WuFlow can use HealthKit data to reduce manual tracking.

Current integrations include:

- Daily step data
- Workout-related data

Health data can be synchronized into WuFlow's progress model while keeping synchronization idempotent.

For example, when daily steps are synchronized, WuFlow updates the existing record for that activity and day rather than creating duplicates.

---

# 🔔 Notifications & Live Activities

WuFlow uses Apple's notification and Live Activity APIs to provide contextual feedback without requiring the application to remain open.

Interactive notifications can allow users to record progress directly from the notification.

Live Activities provide real-time session information, including support for the Dynamic Island on compatible devices.

---

# 🏗 Architecture

WuFlow separates persistence, domain calculations, system integrations, and presentation.

At a high level:

```text
                SwiftUI
                   │
                   ▼
              Application
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
   Domain Logic          System Services
        │                     │
        │              ┌──────┼─────────┐
        │              ▼      ▼         ▼
        │        CoreLocation HealthKit Notifications
        │
        ▼
   Repositories
        │
        ▼
     SwiftData
```

Behavioral calculations are intentionally kept outside the views:

```text
SwiftData
    ↓
Records
    ↓
Calculators
    ↓
Domain Summaries
    ↓
Insights / Visualization
    ↓
SwiftUI
```

This keeps business rules testable and prevents views from becoming responsible for behavioral analysis.

---

# 🧩 Domain Architecture

Some examples of the domain layer include:

```text
ProgressCalculator
DecreaseActivityCalculator
SessionDurationCalculator
SessionConsistencyCalculator
LifeAreaAttentionCalculator
LifeAreaTrendCalculator
BehaviorDayCalculator
BehaviorCalendarCalculator
PeriodCalculator
InsightEngine
```

Each calculator has a focused responsibility and can be tested independently from SwiftUI.

---

# 💾 Persistence

WuFlow uses **SwiftData** for local persistence.

Core models include:

```text
Activity
    │
    ├── ProgressRecord[]
    ├── ObservationRecord[]
    └── Place

Place
    │
    └── PlaceSession
```

Observations support multiple behavioral meanings through a structured observation type:

```text
Observation
    ├── Note
    └── Incident
```

This avoids creating separate persistence models for every kind of behavioral event.

---

# 🧪 Testing

Domain logic is covered with unit tests using an in-memory SwiftData configuration where persistence behavior needs to be exercised.

Current test coverage includes areas such as:

- Progress calculations
- Decrease activity calculations
- Incident intervals
- Session duration calculations
- Session consistency
- Life-area attention
- Life-area trends
- Behavior-day aggregation
- Behavior calendar positioning
- Observation filtering
- Mixed progress / incident data

The goal is to keep behavioral rules independent from the UI so they can be validated through deterministic tests.

---

# 🛠 Technologies

## Language

- Swift 6

## UI

- SwiftUI
- NavigationStack
- Charts
- SF Symbols

## Persistence

- SwiftData
- `@Model`
- `@ModelActor`
- Repository Pattern

## Apple Frameworks

- CoreLocation
- MapKit
- HealthKit
- UserNotifications
- ActivityKit
- WidgetKit

## Concurrency

- Swift Concurrency
- `async/await`
- Actors
- Structured concurrency

## Testing

- XCTest
- In-memory SwiftData containers
- Unit testing of domain logic

---

# 📁 Project Structure

```text
WuFlow
│
├── Features
│   ├── Activities
│   ├── Places
│   ├── Statistics
│   └── Settings
│
├── Components
│
├── Domain
│   ├── Progress
│   ├── Observations
│   ├── Insights
│   ├── Sessions
│   └── BehaviorCalendar
│
├── Services
│   ├── LocationService
│   ├── HealthKitSyncService
│   └── NotificationManager
│
├── Automation
│   ├── LocationAutomationEngine
│   └── NotificationActionHandler
│
├── Persistence
│   ├── Models
│   └── Repositories
│
└── Resources
```

---

# 🚀 Engineering Highlights

WuFlow demonstrates several areas of modern iOS development:

- Native SwiftUI application architecture
- SwiftData persistence
- Repository Pattern
- Dependency Injection
- `@ModelActor`
- Swift Concurrency
- CoreLocation geofencing
- HealthKit synchronization
- Interactive notifications
- Live Activities
- Dynamic Island integration
- MapKit-based location selection
- Deterministic behavioral analysis
- Reusable SwiftUI components
- Unit-tested domain logic
- Separation between UI and business rules

---

# 🗺 Roadmap

The project is being developed incrementally.

### Completed

- Activity tracking
- Progress persistence
- HealthKit integration
- Location automation
- Place sessions
- Behavioral observations
- Incident tracking
- Decrease activity model
- Deterministic insights
- Behavior Calendar
- Live Activities

### Next

- Behavioral experiments
- Experiment tracking
- Comparing behavior before and after intentional changes
- Additional deterministic insights

### Future Exploration

- AI-assisted behavioral synthesis
- Apple Watch integration
- Widgets
- Shortcuts
- Additional automation sources
- Cloud synchronization

AI is intentionally planned after the deterministic analysis layer so that structured behavioral data and explicit rules form the foundation for any future interpretation.

---

# 📸 Screenshots

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

> Additional screenshots for observations, decrease activities, the Behavior Calendar, and Live Activities will be added as the project presentation evolves.

---

# 🎯 Why WuFlow?

Most habit trackers primarily ask users to record whether something happened.

WuFlow explores a different question:

> **What can we learn when behavior, context, and observation are recorded together?**

The project combines automatic context with explicit user input to create a richer behavioral history while keeping the underlying system understandable and deterministic.

It is both a personal application and an ongoing exploration of modern iOS engineering.

---

# 👨‍💻 Author

**Roberto Abad**  
Senior Software Engineer

📱 iOS — Swift, SwiftUI  
🌐 Full-Stack — .NET, C#

🔗 [GitHub](https://github.com/RobertoAbad505)

🔗 [LinkedIn](https://www.linkedin.com/in/robertoabad95/)

🔗 [Portfolio](https://roberto-abad.web.app)

---

# 📜 License

This project is open for educational and portfolio purposes.
