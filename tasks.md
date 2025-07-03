# Activity Monitoring App Refactoring Tasks

## Overview
Transform the workout-centric app into a general activity monitoring app that passively tracks health metrics without requiring users to manually start workouts, following the StepTracker pattern.

## Phase 1: Core Architecture Refactoring

### 1.1 Create New Activity Monitor System
- [x] Create `ActivityMonitor.swift` (based on StepTracker pattern)
  - [x] Passive monitoring of multiple health metrics (steps, distance, heart rate, energy)
  - [x] Automatic background polling every 5 minutes
  - [x] Observable state management
  - [x] Singleton pattern for shared access

### 1.2 Expand HealthKit Provider
- [x] Update `HealthKitProvider.swift` to support comprehensive health metrics
  - [x] Add heart rate monitoring
  - [x] Add active/resting energy monitoring
  - [ ] Add sleep data (if available)
  - [ ] Add workout detection (passive)
  - [x] Update authorization requests

### 1.3 Create New Data Models
- [ ] Create `ActivitySummaryModel.swift` for comprehensive daily activity
  - [ ] Combine steps, distance, energy, heart rate
  - [ ] Activity level classification (sedentary, lightly active, moderately active, very active)
  - [ ] Goal progress tracking
- [ ] Create `HealthMetricsModel.swift` for real-time health data
- [ ] Update `MetricsModel.swift` to support passive monitoring context

### 1.4 Background Processing
- [ ] Create `BackgroundActivityProcessor.swift`
  - [ ] Background app refresh handling
  - [ ] HealthKit observer queries for real-time updates
  - [ ] Automatic goal tracking and notifications

## Phase 2: UI/UX Transformation

### 2.1 Main App Interface Redesign
- [x] Replace workout-centric navigation with activity-focused tabs
  - [x] "Today" tab (current activity summary)
  - [x] "Trends" tab (historical data and trends)
  - [ ] "Goals" tab (goal setting and progress)
  - [x] "Health" tab (comprehensive health metrics)

### 2.2 New View Components
- [x] Create `ActivityDashboardView.swift` - Main activity overview
  - [x] Real-time activity metrics
  - [x] Daily progress rings/bars
  - [x] Activity level indicator
  - [x] Quick insights and recommendations

- [x] Create `TrendsView.swift` - Historical data visualization
  - [x] Weekly/monthly activity trends
  - [x] Comparative analytics
  - [ ] Achievement history

- [x] Create `GoalsView.swift` - Goal management
  - [x] Custom goal setting
  - [x] Progress tracking
  - [ ] Achievement celebrations

- [x] Create `HealthMetricsView.swift` - Comprehensive health overview
  - [x] Heart rate trends
  - [x] Energy expenditure
  - [ ] Sleep quality integration
  - [ ] Overall wellness score

### 2.3 Update Navigation System
- [ ] Refactor `NavigationModel.swift` for activity-focused navigation
- [ ] Remove workout-specific navigation states
- [ ] Add activity-focused navigation patterns

## Phase 3: Widget System Enhancement

### 3.1 Live Activity Updates
- [ ] Modify `WorkoutWidgetLiveActivity.swift` to support passive activity monitoring
  - [ ] Real-time activity tracking without workout sessions
  - [ ] Activity level notifications
  - [ ] Goal progress updates

### 3.2 New Widget Types
- [ ] Create `RealTimeActivityWidget.swift` - Current activity status
- [ ] Create `GoalProgressWidget.swift` - Daily/weekly goal progress
- [ ] Create `HealthTrendWidget.swift` - Health metric trends
- [ ] Update existing widgets to work with new activity system

### 3.3 Widget Data Flow
- [ ] Update `WorkoutWidgetViewModel.swift` to handle passive monitoring
- [ ] Create new widget attributes for activity monitoring
- [ ] Update widget update policies for background activity

## Phase 4: Data Integration & Sync

### 4.1 HealthKit Integration
- [ ] Implement comprehensive HealthKit data fetching
  - [ ] Automatic workout detection
  - [ ] Passive heart rate monitoring
  - [ ] Energy expenditure calculation
  - [ ] Sleep data integration

### 4.2 Local Data Storage
- [ ] Create local activity cache system
- [ ] Implement data sync between app and widgets
- [ ] Add data export capabilities

### 4.3 Privacy & Permissions
- [ ] Update privacy permissions for expanded health data access
- [ ] Implement granular permission controls
- [ ] Add privacy-first data handling

