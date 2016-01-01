# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(not_fn
        "#include <experimental/functional>

        bool f() {return true;}

        int main()
        {
            bool val = std::experimental::not_fn(f)();
        }" COMP_CPP17_FLAG)
comp_workaround(not_fn
"#include <type_traits>

#if ${COMP_PREFIX}HAS_NOT_FN
    #include <experimental/functional>
#endif

namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_NOT_FN
    using std::experimental::not_fn;
#else
    namespace detail
    {
        template <typename F>
        struct notter
        {
            F f;

            template <typename ... Args>
            auto operator()(Args&&... args)
            -> decltype(!${COMP_NAMESPACE}::invoke(f, std::forward<Args>(args)...))
            {
                return !${COMP_NAMESPACE}::invoke(f, std::forward<Args>(args)...);
            }
        };
    }

    template <typename F>
    detail::notter<typename std::decay<F>::type> not_fn(F &&f)
    {
        return {std::forward<F>(f)};
    }
#endif
}" COMP_CPP11_FLAG cpp17_lib/invoke)

comp_unit_test(not_fn
"bool not_fn_test(int a) {return a % 2 == 0;}"
"
REQUIRE(not_fn_test(2));
REQUIRE(!not_fn_test(3));

auto f = ${COMP_NAMESPACE}::not_fn(not_fn_test);
REQUIRE(!f(2));
REQUIRE(f(3));")
