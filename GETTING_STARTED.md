# Getting Started Guide: FB2K-Chinese Component

## Overview

You now have a complete specification, implementation plan, and test-driven development framework for a foobar2000 Chinese character conversion component. This guide will help you start development.

## What You Have

### 📋 Documentation
- **SPECIFICATION.md** - Complete feature specification and requirements
- **IMPLEMENTATION_PLAN.md** - 7-phase roadmap with TDD approach
- **README.md** - User and developer documentation
- **PROJECT_SUMMARY.md** - Overview of what's been created
- **GETTING_STARTED.md** - This file

### 🏗️ Project Structure
- Complete folder hierarchy with include/, src/, tests/, res/ directories
- CMakeLists.txt configured for x86/x64 builds
- Test scaffold with 17 test cases ready to implement

### 🧪 Test Suite (TDD Ready)
- test_encoding.cpp - 7 tests for encoding handling
- test_converter.cpp - 6 tests for Chinese conversion
- test_tag_processor.cpp - 2 tests for metadata operations
- test_integration.cpp - 2 integration tests

### 📝 Header Files with Full Documentation
- encoding.h - EncodingHandler interface
- converter.h - ChineseConverter interface
- tag_processor.h - TagProcessor interface
- component.h - Component metadata

## Quick Start

### 1. Set Up Development Environment

```powershell
# Install prerequisites
# Visual Studio 2019+ or Build Tools
# CMake 3.15+
# foobar2000 SDK v2.1+

# Verify installations
cmake --version
```

### 2. Download Required Libraries

```powershell
# OpenCC (Chinese conversion library)
# https://github.com/BYVoid/OpenCC
# Extract to: fb2k_component/external/opencc

# iconv (Encoding conversion)
# On Windows, available via Visual Studio or vcpkg:
# vcpkg install libiconv:x64-windows
```

### 3. Configure CMakeLists.txt

Update `fb2k_component/CMakeLists.txt` to point to your dependencies:

```cmake
# Uncomment and adjust paths:
# find_package(OpenCC REQUIRED)
# find_package(Iconv REQUIRED)

# Or add manual paths:
# target_include_directories(fb2k_chinese_component PRIVATE
#     "path/to/opencc/include"
#     "path/to/iconv/include"
# )

# target_link_libraries(fb2k_chinese_component PRIVATE
#     "path/to/opencc/lib/libopencc.lib"
#     "path/to/iconv/lib/iconv.lib"
# )
```

### 4. Build and Run Tests

```powershell
cd fb2k_component

# Build (Debug mode for development)
.\build.ps1 -Configuration Debug -Platform x64

# Build and run tests
.\build.ps1 -Configuration Debug -Platform x64 -Test

# Clean build
.\build.ps1 -Clean
```

## Development Workflow (TDD)

Follow this workflow for each feature:

### Phase 1️⃣: Red - Write Failing Tests

```cpp
// Example: test_encoding.cpp
void test_convert_gb2312_to_utf8() {
    std::cout << "Test: convert_gb2312_to_utf8... ";
    
    EncodingHandler handler;
    std::string gb2312_text = /* GB2312 encoded bytes */;
    
    std::string result = handler.to_utf8(gb2312_text, Encoding::GB2312);
    
    assert(!result.empty());  // Failing: returns empty
    assert(result == expected_utf8); // Failing: stub returns input
    
    std::cout << "PASS\n";
}
```

Run test - it will **FAIL** ❌

### Phase 2️⃣: Green - Write Minimum Code

```cpp
// encoding.cpp
std::string EncodingHandler::to_utf8(const std::string& text, Encoding from) const {
    if (text.empty()) {
        return "";
    }
    
    if (from == Encoding::UTF8) {
        return text;
    }
    
    // Minimum implementation to pass test
    // TODO: Implement with iconv
    return text;  // Placeholder
}
```

Run test - it will **PASS** ✅

### Phase 3️⃣: Refactor - Improve Implementation

```cpp
// encoding.cpp - Proper implementation
std::string EncodingHandler::to_utf8(const std::string& text, Encoding from) const {
    if (text.empty()) {
        return "";
    }
    
    if (from == Encoding::UTF8) {
        return text;  // Already UTF-8
    }
    
    // Proper iconv implementation
    iconv_t cd = iconv_open("UTF-8", encoding_name(from));
    if (cd == (iconv_t)(-1)) {
        return text;  // Fallback on error
    }
    
    // ... full conversion logic ...
    
    iconv_close(cd);
    return result;
}
```

Run test - it **STILL PASSES** ✅ with better implementation

## Implementation Roadmap

### Phase 2: Core Engine (Start Here)

**Priority 1**: EncodingHandler
- File: `src/encoding.cpp`
- Tests: `tests/test_encoding.cpp` (7 tests)
- Dependencies: iconv library
- Goal: Pass all 7 encoding tests

```
Tasks:
1. Implement encoding detection (GB2312, BIG5, UTF-8)
2. Implement to_utf8() conversion
3. Implement from_utf8() conversion
4. Implement auto-detection with scoring
```

