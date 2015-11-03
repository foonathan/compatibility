# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("int main(){static_assert(true, \"\");}" static_assert "${cpp11_flag}")
comp_gen_header(static_assert
"
#ifndef ${COMP_PREFIX}STATIC_ASSERT
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
#endif
")