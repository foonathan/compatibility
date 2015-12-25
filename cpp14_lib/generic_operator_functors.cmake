# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(generic_operator_functors
        "#include <functional>
        int main()
        {
            bool val = std::greater<>{}(4, 5);
        }" COMP_CPP14_FLAG)
comp_workaround(generic_operator_functors
"#include <utility>

namespace ${COMP_NAMESPACE}
{
    #define ${COMP_PREFIX}DETAIL_AUTO_RETURN(x) decltype(x) {return x;}

    // only the generic version

    struct plus
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) + std::forward<U>(u))
    };

    struct minus
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) - std::forward<U>(u))
    };

    struct multiplies
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) * std::forward<U>(u))
    };

    struct divides
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) / std::forward<U>(u))
    };

    struct modulus
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) % std::forward<U>(u))
    };

    struct negate
    {
        template <typename T>
        auto operator()(T&& t) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(-std::forward<T>(t))
    };

    struct equal_to
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) == std::forward<U>(u))
    };

    struct not_equal_to
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) != std::forward<U>(u))
    };

    struct greater
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) > std::forward<U>(u))
    };

    struct greater_equal
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) >= std::forward<U>(u))
    };

    struct less
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) < std::forward<U>(u))
    };

    struct less_equal
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) <= std::forward<U>(u))
    };

    struct logical_and
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) && std::forward<U>(u))
    };

    struct logical_or
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) || std::forward<U>(u))
    };

    struct logical_not
    {
        template <typename T>
        auto operator()(T&& t) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(!std::forward<T>(t))
    };

    struct bit_and
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) & std::forward<U>(u))
    };

    struct bit_or
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) | std::forward<U>(u))
    };

    struct bit_xor
    {
        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) ^ std::forward<U>(u))
    };

    struct bit_not
    {
        template <typename T>
        auto operator()(T&& t) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(~std::forward<T>(t))
    };

    #undef ${COMP_PREFIX}DETAIL_AUTO_RETURN
}")
