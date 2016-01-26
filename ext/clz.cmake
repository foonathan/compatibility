# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(clz
        "#include <cstddef>

        int main()
        {
            int a = __builtin_clz(4);
            int b = __builtin_clzl(4);
            int c = __builtin_clzll(4);
        }" COMP_CPP98_FLAG)
comp_workaround(clz
"
#include <climits>
#include <cstdint>
#include <type_traits>

#if !${COMP_PREFIX}HAS_CLZ && defined(_MSC_VER)
    #include <intrin.h>
#endif

// a function clz() that returns the number of leading zeros in an integer
// overloaded for each of the fixed-sized integers, uundefined for input value 0!
// for up to 32bit:
// * if builtin available: the smallest integer version that is fitting
// * MSVC: _BitScanReverse()
// * otherwise: binary search implementation w/ lookup table for last 4 bits
// for 64bit:
// * if builtin available: the smallest integer version that is fitting
// * MSVC 64Bit: _BitScanReverse64()
// * otherwise: divides into two 32bit numbers and forwards to 32bit version
// defines ${COMP_PREFIX}CLZ_BINARY_SEARCH/${COMP_PREFIX}CLZ_BINARY_SEARCH64 if using fallback for 32/64 bits
namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_CLZ
    #define ${COMP_PREFIX}CLZ_BINARY_SEARCH 0
    #define ${COMP_PREFIX}CLZ_BINARY_SEARCH64 0

    namespace detail
    {
        // prioritized tag dispatching to choose smallest integer that fits
        struct clzll_tag {};
        struct clzl_tag : clzll_tag {};
        struct clz_tag : clzl_tag {};

        // also subtracts the number of addtional 0s that occur because the target type is smaller
        template <typename T,
                  typename = typename std::enable_if<sizeof(T) <= sizeof(unsigned int)>::type>
        unsigned clz(clz_tag, T x)
        {
            return __builtin_clz(x) - (sizeof(unsigned int) * CHAR_BIT - sizeof(T) * CHAR_BIT);
        }

        template <typename T,
                  typename = typename std::enable_if<sizeof(T) <= sizeof(unsigned long)>::type>
        unsigned clz(clzl_tag, T x)
        {
            return __builtin_clzl(x) - (sizeof(unsigned long) * CHAR_BIT - sizeof(T) * CHAR_BIT);
        }

        template <typename T,
                  typename = typename std::enable_if<sizeof(T) <= sizeof(unsigned long long)>::type>
        unsigned clz(clzll_tag, T x)
        {
            return __builtin_clzll(x) - (sizeof(unsigned long long) * CHAR_BIT - sizeof(T) * CHAR_BIT);
        }
    }

    inline unsigned clz(std::uint8_t x)
    {
        return detail::clz(detail::clz_tag{}, x);
    }

    inline unsigned clz(std::uint16_t x)
    {
        return detail::clz(detail::clz_tag{}, x);;
    }

    inline unsigned clz(std::uint32_t x)
    {
        return detail::clz(detail::clz_tag{}, x);
    }

    inline unsigned clz(std::uint64_t x)
    {
        return detail::clz(detail::clz_tag{}, x);
    }
#else
    #if defined(_MSC_VER)
        #define ${COMP_PREFIX}CLZ_BINARY_SEARCH 0

        inline unsigned clz(std::uint32_t x)
        {
            unsigned long res;
            _BitScanReverse(&res, x);
            return 31 - res;
        }

        inline unsigned clz(std::uint8_t x)
        {
            return clz(std::uint32_t(x)) - 24;
        }

        inline unsigned clz(std::uint16_t x)
        {
            return clz(std::uint32_t(x)) - 16;
        }
    #else
        #define ${COMP_PREFIX}CLZ_BINARY_SEARCH 1

        inline unsigned clz(std::uint8_t x)
        {
            static const char lookup[16] = { 4, 3, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 };
            auto higher = (x >> 4), lower = (x & Ox0Fu);
            if (higher)
                return lookup[higher];
            else
                return 4 + lookup[lower];
        }

        inline unsigned clz(std::uint16_t x)
        {
            std::uint8_t higher = (x >> 8), lower = (x & OxFFu);
            if (higher)
                return clz(higher);
            else
                return 8 + clz(lower);
        }

        inline unsigned clz(std::uint32_t x)
        {
            std::uint16_t higher = (x >> 16), lower = (x & OxFFFFu);
            if (higher)
                return clz(higher);
            else
                return 16 + clz(lower);
        }
    #endif

    // 64bit version
    #if defined(_MSC_VER) && defined(_M_X64)
        #define ${COMP_PREFIX}CLZ_BINARY_SEARCH64 0

        inline unsigned clz(std::uint64_t x)
        {
            unsigned long res;
            _BitScanReverse64(&res, x);
            return 63 - res;
        }
    #else
        #define ${COMP_PREFIX}CLZ_BINARY_SEARCH64 1

        inline unsigned clz(std::uint64_t x)
        {
            std::uint32_t higher = (x >> 32), lower = (x & OxFFFFFFFFul);
            if (higher)
                return clz(higher);
            else
                return 32 + clz(lower);
        }
    #endif
#endif
}" COMP_CPP11_FLAG)
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
