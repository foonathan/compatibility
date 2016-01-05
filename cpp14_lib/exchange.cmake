# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(exchange
        "#include <utility>

        int main()
        {
            int val = 4;
            int old_val = std::exchange(val, 5);
        }" COMP_CPP14_FLAG)
comp_workaround(exchange
"namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_EXCHANGE
    using std::exchange;
#else
    // see N3668
    template <class T, class U=T>
    T exchange(T &obj, U &&new_val)
    {
        T old_val = std::move(obj);
        obj = std::forward<U>(new_val);
        return old_val;
    }
#endif
}"  COMP_CPP11_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(exchange __cpp_lib_exchange_function 201304)
endif()