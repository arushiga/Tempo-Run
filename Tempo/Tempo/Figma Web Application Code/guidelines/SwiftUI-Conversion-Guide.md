  # SwiftUI Conversion Guide for Run Planner

## Overview
This guide will help you convert the React-based run planner into a native iOS app using SwiftUI.

---

## 1. Project Structure

```
RunPlanner/
├── RunPlannerApp.swift          // App entry point
├── Models/
│   ├── RunType.swift            // Enum for run types
│   └── ScheduledRun.swift       // Data model
├── ViewModels/
│   └── PlannerViewModel.swift   // State management
├── Views/
│   ├── ContentView.swift        // Main view
│   ├── WeeklyPlannerView.swift  // Calendar grid
│   ├── CalendarCellView.swift   // Individual cells
│   ├── RunTypePickerView.swift  // Draggable run types
│   └── StatisticsView.swift     // Stats cards
└── Assets/
    └── ShoeIcons/               // SF Symbols or custom icons
```

---

## 2. Data Models

### RunType.swift
```swift
import SwiftUI

enum RunType: String, Codable, CaseIterable, Identifiable {
    case easy = "Easy"
    case tempo = "Tempo"
    case race = "Race"
    case longRun = "Long Run"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .easy: return Color(hex: "#068EF6")
        case .tempo: return Color(hex: "#D59A34")
        case .race: return Color(hex: "#DC69D8")
        case .longRun: return Color(hex: "#1B9A28")
        }
    }
    
    var icon: String {
        // Using SF Symbols
        switch self {
        case .easy: return "shoe.fill"
        case .tempo: return "shoe.2.fill"
        case .race: return "flag.fill"
        case .longRun: return "figure.run"
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

### ScheduledRun.swift
```swift
import Foundation

struct ScheduledRun: Identifiable, Codable {
    let id: UUID
    var type: RunType
    var day: Int // 0-6 (Monday-Sunday)
    var time: TimeOfDay
    
    init(type: RunType, day: Int, time: TimeOfDay) {
        self.id = UUID()
        self.type = type
        self.day = day
        self.time = time
    }
}

enum TimeOfDay: String, Codable {
    case am = "AM"
    case pm = "PM"
}
```

---

## 3. ViewModel (State Management)

### PlannerViewModel.swift
```swift
import SwiftUI
import Combine

class PlannerViewModel: ObservableObject {
    @Published var scheduledRuns: [ScheduledRun] = [
        ScheduledRun(type: .easy, day: 0, time: .am),
        ScheduledRun(type: .tempo, day: 1, time: .pm)
    ]
    
    // Add or replace run
    func dropRun(type: RunType, day: Int, time: TimeOfDay) {
        // Check if slot is occupied
        if let index = scheduledRuns.firstIndex(where: { $0.day == day && $0.time == time }) {
            // Replace existing run
            scheduledRuns[index] = ScheduledRun(type: type, day: day, time: time)
        } else {
            // Add new run
            scheduledRuns.append(ScheduledRun(type: type, day: day, time: time))
        }
    }
    
    // Remove run
    func removeRun(id: UUID) {
        scheduledRuns.removeAll { $0.id == id }
    }
    
    // Move run
    func moveRun(id: UUID, to day: Int, time: TimeOfDay) {
        if let index = scheduledRuns.firstIndex(where: { $0.id == id }) {
            scheduledRuns[index].day = day
            scheduledRuns[index].time = time
        }
    }
    
    // Statistics
    var stats: [RunType: Int] {
        var counts: [RunType: Int] = [:]
        for run in scheduledRuns {
            counts[run.type, default: 0] += 1
        }
        return counts
    }
    
    var totalRuns: Int {
        scheduledRuns.count
    }
    
    var relativeLoad: Int {
        43 - (7 - totalRuns) * 5
    }
    
