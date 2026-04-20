# 🚴 Bike Widgets - Quick Usage Guide

## 🚀 Quick Start

### Import All Widgets
```dart
import 'package:advance_mobile/widgets/widgets.dart';
```

### Or Import Specific Widgets
```dart
import 'package:advance_mobile/widgets/bike/bike_card.dart';
import 'package:advance_mobile/widgets/common/custom_button.dart';
```

---

## 📝 Common Widget Examples

### CustomButton
```dart
// Basic Button
CustomButton(
  label: 'Book Now',
  onPressed: () {
    print('Button pressed!');
  },
)

// Button with Icon
CustomButton(
  label: 'Book Bike',
  icon: Icons.directions_bike,
  onPressed: () => bookBike(),
  backgroundColor: AppColors.primary,
)

// Loading State
CustomButton(
  label: 'Processing...',
  isLoading: true,
  onPressed: null,
)

// Disabled State
CustomButton(
  label: 'Unavailable',
  isEnabled: false,
  onPressed: null,
  backgroundColor: AppColors.grey400,
)
```

### CustomCard
```dart
// Basic Card
CustomCard(
  child: Column(
    children: [
      Text('Card Content'),
    ],
  ),
)

// Card with Tap Action
CustomCard(
  child: Text('Tap me'),
  onTap: () => print('Card tapped!'),
)

// Card with Custom Border
CustomCard(
  child: Text('Bordered Card'),
  border: Border.all(color: AppColors.primary, width: 2),
)
```

---

## 🚲 Bike Widget Examples

### BikeCard
```dart
// Display Available Bike
BikeCard(
  slotNumber: 1,
  bikeModel: 'Mountain Bike Pro',
  condition: 'Good',
  isAvailable: true,
  batteryLevel: 85.0,
  onBook: () {
    print('Booking bike from slot 1');
    // Navigate to booking screen
  },
)

// Display Booked Bike
BikeCard(
  slotNumber: 5,
  bikeModel: 'City Bike',
  condition: 'Fair',
  isAvailable: false,
  onBook: () {}, // Won't be called
)

// Without Battery Level
BikeCard(
  slotNumber: 3,
  bikeModel: 'Road Bike',
  condition: 'Excellent',
  isAvailable: true,
  onBook: () => bookBike(),
)
```

### BikeSlotIndicator
```dart
// Available Slot
BikeSlotIndicator(
  slotNumber: 1,
  isOccupied: false,
  onTap: () {
    setState(() {
      selectedSlot = 1;
    });
  },
)

// Occupied Slot
BikeSlotIndicator(
  slotNumber: 2,
  isOccupied: true,
  onTap: () {},
)

// Selected Slot
BikeSlotIndicator(
  slotNumber: 1,
  isOccupied: false,
  isSelected: true,
  onTap: () {},
)

// Maintenance Slot
BikeSlotIndicator(
  slotNumber: 5,
  isOccupied: false,
  isMaintenanceMode: true,
  onTap: () {},
)
```

### BikeStatusWidget
```dart
// Available Bike with Full Details
BikeStatusWidget(
  bikeId: 1,
  status: BikeStatus.available,
  batteryLevel: 85.0,
  lastMaintenanceDate: DateTime(2024, 4, 15),
  nextMaintenanceDate: DateTime(2024, 5, 15),
  showDetails: true,
)

// Booked Bike
BikeStatusWidget(
  bikeId: 2,
  status: BikeStatus.booked,
)

// Bike in Maintenance
BikeStatusWidget(
  bikeId: 3,
  status: BikeStatus.maintenance,
  lastMaintenanceDate: DateTime(2024, 4, 20),
  showDetails: true,
)

// Bike Charging
BikeStatusWidget(
  bikeId: 4,
  status: BikeStatus.charging,
  batteryLevel: 45.0,
  showDetails: false,
)
```

---

## 📊 Widget in GridView (BikeSlotIndicator)

```dart
GridView.count(
  crossAxisCount: 4,
  children: List.generate(20, (index) {
    int slotNumber = index + 1;
    bool isOccupied = occupiedSlots.contains(slotNumber);
    bool isSelected = selectedSlot == slotNumber;
    
    return BikeSlotIndicator(
      slotNumber: slotNumber,
      isOccupied: isOccupied,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          selectedSlot = slotNumber;
        });
      },
    );
  }),
)
```

---

## 📋 Widget in ListView (BikeCard)

```dart
ListView.builder(
  itemCount: bikes.length,
  itemBuilder: (context, index) {
    final bike = bikes[index];
    return BikeCard(
      slotNumber: bike.slotNumber,
      bikeModel: bike.model,
      condition: bike.condition,
      isAvailable: bike.isAvailable,
      batteryLevel: bike.batteryLevel,
      onBook: () => bookBike(bike.id),
    );
  },
)
```

---

## 🎨 Theming & Customization

### Using Theme Colors
```dart
CustomButton(
  label: 'Success',
  backgroundColor: AppColors.success,
)

CustomButton(
  label: 'Warning',
  backgroundColor: AppColors.warning,
)

CustomButton(
  label: 'Error',
  backgroundColor: AppColors.error,
)
```

### Custom Spacing
```dart
CustomCard(
  padding: const EdgeInsets.all(AppSpacing.xl), // 20px
)

CustomCard(
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.lg, // 16px
    vertical: AppSpacing.md,   // 12px
  ),
)
```

---

## 🔍 Status Indicators

### BikeSlotIndicator Status Colors
- 🟢 **Green** - Available slot
- 🔴 **Red** - Occupied slot
- 🟠 **Orange** - Maintenance
- 🔵 **Blue** - Selected

### BikeStatusWidget Status Colors
- 🟢 **Green** - Available bike
- 🔴 **Red** - Booked bike
- 🟠 **Orange** - Maintenance
- 🔵 **Blue** - Charging

---

## 💡 Pro Tips

1. **Always use theme constants** - Don't hardcode colors or sizes
2. **Handle loading states** - Use `isLoading` on CustomButton
3. **Provide feedback** - Use callbacks for user interactions
4. **Optimize lists** - Use `const` constructors when possible
5. **Responsive design** - Test on multiple screen sizes

---

## ✅ Checklist

- [ ] Import widgets from `package:advance_mobile/widgets/widgets.dart`
- [ ] Use appropriate widget for your UI needs
- [ ] Pass required parameters
- [ ] Handle callbacks appropriately
- [ ] Test on different screen sizes
- [ ] Use theme colors and spacing
- [ ] Add error handling for async operations

---

**Ready to use in your app! 🎉**
