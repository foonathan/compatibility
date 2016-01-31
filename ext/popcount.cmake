# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(popcount
        "#include <cstddef>

        template <int i>
        struct foo {};

        int main()
        {
            int a = __builtin_popcount(4);
            int b = __builtin_popcountl(4);
            int c = __builtin_popcountll(4);

            // require constant expression
            foo<__builtin_popcount(4)> f;
        }" COMP_CPP11_FLAG)
comp_workaround(popcount
"
#include <cstdint>

// a function popcount() that returns the number of 1-bits in an integer
// * if builtin available: overloaded for each builtin version
// * otherwise: bit-hack version, overloaded for uint32_t and uint64_t
namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_POPCOUNT
    ${COMP_PREFIX}CONSTEXPR_FNC unsigned popcount(unsigned int x)
    {
        return __builtin_popcount(x);
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned popcount(unsigned long x)
    {
        return __builtin_popcountl(x);
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned popcount(unsigned long long x)
    {
        return __builtin_popcountll(x);
    }
#else
    ${COMP_PREFIX}CONSTEXPR_FNC unsigned popcount(std::uint32_t x)
    {
        // from Hacker's Delight, p. 66
        x -= (x >> 1) & 0x55555555u;
        x = (x & 0x33333333u) + ((x >> 2) & 0x33333333u);
        x = (x + (x >> 4)) & 0x0F0F0F0Fu;
        x += x >> 8;
        x += x >> 16;
        return x & 0x3Fu;
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned popcount(std::uint64_t x)
    {
        // adapted from https://en.wikipedia.org/wiki/Hamming_weight, popcount_2
        x -= (x >> 1) & 0x5555555555555555ul;
        x = (x & 0x3333333333333333ul) + ((x >> 2) & 0x3333333333333333ul);
        x = (x + (x >> 4)) & 0x0F0F0F0F0F0F0F0Ful;
        x += x >> 8;
        x += x >> 16;
        x += x >> 32;
        return x & 0x7Fu;
    }
#endif
}" COMP_CPP11_FLAG cpp11_lang/constexpr)

comp_unit_test(popcount
""
"
using ${COMP_NAMESPACE}::popcount;

REQUIRE(popcount(0u) == 0);
REQUIRE(popcount(1u) == 1);
REQUIRE(popcount(2u) == 1);
REQUIRE(popcount(3u) == 2);
REQUIRE(popcount(4u) == 1);

REQUIRE(popcount(255u) == 8);
REQUIRE(popcount(256u) == 1);

REQUIRE(popcount(std::uint32_t(-1)) == 32);
REQUIRE(popcount(std::uint64_t(std::uint32_t(-1)) + 1) == 1);
REQUIRE(popcount(std::uint64_t(-1)) == 64);
")