    var trainingIntensity: Int {
        15 + (stats[.tempo] ?? 0) * 5 + (stats[.race] ?? 0) * 10
    }
}
```

---

## 4. Main View

### ContentView.swift
```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PlannerViewModel()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "#F8FAFC"),
                    Color(hex: "#EFF6FF"),
                    Color(hex: "#F1F5F9")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HeaderView()
                    
                    // Calendar Grid
                    WeeklyPlannerView()
                        .environmentObject(viewModel)
                        .padding()
                    
                    // Run Type Picker
                    RunTypePickerView()
                        .environmentObject(viewModel)
                        .padding(.horizontal)
                    
                    // Statistics
                    StatisticsView()
                        .environmentObject(viewModel)
                        .padding()
                }
            }
        }
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Planner")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Drag and drop to schedule your runs")
                .font(.system(size: 14))
                .foregroundColor(Color.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [Color(hex: "#2563EB"), Color(hex: "#4F46E5")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}
```

---

## 5. Drag and Drop Implementation

### CalendarCellView.swift
```swift
import SwiftUI

struct CalendarCellView: View {
    @EnvironmentObject var viewModel: PlannerViewModel
    let day: Int
    let time: TimeOfDay
    
    var scheduledRun: ScheduledRun? {
        viewModel.scheduledRuns.first { $0.day == day && $0.time == time }
    }
    
    @State private var isTargeted = false
    
    var body: some View {
        ZStack {
            // Cell background
            RoundedRectangle(cornerRadius: 12)
                .fill(cellBackground)
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(cellBorder, lineWidth: isTargeted ? 3 : 2.5)
                )
                .shadow(
                    color: scheduledRun != nil ? .black.opacity(0.1) : .clear,
                    radius: 4
                )
            
            // Icon if scheduled
            if let run = scheduledRun {
                Image(systemName: run.type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(run.type.color)
                    .draggable(run) // Enable dragging
            }
        }
        .scaleEffect(isTargeted ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isTargeted)
        // Drop destination
        .dropDestination(for: ScheduledRun.self) { items, location in
            if let run = items.first {
                viewModel.moveRun(id: run.id, to: day, time: time)
            }
            return true
        } isTargeted: { targeted in
            isTargeted = targeted
        }
        .dropDestination(for: RunType.self) { types, location in
            if let type = types.first {
                viewModel.dropRun(type: type, day: day, time: time)
            }
            return true
        } isTargeted: { targeted in
            isTargeted = targeted
        }
        .onTapGesture(count: 2) {
            // Double tap to remove
            if let run = scheduledRun {
                withAnimation {
                    viewModel.removeRun(id: run.id)
                }
            }
        }
    }
    
    private var cellBackground: Color {
        if let run = scheduledRun {
            return run.type.color.opacity(0.08)
        } else if isTargeted {
            return Color.blue.opacity(0.1)
        } else {
            return Color.white
        }
    }
    
    private var cellBorder: Color {
        if isTargeted {
            return Color.blue
        } else if let run = scheduledRun {
            return run.type.color
        } else {
            return Color.gray.opacity(0.2)
        }
    }
}
```

### WeeklyPlannerView.swift
```swift
import SwiftUI

struct WeeklyPlannerView: View {
    @EnvironmentObject var viewModel: PlannerViewModel
    let days = ["M", "T", "W", "R", "F", "S", "S"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Day headers
            HStack(spacing: 40) {
                Spacer()
                    .frame(width: 32)
                
                ForEach(0..<7) { day in
                    Text(days[day])
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#475569"))
                        .frame(width: 40)
                }
            }
            
            // Grid
            VStack(spacing: 20) {
                ForEach([TimeOfDay.am, TimeOfDay.pm], id: \.self) { time in
                    HStack(spacing: 40) {
                        Text(time.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "#64748B"))
                            .frame(width: 32)
                        
                        ForEach(0..<7) { day in
                            CalendarCellView(day: day, time: time)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#F8FAFC"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
            
            Text("💡 Drag to move • Double-tap to remove")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#64748B"))
        }
    }
}
```

### RunTypePickerView.swift
```swift
import SwiftUI

struct RunTypePickerView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Run Types")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#475569"))
            
            HStack(spacing: 32) {
                ForEach(RunType.allCases) { type in
                    DraggableRunTypeView(runType: type)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#F8FAFC"),
                            Color(hex: "#EFF6FF").opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct DraggableRunTypeView: View {
    let runType: RunType
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(runType.color.opacity(0.08))
                    .frame(width: 52, height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(runType.color, lineWidth: 2.5)
                    )
                
                Image(systemName: runType.icon)
                    .font(.system(size: 24))
                    .foregroundColor(runType.color)
            }
            .scaleEffect(isDragging ? 0.9 : 1.0)
            .opacity(isDragging ? 0.5 : 1.0)
            
            Text(runType.rawValue)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "#475569"))
        }
        .draggable(runType) {
            // Drag preview
            Image(systemName: runType.icon)
                .font(.system(size: 32))
                .foregroundColor(runType.color)
                .onAppear { isDragging = true }
                .onDisappear { isDragging = false }
        }
    }
}
```

---

## 6. Statistics View

### StatisticsView.swift
```swift
import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var viewModel: PlannerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📊")
                Text("Upcoming Week (March 9-15)")
                    .font(.system(size: 16, weight: .bold))
            }
            
            // Stats grid
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
                StatCardView(
                    label: "Easy Runs",
                    value: viewModel.stats[.easy] ?? 0,
                    backgroundColor: Color.blue.opacity(0.1),
                    textColor: Color.blue
                )
                StatCardView(
                    label: "Tempo Runs",
                    value: viewModel.stats[.tempo] ?? 0,
                    backgroundColor: Color.orange.opacity(0.1),
                    textColor: Color.orange
                )
                StatCardView(
                    label: "Races",
                    value: viewModel.stats[.race] ?? 0,
                    backgroundColor: Color.pink.opacity(0.1),
                    textColor: Color.pink
                )
                StatCardView(
                    label: "Long Runs",
                    value: viewModel.stats[.longRun] ?? 0,
                    backgroundColor: Color.green.opacity(0.1),
                    textColor: Color.green
                )
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Metrics
            MetricCardView(
                label: "Relative Load",
                value: viewModel.relativeLoad,
                isHigh: viewModel.relativeLoad > 30
            )
            MetricCardView(
                label: "Training Intensity",
                value: viewModel.trainingIntensity,
                isHigh: viewModel.trainingIntensity > 20
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct StatCardView: View {
    let label: String
    let value: Int
    let backgroundColor: Color
    let textColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            Text("\(value)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.gray.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct MetricCardView: View {
    let label: String
    let value: Int
    let isHigh: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#475569"))
            
            Spacer()
            
            Text("\(value > 0 ? "+" : "")\(value)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isHigh ? Color.orange : Color.green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHigh ? Color.orange.opacity(0.1) : Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isHigh ? Color.orange.opacity(0.3) : Color.green.opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
    }
}
```

---

## 7. App Entry Point

### RunPlannerApp.swift
```swift
import SwiftUI

@main
struct RunPlannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

## 8. Key SwiftUI Concepts Used

### Drag and Drop
- **`.draggable()`** - Makes views draggable
- **`.dropDestination()`** - Creates drop zones
- Both support custom data types (RunType, ScheduledRun)

### State Management
- **`@StateObject`** - Creates and owns ViewModel
- **`@EnvironmentObject`** - Shares ViewModel across views
- **`@Published`** - Triggers view updates on data changes

### Layout
- **`VStack/HStack/ZStack`** - Vertical/horizontal/overlay stacks
- **`LazyVGrid`** - Grid layout for stats
- **`.frame()`** - Set view sizes
- **`.padding()`** - Add spacing

### Styling
- **`RoundedRectangle`** - Rounded corners
- **`LinearGradient`** - Gradient backgrounds
- **`.shadow()`** - Drop shadows
- **`.overlay()`** - Border overlays

---

## 9. Next Steps for Full iOS App

### Data Persistence
```swift
// Add to PlannerViewModel
import Foundation

class PlannerViewModel: ObservableObject {
    // ... existing code ...
    
    // Save to UserDefaults
    func save() {
        if let encoded = try? JSONEncoder().encode(scheduledRuns) {
            UserDefaults.standard.set(encoded, forKey: "scheduledRuns")
        }
    }
    
    // Load from UserDefaults
    func load() {
        if let data = UserDefaults.standard.data(forKey: "scheduledRuns"),
           let decoded = try? JSONDecoder().decode([ScheduledRun].self, from: data) {
            scheduledRuns = decoded
        }
    }
}
```

### HealthKit Integration
```swift
import HealthKit

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    func requestAuthorization() {
        let workoutType = HKObjectType.workoutType()
        let typesToRead: Set = [workoutType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            // Handle authorization
        }
    }
}
```

### CloudKit Sync
```swift
import CloudKit

class CloudKitManager {
    let container = CKContainer.default()
    
    func saveRuns(_ runs: [ScheduledRun]) async throws {
        let database = container.privateCloudDatabase
        // Convert to CKRecord and save
    }
}
```

### Notifications
```swift
import UserNotifications

class NotificationManager {
    func scheduleRunReminder(for run: ScheduledRun) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Run!"
        content.body = "You have a \(run.type.rawValue) scheduled"
        
        // Schedule notification
    }
}
```

---

## 10. Tips for Development

1. **Use Xcode Previews** - Fast iteration
```swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

2. **SF Symbols** - Free icon library (shoe.fill, figure.run, etc.)

3. **Test on Device** - Drag and drop feels different on hardware

4. **Use SwiftUI Preview Device Variations**
```swift
.previewDevice("iPhone 15 Pro")
.previewDisplayName("iPhone 15 Pro")
```

5. **Accessibility** - Add labels for VoiceOver
```swift
.accessibilityLabel("Monday AM slot")
.accessibilityHint("Double tap to schedule a run")
```

---

## Resources

- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Drag and Drop in SwiftUI](https://developer.apple.com/documentation/swiftui/drag-and-drop)
- [HealthKit Framework](https://developer.apple.com/documentation/healthkit)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

## Conclusion

This conversion maintains all the functionality of your React app while leveraging SwiftUI's native features:
- Native drag and drop
- Smooth animations
- Better performance
- iOS design patterns
- Easy integration with iOS features (HealthKit, CloudKit, etc.)

Start with the basic structure, then add features incrementally!
