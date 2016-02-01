# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(ctz
        "#include <cstddef>

        template <int i>
        struct foo {};

        int main()
        {
            int a = __builtin_ctz(4);
            int b = __builtin_ctzl(4);
            int c = __builtin_ctzll(4);

            // require constant expression
            foo<__builtin_ctz(4)> f;
        }" COMP_CPP11_FLAG)
comp_workaround(ctz
"
#include <cstdint>

// a function ctz() that returns the number of trailing zeros in an integer
// undefined for input value 0!
// * if builtin available: overloaded for each builtin version
// * otherwise: binary search implementation w/ lookup table for last 4 bits, overloaded for each fixed-sized integers
namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_CTZ
    ${COMP_PREFIX}CONSTEXPR_FNC unsigned ctz(unsigned int x)
    {
        return __builtin_ctz(x);
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned ctz(unsigned long x)
    {
        return __builtin_ctzl(x);
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned ctz(unsigned long long x)
    {
        return __builtin_ctzll(x);
    }
#else
    namespace detail
    {
        ${COMP_PREFIX}CONSTEXPR char ctz_lookup[16] = { 0, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0};

        ${COMP_PREFIX}CONSTEXPR_FNC unsigned ctz_base(std::uint8_t higher, std::uint8_t lower)
        {
            return lower ? ctz_lookup[lower] : 4 + ctz_lookup[higher];
        }
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned ctz(std::uint8_t x)
    {
        return detail::ctz_base(x >> 4, x & 0x0Fu);
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned ctz(std::uint16_t x)
    {
        return x & 0xFFu ? ctz(std::uint8_t(x & 0xFFu)) : 8 + ctz(std::uint8_t(x >> 8));
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned ctz(std::uint32_t x)
    {
        return x & 0xFFFFu ? ctz(std::uint16_t(x & 0xFFFFu)) : 16 + ctz(std::uint16_t(x >> 16));
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned ctz(std::uint64_t x)
    {
        return x & 0xFFFFFFFFul ? ctz(std::uint32_t(x & 0xFFFFFFFFul)) : 32 + ctz(std::uint32_t(x >> 32));
    }
#endif
}" COMP_CPP11_FLAG cpp11_lang/constexpr)

comp_unit_test(ctz
"#include <climits>"
"
using ${COMP_NAMESPACE}::ctz;

REQUIRE(ctz(1u) == 0);
REQUIRE(ctz(2u) == 1);
REQUIRE(ctz(3u) == 0);
REQUIRE(ctz(4u) == 2);

REQUIRE(ctz(255u) == 0);
REQUIRE(ctz(256u) == 8);
REQUIRE(ctz(257u) == 0);

REQUIRE(ctz(std::uint32_t(-1)) == 0);
REQUIRE(ctz(std::uint64_t(std::uint32_t(-1)) + 1) == 32);
")
