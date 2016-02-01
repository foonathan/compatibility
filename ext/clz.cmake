# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(clz
        "#include <cstddef>

        template <int i>
        struct foo {};

        int main()
        {
            int a = __builtin_clz(4);
            int b = __builtin_clzl(4);
            int c = __builtin_clzll(4);

            // require constant expression
            foo<__builtin_clz(4)> f;
        }" COMP_CPP11_FLAG)
comp_workaround(clz
"
#include <climits>
#include <cstdint>
#include <type_traits>

// a function clz() that returns the number of leading zeros in an integer
// overloaded for each of the fixed-sized integers, undefined for input value 0!
// * if builtin available: uses the smallest integer version that is fitting
// * otherwise: binary search implementation w/ lookup table for last 4 bits
namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_CLZ
    namespace detail
    {
        // prioritized tag dispatching to choose smallest integer that fits
        struct clzll_tag {};
        struct clzl_tag : clzll_tag {};
        struct clz_tag : clzl_tag {};

        // also subtracts the number of addtional 0s that occur because the target type is smaller
        template <typename T,
                  typename = typename std::enable_if<sizeof(T) <= sizeof(unsigned int)>::type>
        ${COMP_PREFIX}CONSTEXPR_FNC unsigned clz(clz_tag, T x)
        {
            return __builtin_clz(x) - (sizeof(unsigned int) * CHAR_BIT - sizeof(T) * CHAR_BIT);
        }

        template <typename T,
                  typename = typename std::enable_if<sizeof(T) <= sizeof(unsigned long)>::type>
        ${COMP_PREFIX}CONSTEXPR_FNC unsigned clz(clzl_tag, T x)
        {
            return __builtin_clzl(x) - (sizeof(unsigned long) * CHAR_BIT - sizeof(T) * CHAR_BIT);
        }

        template <typename T,
                  typename = typename std::enable_if<sizeof(T) <= sizeof(unsigned long long)>::type>
        ${COMP_PREFIX}CONSTEXPR_FNC unsigned clz(clzll_tag, T x)
        {
            return __builtin_clzll(x) - (sizeof(unsigned long long) * CHAR_BIT - sizeof(T) * CHAR_BIT);
        }
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned clz(std::uint8_t x)
    {
        return detail::clz(detail::clz_tag{}, x);
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned clz(std::uint16_t x)
    {
        return detail::clz(detail::clz_tag{}, x);;
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned clz(std::uint32_t x)
    {
        return detail::clz(detail::clz_tag{}, x);
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned clz(std::uint64_t x)
    {
        return detail::clz(detail::clz_tag{}, x);
    }
#else
    namespace detail
    {
        ${COMP_PREFIX}CONSTEXPR std::uint8_t clz_lookup[16] = { 4, 3, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 };

        ${COMP_PREFIX}CONSTEXPR_FNC unsigned clz_base(std::uint8_t higher, std::uint8_t lower)
        {
            return higher ? clz_lookup[higher] : 4 + clz_lookup[lower];
        }
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned clz(std::uint8_t x)
    {
        return detail::clz_base(x >> 4, x & 0x0Fu);
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned clz(std::uint16_t x)
    {
        return x >> 8 ? clz(std::uint8_t(x >> 8)) : 8 + clz(std::uint8_t(x & 0xFFu));
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned clz(std::uint32_t x)
    {
        return x >> 16 ? clz(std::uint16_t(x >> 16)) : 16 + clz(std::uint16_t(x & 0xFFFFu));
    }

    ${COMP_PREFIX}CONSTEXPR_FNC unsigned clz(std::uint64_t x)
    {
        return x >> 32 ? clz(std::uint32_t(x >> 32)) : 32 + clz(std::uint32_t(x & 0xFFFFFFFFul));
    }
#endif
}" COMP_CPP11_FLAG cpp11_lang/constexpr)
comp_unit_test(clz
"#include <cstdint>"
"
using ${COMP_NAMESPACE}::clz;
// 8 bits
REQUIRE(clz(std::uint8_t(1)) == 7);
REQUIRE(clz(std::uint8_t(2)) == 6);
REQUIRE(clz(std::uint8_t(127)) == 1);
REQUIRE(clz(std::uint8_t(128)) == 0);
REQUIRE(clz(std::uint8_t(200)) == 0);
REQUIRE(clz(std::uint8_t(255)) == 0);

// 16 bits
REQUIRE(clz(std::uint16_t(1)) == 15);
REQUIRE(clz(std::uint16_t(2)) == 14);
REQUIRE(clz(std::uint16_t(128)) == 8);
REQUIRE(clz(std::uint16_t(256)) == 7);
REQUIRE(clz(std::uint16_t(0xFFFD)) == 0);
REQUIRE(clz(std::uint16_t(0xFFFF)) == 0);

// 32 bits
REQUIRE(clz(std::uint32_t(1)) == 31);
REQUIRE(clz(std::uint32_t(2)) == 30);
REQUIRE(clz(std::uint32_t(0xFFFF)) == 16);
REQUIRE(clz(std::uint32_t(0xFFFF + 1)) == 15);
REQUIRE(clz(std::uint32_t(-1)) == 0); // max value

// 64 bits
REQUIRE(clz(std::uint64_t(1)) == 63);
REQUIRE(clz(std::uint64_t(2)) == 62);
REQUIRE(clz(std::uint64_t(std::uint32_t(-1))) == 32);
REQUIRE(clz(std::uint64_t(std::uint32_t(-1)) + 1) == 31);
REQUIRE(clz(std::uint64_t(-1)) == 0); // max value")
