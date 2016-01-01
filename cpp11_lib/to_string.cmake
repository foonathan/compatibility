# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(to_string "#include <string>
                    int main()
                    {
                        std::to_string(5);
                        std::to_string(5ul);
                        std::to_string(5.0);
                    }" COMP_CPP11_FLAG)
comp_workaround(to_string
"#include <string>

#if !${COMP_PREFIX}HAS_TO_STRING
    #include <cfloat>
    #include <cstdio>
#endif

namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_TO_STRING
    using std::to_string;
#else
    inline std::string to_string(int value)
    {
        char buf[4 * sizeof(value)];
        std::sprintf(buf, \"%d\", value);
        return buf;
    }

    inline std::string to_string(long value)
    {
        char buf[4 * sizeof(value)];
        std::sprintf(buf, \"%ld\", value);
        return buf;
    }

    inline std::string to_string(long long value)
    {
        char buf[4 * sizeof(value)];
        std::sprintf(buf, \"%lld\", value);
        return buf;
    }

    inline std::string to_string(unsigned value)
    {
        char buf[4 * sizeof(value)];
        std::sprintf(buf, \"%u\", value);
        return buf;
    }

    inline std::string to_string(unsigned long value)
    {
        char buf[4 * sizeof(value)];
        std::sprintf(buf, \"%lu\", value);
        return buf;
    }

    inline std::string to_string(unsigned long long value)
    {
        char buf[4 * sizeof(value)];
        std::sprintf(buf, \"%llu\", value);
        return buf;
    }

    inline std::string to_string(float value)
    {
        char buf[FLT_MAX_10_EXP + 20];
        std::sprintf(buf, \"%f\", value);
        return buf;
    }

    inline std::string to_string(double value)
    {
        char buf[DBL_MAX_10_EXP + 20];
        std::sprintf(buf, \"%f\", value);
        return buf;
    }

    inline std::string to_string(long double value)
    {
        char buf[LDBL_MAX_10_EXP + 20];
        std::sprintf(buf, \"%Lf\", value);
        return buf;
    }
#endif
}" COMP_CPP98_FLAG)
comp_unit_test(to_string
"
#include <limits>

template <typename Int>
void test_integer()
{
    auto min = std::numeric_limits<Int>::min();
    auto max = std::numeric_limits<Int>::max();

    REQUIRE(${COMP_NAMESPACE}::to_string(Int(0)) == \"0\");
    REQUIRE(${COMP_NAMESPACE}::to_string(Int(1024)) == \"1024\");
    REQUIRE(${COMP_NAMESPACE}::to_string(Int(-10)) == \"-10\");

    REQUIRE(${COMP_NAMESPACE}::to_string(min) != \"\");
    REQUIRE(${COMP_NAMESPACE}::to_string(max) != \"\");
}

template <typename Int>
void test_unsigned_integer()
{
    auto max = std::numeric_limits<Int>::max();

    REQUIRE(${COMP_NAMESPACE}::to_string(Int(0)) == \"0\");
    REQUIRE(${COMP_NAMESPACE}::to_string(Int(1024)) == \"1024\");

    REQUIRE(${COMP_NAMESPACE}::to_string(max) != \"\");
}

template <typename Float>
void test_float()
{
    auto min = std::numeric_limits<Float>::min();
    auto max = std::numeric_limits<Float>::max();
    auto inf = std::numeric_limits<Float>::infinity();
    auto nan = std::numeric_limits<Float>::quiet_NaN();

    REQUIRE(${COMP_NAMESPACE}::to_string(Float(0)) == \"0.000000\");
    REQUIRE(${COMP_NAMESPACE}::to_string(Float(1024)) == \"1024.000000\");
    REQUIRE(${COMP_NAMESPACE}::to_string(Float(0.5)) == \"0.500000\");
    REQUIRE(${COMP_NAMESPACE}::to_string(Float(-0.5)) == \"-0.500000\");
    REQUIRE(${COMP_NAMESPACE}::to_string(Float(-10)) == \"-10.000000\");

    auto inf_str = ${COMP_NAMESPACE}::to_string(inf);
    REQUIRE(inf_str.size() >= 3);
    REQUIRE(inf_str[0] == 'i');
    REQUIRE(inf_str[1] == 'n');
    REQUIRE(inf_str[2] == 'f');

    inf_str = ${COMP_NAMESPACE}::to_string(-inf);
    REQUIRE(inf_str.size() >= 4);
    REQUIRE(inf_str[0] == '-');
    REQUIRE(inf_str[1] == 'i');
    REQUIRE(inf_str[2] == 'n');
    REQUIRE(inf_str[3] == 'f');

    auto nan_str = ${COMP_NAMESPACE}::to_string(nan);
    REQUIRE(nan_str.size() >= 3);
    REQUIRE(nan_str[0] == 'n');
    REQUIRE(nan_str[1] == 'a');
    REQUIRE(nan_str[2] == 'n');

    nan_str = ${COMP_NAMESPACE}::to_string(-nan);
    REQUIRE(nan_str.size() >= 4);
    REQUIRE(nan_str[0] == '-');
    REQUIRE(nan_str[1] == 'n');
    REQUIRE(nan_str[2] == 'a');
    REQUIRE(nan_str[3] == 'n');

    REQUIRE(${COMP_NAMESPACE}::to_string(min) != \"\");
    REQUIRE(${COMP_NAMESPACE}::to_string(max) != \"\");
}
"
"
test_integer<int>();
test_integer<long>();
test_integer<long long>();

test_unsigned_integer<unsigned int>();
test_unsigned_integer<unsigned long>();
test_unsigned_integer<unsigned long long>();

test_float<float>();
test_float<double>();
test_float<long double>();
")
