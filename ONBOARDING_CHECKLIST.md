# Developer Onboarding Checklist

**Project**: FB2K-Chinese - foobar2000 Chinese Character Conversion Component  
**Phase**: 1 ✅ Complete → 2 ⏳ Ready to Start  
**Last Updated**: November 4, 2025

---

## 📖 Pre-Implementation (1-2 hours)

### Read Documentation
- [ ] Read SPECIFICATION.md (focus on section 2 - Requirements)
- [ ] Read IMPLEMENTATION_PLAN.md (understand Phase 2 tasks)
- [ ] Read GETTING_STARTED.md (setup instructions)
- [ ] Skim QUICK_REFERENCE.md (bookmark for quick lookup)
- [ ] Review .github/copilot-instructions.md (understand architecture)

### Understand Project Structure
- [ ] Explore fb2k_component/include/ (4 header files)
- [ ] Explore fb2k_component/src/ (4 implementation files)
- [ ] Explore fb2k_component/tests/ (4 test files with 17 tests)
- [ ] Review CMakeLists.txt (build configuration)
- [ ] Review build.ps1 (build script)

### Key Files to Bookmark
1. SPECIFICATION.md - Reference for requirements
2. IMPLEMENTATION_PLAN.md - Reference for tasks
3. QUICK_REFERENCE.md - For quick lookups
4. .github/copilot-instructions.md - For AI assistance

---

## 🔧 Environment Setup (30 minutes)

### Install Prerequisites
- [ ] Visual Studio 2019+ or Visual C++ Build Tools
- [ ] CMake 3.15+
- [ ] Git (for version control)
- [ ] PowerShell 5.1+ (usually pre-installed)

### Download External Libraries
- [ ] Download OpenCC (Chinese conversion library)
  - Source: https://github.com/BYVoid/OpenCC
  - Extract to: fb2k_component/external/opencc (or note install path)
  
- [ ] Download iconv (Encoding conversion library)
  - Option 1: vcpkg install libiconv:x64-windows
  - Option 2: Already installed on Windows (usually)
  - Note: Installation path for CMakeLists.txt

- [ ] Download foobar2000 SDK v2.1+
  - Source: https://www.foobar2000.org/SDK
  - Note: Not needed until Phase 3

### Verify Installation
- [ ] Run: `cmake --version`
- [ ] Run: `git --version`
- [ ] Check: OpenCC library path noted
- [ ] Check: iconv library path noted

---

## 🏗️ Build Verification (15 minutes)

### Initial Build
- [ ] Open PowerShell in fb2k_component directory
- [ ] Run: `mkdir build` (create build directory)
- [ ] Run: `cd build`
- [ ] Run: `cmake .. -G "Visual Studio 16 2019" -A x64`
- [ ] Run: `cd ..`
- [ ] Run: `.\build.ps1 -Configuration Debug -Platform x64`

### Verify Test Infrastructure
- [ ] Check for successful build output
- [ ] Check build/ directory was created
- [ ] Verify test executable exists (fb2k_chinese_test.exe)
- [ ] Run: `.\build.ps1 -Configuration Debug -Platform x64 -Test`
- [ ] Verify tests can run (even if some fail)

### Clean Up
- [ ] Run: `.\build.ps1 -Clean` to reset
- [ ] Verify build/ directory removed

---

## 📝 Understanding Architecture (30 minutes)

### Read Code Interfaces
- [ ] Read include/encoding.h completely
- [ ] Read include/converter.h completely
- [ ] Read include/tag_processor.h completely
- [ ] Read include/component.h completely

### Understand Data Flow
- [ ] Study the encoding flow: GB2312/BIG5 → UTF-8
- [ ] Study the conversion flow: SC ↔ TC
- [ ] Study the tag flow: read → convert → write
- [ ] Review SPECIFICATION.md section 4.2 (Key Classes)

### Review Test Patterns
- [ ] Open tests/test_encoding.cpp
- [ ] Understand test structure (Arrange-Act-Assert)
- [ ] Review test data definitions
- [ ] Open tests/test_converter.cpp
- [ ] Compare test patterns

---

## 🎯 Phase 2 Preparation (1 hour)

### Understand Phase 2 Tasks
- [ ] Read IMPLEMENTATION_PLAN.md Phase 2 section
- [ ] Identify Task 2.1: EncodingHandler (priority 1)
- [ ] Identify Task 2.2: ChineseConverter (priority 2)
- [ ] Identify Task 2.3: Integration tests
- [ ] Note: 7 tests for EncodingHandler
- [ ] Note: 6 tests for ChineseConverter

### Prepare Development Environment
- [ ] Update CMakeLists.txt with OpenCC path (if needed)
- [ ] Update CMakeLists.txt with iconv path (if needed)
- [ ] Verify clean build still works
- [ ] Create working branch: `git checkout -b phase2-core-engine`

### Plan First Task
- [ ] Task: Implement EncodingHandler
- [ ] File: src/encoding.cpp
- [ ] Tests: 7 in tests/test_encoding.cpp
- [ ] Approach: TDD (tests first)
- [ ] Priority: Detect UTF-8, GB2312, BIG5

---

## ✅ Ready to Develop Checklist

### Environment Ready?
- [ ] CMake installed and working
- [ ] Visual Studio or build tools available
- [ ] OpenCC library available
- [ ] iconv library available
- [ ] Build script runs successfully