**Priority 2**: ChineseConverter
- File: `src/converter.cpp`
- Tests: `tests/test_converter.cpp` (6 tests)
- Dependencies: OpenCC library
- Goal: Pass all 6 converter tests

```
Tasks:
1. Implement to_traditional() (SC→TC)
2. Implement to_simplified() (TC→SC)
3. Implement has_convertible_text()
4. Implement would_change()
5. Add character preservation logic
```

### Phase 3: Integration

**Priority 3**: TagProcessor
- File: `src/tag_processor.cpp`
- Tests: `tests/test_tag_processor.cpp` (2 tests)
- Dependencies: foobar2000 SDK
- Goal: Pass all tag processor tests

**Priority 4**: Integration Tests
- Tests: `tests/test_integration.cpp` (2 tests)
- Goal: Encoding + Converter + TagProcessor work together

## Testing Command Reference

```powershell
# Build only
cmake --build build --config Debug

# Run all tests with verbose output
cd build
ctest --verbose

# Run specific test executable
.\Debug\fb2k_chinese_test.exe

# Run with output on failure
ctest --output-on-failure
```

## Code Structure Reference

### Adding a New Test

1. Edit appropriate test file (tests/test_*.cpp)
2. Add test function:
```cpp
void test_my_feature() {
    std::cout << "Test: my_feature... ";
    
    // Arrange
    MyClass obj;
    
    // Act
    auto result = obj.do_something();
    
    // Assert
    assert(result == expected);
    
    std::cout << "PASS\n";
}
```
3. Call from main():
```cpp
int main() {
    try {
        test_my_feature();
        // ... more tests ...
    }
    catch (const std::exception& e) {
        std::cerr << "TEST FAILED: " << e.what() << "\n";
        return 1;
    }
}
```
4. Run `.\build.ps1 -Configuration Debug -Platform x64 -Test`

### Adding a New Implementation

1. Declare in header (include/*.h):
```cpp
class MyClass {
    std::string my_method(const std::string& input) const;
};
```

2. Implement in source (src/*.cpp):
```cpp
std::string MyClass::my_method(const std::string& input) const {
    // Implementation
}
```

3. Write tests first (tests/test_*.cpp)
4. Run tests - they fail initially
5. Improve implementation until tests pass
6. Refactor as needed

## Common Tasks

### Debugging Tests

```powershell
# Build in Debug mode with symbols
.\build.ps1 -Configuration Debug -Platform x64

# Run single test with debugger
# Then attach Visual Studio to process or use:
cd build
.\Debug\fb2k_chinese_test.exe
```

### Building Release Version

```powershell
# Optimized build
.\build.ps1 -Configuration Release -Platform x64

# Create component package
# (To be implemented in Phase 7)
```

### Cross-Platform Build

```powershell
# Build for x86
.\build.ps1 -Configuration Release -Platform x86

# Build for x64
.\build.ps1 -Configuration Release -Platform x64
```

## Progress Tracking

### Phase Completion Checklist

**Phase 2: Core Engine**
- [ ] EncodingHandler: All 7 tests passing
- [ ] ChineseConverter: All 6 tests passing
- [ ] Integration tests: All 2 tests passing
- [ ] Code coverage: >80%
- [ ] Documentation updated

**Phase 3: foobar2000 Integration**
- [ ] TagProcessor: All 2 tests passing
- [ ] ConversionService implemented
- [ ] Component entry point functional
- [ ] Loads in foobar2000 v2.1.X

**Phase 4-7**
- [ ] See IMPLEMENTATION_PLAN.md for details

## Getting Help

### If You're Stuck

1. **Check the test**: Read what the test expects
2. **Stub the interface**: Just return empty/default values
3. **Run the test**: See what fails
4. **Implement minimum**: Write just enough to pass
5. **Check examples**: Look at similar tests for patterns

### Key Files to Reference

- `SPECIFICATION.md` - What the component should do
- `IMPLEMENTATION_PLAN.md` - How to build it
- `include/*.h` - Interface contracts
- `tests/test_*.cpp` - Expected behavior

## Next Steps

1. ✅ Read SPECIFICATION.md to understand requirements
2. ✅ Read IMPLEMENTATION_PLAN.md to understand phases
3. ⏳ Set up foobar2000 SDK and libraries
4. ⏳ Update CMakeLists.txt with library paths
5. ⏳ Run: `.\build.ps1 -Configuration Debug -Platform x64 -Test`
6. ⏳ Start with EncodingHandler implementation (Phase 2, Priority 1)

## Contact & Support

For issues or questions:
- Review relevant documentation files
- Check test cases for expected behavior
- Examine header files for interface contracts

---

**Happy coding! 🚀**

Remember: **Tests First** → **Red-Green-Refactor** → **Commit**

Current Status: Phase 1 ✅ - Foundation Complete
Next Phase: Phase 2 ⏳ - Core Engine Implementation
