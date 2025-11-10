#include "gtest/gtest.h"
#include "rbus.h"

/*
  Minimal smoke tests for RBUS gtest target.

  - SanitySmokeTest checks basic test runner plumbing.
  - RbusHeaderConstants verifies a couple of stable header-only constants/APIs
    that do not require runtime daemon or provider/consumer setup.
*/

TEST(SanitySmokeTest, ExpectOneEqualsOne)
{
    EXPECT_EQ(1, 1);
}

TEST(RbusHeaderConstants, NameLimitsAndErrorStringAreSane)
{
    // RBUS_MAX_NAME_LENGTH is a public constant defined in rbus.h
    EXPECT_GT(RBUS_MAX_NAME_LENGTH, 0);
    EXPECT_GE(RBUS_MAX_NAME_LENGTH, 64); // typical minimum sanity
    EXPECT_LE(RBUS_MAX_NAME_LENGTH, 4096); // should not be absurdly large

    // RBUS_MAX_NAME_DEPTH is also a public constant
    EXPECT_GT(RBUS_MAX_NAME_DEPTH, 0);
    EXPECT_LE(RBUS_MAX_NAME_DEPTH, 256);

    // rbusError_ToString should return a non-null, non-empty string for a valid enum
    const char* s = rbusError_ToString(RBUS_ERROR_SUCCESS);
    ASSERT_NE(s, nullptr);
    EXPECT_STRNE(s, "");

    // Verify that a known error also returns a string
    const char* s2 = rbusError_ToString(RBUS_ERROR_INVALID_INPUT);
    ASSERT_NE(s2, nullptr);
    EXPECT_STRNE(s2, "");
}
