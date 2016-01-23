# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

# uses macro __STDC_HOSTED__
comp_feature(hosted_implementation "#include <cstddef>
                    #if !_MSC_VER && !__STDC_HOSTED__
                        #error \"no hosted\"
                    #endif

                    int main() {}" COMP_CPP98_FLAG)
comp_workaround(hosted_implementation
"// HAS_HOSTED_IMPLEMENTATION doesn't sond that nice... :D
#define ${COMP_PREFIX}HOSTED_IMPLEMENTATION ${COMP_PREFIX}HAS_HOSTED_IMPLEMENTATION

#include <type_traits>

#if ${COMP_PREFIX}HOSTED_IMPLEMENTATION
    #include <utility>
#endif

namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_RVALUE_REF
    // move - taken from http://stackoverflow.com/a/7518365
    template <typename T>
    typename std::remove_reference<T>::type&& move(T&& arg) ${COMP_PREFIX}NOEXCEPT
    {
        return static_cast<typename std::remove_reference<T>::type&&>(arg);
    }

    // forward - taken from http://stackoverflow.com/a/27501759
    template <class T>
    T&& forward(typename std::remove_reference<T>::type& t) ${COMP_PREFIX}NOEXCEPT
    {
        return static_cast<T&&>(t);
    }

    template <class T>
    T&& forward(typename std::remove_reference<T>::type&& t) ${COMP_PREFIX}NOEXCEPT
    {
        static_assert(!std::is_lvalue_reference<T>::value,
                      \"Can not forward an rvalue as an lvalue.\");
        return static_cast<T&&>(t);
    }
#endif

#if ${COMP_PREFIX}HOSTED_IMPLEMENTATION
    using std::swap;
#else
    #if ${COMP_PREFIX}HAS_RVALUE_REF
        template <typename T>
        void swap(T &a, T &b) ${COMP_PREFIX}NOEXCEPT_IF(std::is_nothrow_move_assignable<T>::value
                                                   && std::is_nothrow_move_constructible<T>::value)
       {
           T tmp = move(a);
           a = move(b);
           b = move(tmp);
        }
    #else
        template <typename T>
        void swap(T &a, T &b)
        {
            T tmp(a);
            a = b;
            b = tmp;
        }
    #endif
#endif
}" COMP_CPP98_FLAG cpp11_lang/noexcept cpp11_lang/rvalue_ref)
