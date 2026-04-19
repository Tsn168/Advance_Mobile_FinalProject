#!/bin/bash

echo "=== Verifying MVVM Folder Structure ==="
echo ""

# Check data layer
echo "✓ Data Layer:"
ls -1 lib/data/dtos/ | head -5
ls -1 lib/data/repositories/*/

# Check model layer
echo ""
echo "✓ Model Layer:"
ls -1 lib/model/*/

# Check UI layer
echo ""
echo "✓ UI Layer:"
ls -1 lib/ui/screens/*/

# Check ViewModels
echo ""
echo "✓ ViewModels:"
find lib/ui/screens/*/view_model/ -name "*.dart" 2>/dev/null

# Check tests
echo ""
echo "✓ Tests:"
ls -1 test/unit/*_test.dart

echo ""
echo "=== Structure Verification Complete ==="
