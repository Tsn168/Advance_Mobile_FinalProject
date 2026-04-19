# MVVM Architecture Diagram

## Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
│                        (lib/ui/)                             │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐         ┌──────────────┐                  │
│  │   Screen     │ watches │  ViewModel   │                  │
│  │   (View)     │◄────────│ (ChangeNotifier)                │
│  └──────────────┘         └──────┬───────┘                  │
│       │                           │                          │
│       │ User Action              │ Business Logic           │
│       └──────────►                │                          │
│                                   │                          │
└───────────────────────────────────┼──────────────────────────┘
                                    │
                                    │ calls
                                    ▼
┌─────────────────────────────────────────────────────────────┐
│                        DATA LAYER                            │
│                      (lib/data/)                             │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │   Repository     │         │   Repository     │          │
│  │   Interface      │◄────────│   Mock/Firebase  │          │
│  └────────┬─────────┘         └──────────────────┘          │
│           │                                                   │
│           │ returns Domain Model                             │
│           │                                                   │
│  ┌────────▼─────────┐                                        │
│  │      DTO         │                                        │
│  │ (Data Transfer)  │                                        │
│  └──────────────────┘                                        │
│                                                               │
└───────────────────────────────────┬─────────────────────────┘
                                    │
                                    │ converts to
                                    ▼
┌─────────────────────────────────────────────────────────────┐
│                       DOMAIN LAYER                           │
│                      (lib/model/)                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Bike   │  │ Booking  │  │   Pass   │  │ Station  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│                                                               │
│           Pure Dart Business Entities                        │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Detailed Flow: User Books a Bike

```
1. USER INTERACTION → User taps "Book Bike"
                ↓
2. VIEW (MapScreen) → Displays bike list, handles input
                ↓
3. VIEWMODEL (BookingViewModel) → Validates, manages state
                ↓
4. REPOSITORY INTERFACE → Defines contract
                ↓
5. REPOSITORY IMPLEMENTATION → Saves data
                ↓
6. DOMAIN MODEL (Booking) → Returns entity
                ↓
7. VIEWMODEL → Updates state, notifyListeners()
                ↓
8. VIEW → UI rebuilds, shows success
```

## Folder Structure Mapping

```
lib/ui/screens/map/map_screen.dart ──────────► VIEW
lib/ui/screens/map/view_model/map_viewmodel.dart ──► VIEWMODEL
lib/data/repositories/booking/booking_repository.dart ──► INTERFACE
lib/data/repositories/booking/booking_repository_mock.dart ──► IMPLEMENTATION
lib/model/booking/booking.dart ──────────────► DOMAIN MODEL
```