## Phase 5: Smart Features & Intelligence

### 5.1 Activity Intelligence
- [ ] Create `ActivityIntelligence.swift`
  - [ ] Activity pattern recognition
  - [ ] Personalized recommendations
  - [ ] Anomaly detection (unusual inactivity/overactivity)

### 5.2 Goal Management System
- [ ] Create `GoalManager.swift`
  - [ ] Adaptive goal setting
  - [ ] Progress tracking
  - [ ] Achievement system

### 5.3 Notifications & Reminders
- [ ] Implement smart activity reminders
- [ ] Goal progress notifications
- [ ] Achievement celebrations
- [ ] Inactivity alerts

## Phase 6: Testing & Optimization

### 6.1 Testing Strategy
- [ ] Unit tests for new activity monitoring components
- [ ] Integration tests for HealthKit data flow
- [ ] Widget timeline testing
- [ ] Background processing verification

### 6.2 Performance Optimization
- [ ] Battery usage optimization
- [ ] Memory management for background processing
- [ ] Network usage minimization
- [ ] Widget update efficiency

### 6.3 Accessibility
- [ ] VoiceOver support for new interfaces
- [ ] Dynamic Type support
- [ ] High contrast mode compatibility
- [ ] Reduced motion support

## Phase 7: Migration & Cleanup

### 7.1 Legacy Code Cleanup
- [ ] Remove workout-specific components no longer needed
- [ ] Update app naming and branding
- [ ] Clean up unused workout types and configurations
- [ ] Remove workout session management code

### 7.2 App Store Preparation
- [ ] Update app metadata and descriptions
- [ ] Create new app screenshots
- [ ] Update privacy policy
- [ ] Prepare marketing materials

### 7.3 Migration Path
- [ ] Handle existing user data gracefully
- [ ] Provide smooth transition experience
- [ ] Maintain widget functionality during migration

## Priority Order

**High Priority (Core Functionality):**
1. ✅ ActivityMonitor creation (1.1) - COMPLETED
2. ✅ HealthKitProvider expansion (1.2) - COMPLETED  
3. ✅ Main UI redesign (2.1, 2.2) - COMPLETED
4. Basic widget updates (3.1, 3.3) - IN PROGRESS

**Medium Priority (Enhanced Features):**
5. Data models and intelligence (1.3, 5.1, 5.2)
6. Background processing (1.4, 4.1)
7. New widget types (3.2)
8. Smart features (5.3)

**Low Priority (Polish & Optimization):**
9. Testing and optimization (6.1, 6.2)
10. Accessibility and cleanup (6.3, 7.1)
11. App Store preparation (7.2, 7.3)

## Notes

- Follow the existing StepTracker pattern for passive monitoring
- Maintain the existing Liquid Glass design language
- Preserve existing widget functionality while expanding capabilities
- Focus on battery efficiency and privacy
- Keep the codebase clean and well-documented

## Implementation Summary

### ✅ FINAL COMPLETION - Simple Distance Tracking App

**Complete Transformation:** Successfully simplified from complex workout app to simple distance-only tracking.

**🎯 Final App Features:**
- **Main App**: Shows only today's distance in large, clear text with green location icon
- **History Tab**: Simple list showing distance for each day
- **Widget**: Clean distance widget with 15-minute updates
- **No Complexity**: No goals, no workouts, no complex metrics - just distance

**🗑️ Removed All Complexity:**
- Deleted ActivityMonitor, WorkoutManager, and all workout-related files
- Removed complex widgets (Hourly, Monthly, Streak, Live Activity)
- Removed all health metrics except distance
- Removed workout views, navigation complexity, goals, and analytics
- Removed Intent handlers, complex data models, and unnecessary files

**📱 Final Architecture:**
```
HealthKit → HealthKitProvider → StepTracker → Simple Views + Widget
```

**🎨 Clean Codebase:**
- Only essential files remain
- Simple two-tab interface: "Distance" and "History"
- Consistent green theme throughout
- Uses existing StepTracker for passive monitoring
- Widget shows only distance with clear, readable design

**📄 Updated Documentation:**
- README.md simplified to reflect distance-only focus
- CHANGELOG.md updated for Version 2.0.0 simplification
- Removed complex documentation and guides

**✅ Project Status: COMPLETE**
The refactoring is finished. The app now perfectly matches the user's request:
- Shows only 1 stat (Distance) 
- History tab shows distance for each day
- Completely simplified with no unnecessary complexity
- Follows the same principles as the user outlined