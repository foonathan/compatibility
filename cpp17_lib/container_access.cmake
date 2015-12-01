# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("#include <iterator>
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
                    }"
                    container_access "${cpp17_flag}")
comp_gen_header(container_access
"
#include <cstddef>
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
        constexpr auto size(const C &c) -> decltype(c.size())
        {
            return c.size();
        }

        template <typename T, std::size_t N>
        constexpr std::size_t size(const T (&) [N]) noexcept
        {
            return N;
        }

        template <class C>
        constexpr auto empty(const C &c) -> decltype(c.empty())
        {
            return c.empty();
        }

        template <typename T, std::size_t N>
        constexpr bool empty(const T (&) [N]) noexcept
        {
            return false;
        }

        template <typename T>
        constexpr bool empty(std::initializer_list<T> list) noexcept
        {
            return list.size() == 0u;
        }

        template <class C>
        constexpr auto data(C &c) -> decltype(c.data())
        {
            return c.data();
        }

        template <class C>
        constexpr auto data(const C &c) -> decltype(c.data())
        {
            return c.data();
        }

        template <typename T, std::size_t N>
        constexpr T* data(const T (&array) [N]) noexcept
        {
            return array;
        }

        template <typename T>
        constexpr const T* data(std::initializer_list<T> list) noexcept
        {
            return list.begin();
        }
    #endif
}
")