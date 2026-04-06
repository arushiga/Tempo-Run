# Tempo SwiftUI Migration Plan

## Purpose

This document turns the current React/Tailwind web prototype into a practical SwiftUI implementation plan for Assignment 5.

The goal is not to fully rebuild the production app immediately. The goal is to deliver the smallest native iOS prototypes that prove the required technical requirements are feasible.

## Current Evaluation

The Figma web application code is a good reference source for:

- screen layout
- navigation flow
- styling direction
- interaction behavior
- mock data shape

It should not be treated as code to translate line-by-line.

The strongest parts of the web app for SwiftUI conversion are:

- `Login`
- `SignUp`
- `Calendar` / `RunPlanner`
- `Profile`
- `Home`

The weakest part for direct reuse is the generic web UI layer in `src/app/components/ui/*`. Those files are mostly web-specific and should not be ported one-for-one.

## Assignment-Driven Scope

Based on [README.md](/Users/ericchen/Code/Tempo/Tempo/Tempo/README.md), the prototypes should prove:

1. Hello World
2. Hello Styles
3. Login / signup flow
4. Firestore-backed data rendering
5. Weekly planner drag and drop
6. Optional map/location feature only if time allows

For Assignment 5, the correct strategy is to prioritize technical risk, not feature completeness.

## Recommended Prototype Set

### Required and already started

1. `HelloWorldView`
2. `HelloStylesView`

### Required next prototypes

3. Auth prototype
- Sign up form
- Login form
- Firebase Auth integration
- Minimal user record creation in Firestore

4. Profile rendering prototype
- Fetch one user profile from Firestore
- Render friends/connections
- Render past runs grouped by date
- Render progress bars for training plans

5. Planner interaction prototype
- Weekly grid
- One draggable workout item per cell
- Drag from palette to planner
- Move existing item between cells
- Remove item
- Show intensity/type visually

### Optional prototype

6. Activity/Map prototype
- Record button entry point
- MapKit route preview
- Core Location permission flow

## Screen Inventory From Web App

Web routes currently defined in `Figma Web Application Code/src/app/routes.tsx`:

- `/login`
- `/signup`
- `/`
- `/calendar`
- `/record`
- `/activity`
- `/profile`

Suggested SwiftUI equivalents:

- `LoginView`
- `SignUpView`
- `HomeView`
- `PlannerView`
- `RecordView`
- `ActivityView`
- `ProfileView`

## SwiftUI Folder Mapping

Use the existing iOS structure like this:

### `App/`

- `TempoApp.swift`
- `RootTabView.swift`
- `AppContainerView.swift`

### `Core/Theme/`

- `TempoColor.swift`
- `TempoTypography.swift`
- `TempoSpacing.swift`
- `TempoGradients.swift`

### `Core/Components/`

- `GlassCard.swift`
- `PrimaryButton.swift`
- `SecondaryButton.swift`
- `TempoTextField.swift`
- `StatCard.swift`
- `ProgressMetricRow.swift`
- `BottomTabBar.swift` if needed

### `Core/Models/`

- `UserProfile.swift`
- `FriendConnection.swift`
- `PastRun.swift`
- `TrainingPlan.swift`
- `RunType.swift`
- `ScheduledRun.swift`

### `Core/Navigation/`

- `AppRoute.swift`
- `AuthFlow.swift`
- `MainTab.swift`

### `Features/Auth/`

- `LoginView.swift`
- `SignUpView.swift`
- `AuthViewModel.swift`

### `Features/Home/`

- `HomeView.swift`

### `Features/Planner/`

- `PlannerView.swift`
- `PlannerGridView.swift`
- `PlannerCellView.swift`
- `RunTypePickerView.swift`
- `PlannerStatsView.swift`
- `PlannerViewModel.swift`

### `Features/Profile/`

- `ProfileView.swift`
- `ProfileHeaderView.swift`
- `GoalCard.swift`
- `AchievementBadge.swift`
- `ProfileViewModel.swift`

### `Features/Activity/`

- `ActivityView.swift`
- `RunMapView.swift`

### `Features/Hello/`

- `HelloWorldView.swift`
- `HelloStylesView.swift`

### `Services/`

- `AuthService.swift`
- `FirestoreService.swift`
- `ProfileRepository.swift`
- `PlannerRepository.swift`

### `Resources/`

- assets
- app icons

## What To Port Directly vs Adapt

### Port conceptually

- screen hierarchy
- visual composition
- button labels
- card groupings
- data groupings
- planner interaction rules

### Adapt natively

- React Router -> `NavigationStack`, `TabView`, flow state
- Tailwind classes -> shared SwiftUI modifiers/theme tokens
- React state -> `@State`, `@Observable`, `@StateObject`
- React DnD -> SwiftUI `draggable` and `dropDestination`
- web inputs -> SwiftUI `TextField`, `SecureField`, toggle controls

### Do not port literally

- `components/ui/*`
- browser event assumptions
- DOM-based layout hacks
- CSS utility class structure

## Build Order

### Phase 1: Foundation

1. Create theme tokens from web styles
2. Build shared glass card and button components
3. Set up root app shell and navigation

### Phase 2: Auth

4. Build `LoginView`
5. Build `SignUpView`
6. Add Firebase Auth integration
7. Store minimal profile document in Firestore

### Phase 3: Planner

8. Create `RunType` and `ScheduledRun` models
9. Build planner grid
10. Add drag/drop behavior
11. Add planner stats cards
12. Use mock data first, then optionally persist

### Phase 4: Profile

13. Build profile screen with mock sections
14. Replace mock data with Firestore reads
15. Group past runs by date
16. Render training progress bars

### Phase 5: Home and polish

17. Build home dashboard as lightweight shell
18. Hook navigation into planner/profile/auth
19. Add optional activity/map prototype if still needed

## Minimal Success Criteria Per Prototype

### Auth

Success means:

- user can enter email/password
- sign up action succeeds or is convincingly stubbed
- login action succeeds or is convincingly stubbed
- one Firestore user record exists or is simulated identically

### Profile

Success means:

- profile view renders dynamic-looking user data
- friends and past runs appear from a model/service layer
- historical training plan progress bars are visible

### Planner

Success means:

- workout types are draggable
- each cell accepts at most one workout
- dropping replaces an existing cell workout
- moving and removing items work
- visual state reflects workout type and intensity

## Risks and Notes

### Good risk to tackle early

- Firebase setup
- drag and drop behavior
- Firestore data modeling

### Scope risks

- trying to build every screen before shared theme/components exist
- trying to port all web UI utility components
- trying to fully implement backend logic before the prototype screens exist

### Recommendation

Mock first where allowed, but keep the interfaces shaped like real services so Firebase can replace mocks cleanly.

## Team Work Split

Recommended parallelization:

### Person 1

- theme
- shared components
- app shell/navigation

### Person 2

- auth screens
- Firebase Auth setup

### Person 3

- planner interaction
- run models

### Person 4

- profile rendering
- Firestore reads

## Immediate Next Step

The next implementation task should be:

1. Extract the core design system from the web app into `Core/Theme` and `Core/Components`
2. Create a real app shell with tabs for `Home`, `Planner`, and `Profile`
3. Start the Auth prototype

Do not start by porting every web screen at once.
