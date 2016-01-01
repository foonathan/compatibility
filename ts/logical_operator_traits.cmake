# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(logical_operator_traits
    "#include <experimental/type_traits>
    #include <type_traits>

    struct foo : std::true_type
    {};

    int main()
    {
        std:;experimental::conjunction<foo> c;
    }" COMP_CPP17_FLAG)
comp_workaround(logical_operator_traits
"#include <type_traits>

#if ${COMP_PREFIX}HAS_LOGICAL_OPERATOR_TRAITS
    #include <experimental/type_traits>
#endif

namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_LOGICAL_OPERATOR_TRAITS
    using std::experimental::conjunction;
    using std::experimental::disjunction;
    using std::experimental::negation;
#else
    template <class B>
    struct negation : std::integral_constant<bool, !B::value> {};

    // conjunction
    template <class...>
    struct conjunction;

    template <>
    struct conjunction<>
    : std::true_type {};

    template <class B1>
    struct conjunction<B1>
    : B1 {};

    template <class B1, class ... Bs>
    struct conjunction<B1, Bs...>
    : std::conditional<B1::value == false, B1, conjunction<Bs...>>::type {};

    // disjunction
    template <class...>
    struct disjunction;

    template <>
    struct disjunction<>
    : std::false_type {};

    template <class B1>
    struct disjunction<B1>
    : B1 {};

    template <class B1, class ... Bs>
    struct disjunction<B1, Bs...>
    : std::conditional<B1::value == false, disjunction<Bs...>, B1> {};
#endif
}" COMP_CPP11_FLAG)
