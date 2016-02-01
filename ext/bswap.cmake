# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(bswap
        "#include <cstddef>

        template <int i>
        struct foo {};

        int main()
        {
            int a = __builtin_bswap16(4);
            int b = __builtin_bswap32(4);
            int c = __builtin_bswap64(4);

            // require constant expression
            foo<__builtin_bswap16(4)> f;
        }" COMP_CPP11_FLAG)
comp_workaround(bswap
"#include <cstdint>

// a function bswap() that swaps the bytes of an (unsigned) integer
// it is overloaded for each std::uint(8,16,32,64)_t
// e.g. OxAABB becomes 0xBBAA
namespace ${COMP_NAMESPACE}
{
    ${COMP_PREFIX}CONSTEXPR_FNC std::uint8_t bswap(std::uint8_t x)
    {
        return x;
    }

#if ${COMP_PREFIX}HAS_BSWAP
    ${COMP_PREFIX}CONSTEXPR_FNC std::uint16_t bswap(std::uint16_t x)
    {
        return __builtin_bswap16(x);
    }

    ${COMP_PREFIX}CONSTEXPR_FNC std::uint32_t bswap(std::uint32_t x)
    {
        return __builtin_bswap32(x);
    }

    ${COMP_PREFIX}CONSTEXPR_FNC std::uint64_t bswap(std::uint64_t x)
    {
        return __builtin_bswap64(x);
    }
#else
    ${COMP_PREFIX}CONSTEXPR_FNC std::uint16_t bswap(std::uint16_t x)
    {
        return (x & 0x00FFu) << 8
             | (x & 0xFF00u) >> 8;
    }

    ${COMP_PREFIX}CONSTEXPR_FNC std::uint32_t bswap(std::uint32_t x)
    {
        return (x & 0x000000FFu) << 24
             | (x & 0x0000FF00u) << 8
             | (x & 0x00FF0000u) >> 8
             | (x & 0xFF000000u) >> 24;
    }

    ${COMP_PREFIX}CONSTEXPR_FNC std::uint64_t bswap(std::uint64_t x)
    {
        return (x & 0x00000000000000FFul) << 56
             | (x & 0x000000000000FF00ul) << 40
             | (x & 0x0000000000FF0000ul) << 24
             | (x & 0x00000000FF000000ul) << 8
             | (x & 0x000000FF00000000ul) >> 8
             | (x & 0x0000FF0000000000ul) >> 24
             | (x & 0x00FF000000000000ul) >> 40
             | (x & 0xFF00000000000000ul) >> 56;
    }
#endif
}" COMP_CPP11_FLAG cpp11_lang/constexpr)

comp_unit_test(bswap
""
"
using ${COMP_NAMESPACE}::bswap;

REQUIRE(bswap(std::uint8_t(0xAA)) == 0xAA);
REQUIRE(bswap(std::uint16_t(0xAABB)) == 0xBBAA);
REQUIRE(bswap(std::uint32_t(0xAABBCCDD)) == 0xDDCCBBAA);
REQUIRE(bswap(std::uint64_t(0xAABBCCDDEEFF0011)) == 0x1100FFEEDDCCBBAA);
")
