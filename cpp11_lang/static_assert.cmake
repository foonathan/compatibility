# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(static_assert "int main(){static_assert(true, \"\");}" COMP_CPP11_FLAG)
comp_workaround(static_assert
"#ifndef ${COMP_PREFIX}STATIC_ASSERT
    #if ${COMP_PREFIX}HAS_STATIC_ASSERT
        #define ${COMP_PREFIX}STATIC_ASSERT(Expr, Msg) static_assert(Expr, Msg)
    #else
        namespace ${COMP_NAMESPACE} { namespace detail
        {
            template <bool B>
            struct static_assert_impl;

            template <>
            struct static_assert_impl<true> {};
        }} // namespace ${COMP_NAMESPACE}::detail

        #define ${COMP_PREFIX}STATIC_ASSERT(Expr, Msg) ${COMP_NAMESPACE}::detail::static_assert_impl<(Expr)>()
    #endif
#endif" COMP_CPP98_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(static_assert __cpp_static_assert 200410)
endif()