### Knowledge Ready?
- [ ] Understand Phase 2 focus (EncodingHandler)
- [ ] Familiar with test pattern (Arrange-Act-Assert)
- [ ] Know which tests to work on
- [ ] Understand TDD workflow (Red-Green-Refactor)
- [ ] Know success criteria (pass all tests)

### Code Ready?
- [ ] Current branch: phase2-core-engine (or similar)
- [ ] Clean build verified
- [ ] Test executable builds successfully
- [ ] Ready to implement first test

---

## 🚀 First Development Task

### Task: Implement EncodingHandler::detect_encoding()

**Step 1: Understand Current Tests**
```powershell
# Open tests/test_encoding.cpp
# Find: test_detect_utf8_encoding()
# Find: test_detect_gb2312_encoding()
```

**Step 2: Run Current Tests**
```powershell
# Current result: Some tests may pass (stubs)
.\build.ps1 -Configuration Debug -Platform x64 -Test
```

**Step 3: Plan Implementation**
- [ ] Read IMPLEMENTATION_PLAN.md Task 2.1 details
- [ ] Understand encoding detection heuristics
- [ ] Plan scoring algorithm (UTF-8, GB2312, BIG5)
- [ ] Review helper methods in encoding.h

**Step 4: Implement**
- [ ] Write detect_encoding() logic
- [ ] Implement scoring methods
- [ ] Handle edge cases (empty strings, ambiguous)
- [ ] Graceful fallback (default to UTF-8)

**Step 5: Test**
```powershell
# Build and test
.\build.ps1 -Configuration Debug -Platform x64 -Test

# Check if encoding detection tests pass
# Iterate until all 7 encoding tests pass
```

**Step 6: Commit**
```powershell
git add -A
git commit -m "Implement EncodingHandler encoding detection"
```

---

## 📞 Getting Help

### Questions About Requirements?
→ Check SPECIFICATION.md

### Questions About Architecture?
→ Check IMPLEMENTATION_PLAN.md or include/*.h

### Questions About Build?
→ Check GETTING_STARTED.md or run `.\build.ps1 -Help`

### Questions About Test Pattern?
→ Check tests/test_encoding.cpp (look for pattern)

### Questions About Next Steps?
→ Check IMPLEMENTATION_PLAN.md Phase 2

---

## 📊 Progress Tracking

### Phase 1 Status
- [x] Specification complete
- [x] Planning complete
- [x] Architecture designed
- [x] Tests written
- [x] Build system ready

### Phase 2 Status
- [ ] EncodingHandler implemented (7/7 tests passing)
- [ ] ChineseConverter implemented (6/6 tests passing)
- [ ] Integration tests passing (2/2 tests passing)
- [ ] Total Phase 2: 15/15 tests passing

### Phase 3+ Status
- [ ] TagProcessor implemented
- [ ] ConversionService implemented
- [ ] foobar2000 integration
- [ ] UI dialog
- [ ] Advanced features
- [ ] Testing & validation
- [ ] Packaging

---

## 🎓 Development Workflow Reminder

### For Each Feature (TDD Cycle):

1. **RED**: Write failing test
   ```cpp
   void test_feature() { 
       assert(expected_value == actual_value);
   }
   ```

2. **GREEN**: Write minimum code to pass
   ```cpp
   return expected_value;  // Stub
   ```

3. **REFACTOR**: Improve implementation
   ```cpp
   // Proper implementation with error handling
   ```

4. **VERIFY**: Test passes + all other tests still pass
   ```powershell
   .\build.ps1 -Test
   ```

5. **COMMIT**: Save changes
   ```powershell
   git add -A
   git commit -m "Feature: implementation details"
   ```

---

## 🎯 Success Metrics for Phase 2

By end of Phase 2, you should have:

- [x] 7/7 EncodingHandler tests passing
- [x] 6/6 ChineseConverter tests passing
- [x] 2/2 Integration tests passing
- [x] Build completing without errors
- [x] Code follows project conventions
- [x] All tests use TDD pattern
- [x] Graceful error handling in place
- [x] Thread-safety contracts maintained

---

## 📋 Onboarding Completion

When all items above are checked:

✅ You're ready to start Phase 2 implementation!

**Next Step**: Begin with EncodingHandler::detect_encoding()

**Time Estimate**: 1.5 weeks for Phase 2 (both modules)

**Support**: Reference documentation always available

---

## 🔗 Quick Links

| Resource | File | Time |
|----------|------|------|
| Requirements | SPECIFICATION.md | 30 min |
| Roadmap | IMPLEMENTATION_PLAN.md | 20 min |
| Setup | GETTING_STARTED.md | 15 min |
| Quick Lookup | QUICK_REFERENCE.md | 5 min |
| AI Guidance | .github/copilot-instructions.md | 10 min |

---

**Total Onboarding Time**: ~4-5 hours  
**Expected Start Date**: [Insert date]  
**Phase 2 Target Completion**: [Insert date + 1.5 weeks]

---

**Notes for Developer**:
- Save this checklist
- Mark items as you complete them
- Reference documentation as needed
- Use QUICK_REFERENCE.md for daily lookup
- Test early and often

---

**Good luck with Phase 2! 🚀**

*For questions, refer to GETTING_STARTED.md or .github/copilot-instructions.md*
