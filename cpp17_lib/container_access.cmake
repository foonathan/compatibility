# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(container_access
                "#include <iterator>
                #include <vector>
                int main()
                {
                    int array[3];
                    std::size(array);
                    std::data(array);
                    std::empty(array);
                    std::vector<int> vec;
                    std::size(vec);
                    std::data(vec);
                    std::empty(vec);
                }" COMP_CPP17_FLAG)
comp_workaround(container_access
"#include <cstddef>
#include <initializer_list>

namespace ${COMP_NAMESPACE}
{
    #if ${COMP_PREFIX}HAS_CONTAINER_ACCESS
        using std::size;
        using std::empty;
        using std::data;
    #else
        // see http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2014/n4280.pdf
        template <class C>
        ${COMP_PREFIX}CONSTEXPR_FNC auto size(const C &c) -> decltype(c.size())
        {
            return c.size();
        }

        template <typename T, std::size_t N>
        ${COMP_PREFIX}CONSTEXPR_FNC std::size_t size(const T (&) [N]) ${COMP_PREFIX}NOEXCEPT
        {
            return N;
        }

        template <class C>
        ${COMP_PREFIX}CONSTEXPR_FNC auto empty(const C &c) -> decltype(c.empty())
        {
            return c.empty();
        }

        template <typename T, std::size_t N>
        ${COMP_PREFIX}CONSTEXPR_FNC bool empty(const T (&) [N]) ${COMP_PREFIX}NOEXCEPT
        {
            return false;
        }

        template <typename T>
        ${COMP_PREFIX}CONSTEXPR_FNC bool empty(std::initializer_list<T> list) ${COMP_PREFIX}NOEXCEPT
        {
            return list.size() == 0u;
        }

        template <class C>
        ${COMP_PREFIX}CONSTEXPR_FNC auto data(C &c) -> decltype(c.data())
        {
            return c.data();
        }

        template <class C>
        ${COMP_PREFIX}CONSTEXPR_FNC auto data(const C &c) -> decltype(c.data())
        {
            return c.data();
        }

        template <typename T, std::size_t N>
        ${COMP_PREFIX}CONSTEXPR_FNC T* data(const T (&array) [N]) ${COMP_PREFIX}NOEXCEPT
        {
            return array;
        }

        template <typename T>
        ${COMP_PREFIX}CONSTEXPR_FNC const T* data(std::initializer_list<T> list) ${COMP_PREFIX}NOEXCEPT
        {
            return list.begin();
        }
    #endif
}" COMP_CPP11_FLAG cpp11_lang/constexpr cpp11_lang/noexcept)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(container_access __cpp_lib_nonmember_container_access 201411)
endif()