# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(apply
        "#include <experimental/tuple>
        #include <tuple>

        int a(int, int) {return 0;}

        int main()
        {
            std::tuple<int, int> t;
            int val = std::experimental::apply(a, t);
        }" COMP_CPP14_FLAG)
comp_workaround(apply
"#include <tuple>
#include <type_traits>

#if ${COMP_PREFIX}HAS_APPLY
    #include <experimental/tuple>
#endif

namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_APPLY
    using std::experimental::apply;
#else
    #define ${COMP_PREFIX}DETAIL_AUTO_RETURN(...) decltype(__VA_ARGS__) {return (__VA_ARGS__);}

    namespace detail
    {
        template <typename F, class Tuple, std::size_t... I>
        ${COMP_PREFIX}CONSTEXPR auto apply(F &&f, Tuple &&t, ${COMP_NAMESPACE}::index_sequence<I...>)
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(${COMP_NAMESPACE}::invoke(std::forward<F>(f), std::get<I>(std::forward<Tuple>(t))...))
    }

    template <typename F, class Tuple>
    ${COMP_PREFIX}CONSTEXPR auto apply(F &&f, Tuple &&t)
    -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(detail::apply(std::forward<F>(f), std::forward<Tuple>(t),${COMP_NAMESPACE}::make_index_sequence<std::tuple_size<typename std::decay<Tuple>::type>::value>{}))

    #undef ${COMP_PREFIX}DETAIL_AUTO_RETURN
#endif
}" COMP_CPP11_FLAG cpp11_lang/constexpr cpp14_lib/integer_sequence cpp17_lib/invoke)

# rudimentary test to force instantiation
comp_unit_test(apply
"
#include <string>

void apply_test(int a, int b, std::string str)
{
    REQUIRE(a == 0);
    REQUIRE(b == 1);
    REQUIRE(str == \"abc\");
}
"
"
std::tuple<int, int, std::string> tuple = std::make_tuple(0, 1, \"abc\");
${COMP_NAMESPACE}::apply(apply_test, tuple);
")