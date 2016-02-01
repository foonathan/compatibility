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
    // warning: ugly bit hacks incoming
    // adapted from Hacker's Delight, p. 66, and https://en.wikipedia.org/wiki/Hamming_weight, popcount_2

    namespace detail
    {
        // step 1)
        // look at each pair of bits and put count of ones there
        ${COMP_PREFIX}CONSTEXPR_FNC std::uint32_t popcount_2er(std::uint32_t x)
        {
            return x - ((x >> 1) & 0x55555555u);
        }

        ${COMP_PREFIX}CONSTEXPR_FNC std::uint64_t popcount_2er(std::uint64_t x)
        {
            return x - ((x >> 1) & 0x5555555555555555u);
        }

        // step 2)
        // look at each 4er pack of bits and put count of ones there
        ${COMP_PREFIX}CONSTEXPR_FNC std::uint32_t popcount_4er(std::uint32_t x)
        {
            return (x & 0x33333333u) + ((x >> 2) & 0x33333333u);
        }

        ${COMP_PREFIX}CONSTEXPR_FNC std::uint64_t popcount_4er(std::uint64_t x)
        {
            return (x & 0x3333333333333333u) + ((x >> 2) & 0x3333333333333333u);
        }

        // step 3)
        // look at each 8er pack of bits and put count of ones there
        ${COMP_PREFIX}CONSTEXPR_FNC std::uint32_t popcount_8er(std::uint32_t x)
        {
            return (x + (x >> 4)) & 0x0F0F0F0Fu;
        }

        ${COMP_PREFIX}CONSTEXPR_FNC std::uint64_t popcount_8er(std::uint64_t x)
        {
            return (x + (x >> 4)) & 0x0F0F0F0F0F0F0F0Fu;
        }

        // step 4)
        // look at each 16er pack of bits and put count of ones there
        template <typename T>
        ${COMP_PREFIX}CONSTEXPR_FNC T popcount_16er(T x)
        {
            return x + (x >> 8);
        }

        // step 5)
        // look at each 32er pack of bits and put count of ones there
        template <typename T>
        ${COMP_PREFIX}CONSTEXPR_FNC T popcount_32er(T x)
        {
            return x + (x >> 16);
        }

        // performs step 1-5
        template <typename T>
        ${COMP_PREFIX}CONSTEXPR_FNC T popcount_upto_32er(T x)
        {
            return popcount_32er(popcount_16er(popcount_8er(popcount_4er(popcount_2er(x)))));
        }

        // step 6) (64bit only)
        // look at each 64er pack of bits and put count of ones there
        ${COMP_PREFIX}CONSTEXPR_FNC std::uint64_t popcount_64er(std::uint64_t x)
        {
            return x + (x >> 32);
        }
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned popcount(std::uint32_t x)
    {
        // count bits and mask of higher bits
        return detail::popcount_upto_32er(x) & 0x3Fu;
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned popcount(std::uint64_t x)
    {
        // count bits (including 64er) and mask of higher bits
        return detail::popcount_64er(detail::popcount_upto_32er(x)) & 0x7Fu;
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
