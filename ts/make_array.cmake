# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(make_array
        "#include <experimental/array>
        #include <array>

        int main()
        {
            std::array<int, 5> arr = std::experimental::make_array(1, 2, 3, 4, 5);
            int arr2[] = {1, 2, 3};
            std::array<int, 3> arr3 = std::experimental::to_array(arr2);
        }" COMP_CPP17_FLAG)
comp_workaround(make_array
"#include <array>
#include <type_traits>
#include <functional>

#if ${COMP_PREFIX}HAS_MAKE_ARRAY
    #include <experimental/array>
#endif

namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_MAKE_ARRAY
    using std::experimental::make_array;
    using std::experimental::to_array;
#else
    // based on cppreference.com
    namespace detail
    {
        template <typename>
        struct no_ref_wrapper : std::true_type {};

        template <typename T>
        struct no_ref_wrapper<std::reference_wrapper<T>> : std::false_type{};

        template <typename D, typename ...>
        struct return_type
        {
            typedef D type;
        };

        template <typename ... Ts>
        struct return_type<void, Ts...>
        {
            static_assert(${COMP_NAMESPACE}::conjunction<no_ref_wrapper<typename std::decay<Ts>::type>...>::value,
                \"make_array: cannot deduce type if passed reference wrapper\");

             typedef typename std::common_type<Ts...>::type type;
        };
    }

    template <typename D = void, typename ... Ts>
    ${COMP_PREFIX}CONSTEXPR std::array<typename detail::return_type<D, Ts...>::type, sizeof...(Ts)>
        make_array(Ts&&... ts)
    {
        return {std::forward<Ts>(ts)...};
    }

    namespace detail
    {
        template <typename T, std::size_t N, std::size_t ... Is>
    ${COMP_PREFIX}CONSTEXPR std::array<typename std::remove_cv<T>::type, N>
        to_array(T(&arr)[N], ${COMP_NAMESPACE}::index_sequence<Is...>)
        {
            return {{ arr[Is]... }};
        }
    }

    template <typename T, std::size_t N>
    ${COMP_PREFIX}CONSTEXPR std::array<typename std::remove_cv<T>::type, N>
        to_array(T(&arr)[N])
    {
        return detail::to_array(arr, ${COMP_NAMESPACE}::make_index_sequence<N>{});
    }
#endif
}" COMP_CPP11_FLAG cpp11_lang/constexpr cpp14_lib/integer_sequence ts/logical_operator_traits)

comp_unit_test(make_array
""
"
// just instantiate functions
std::array<int, 5> arr = ${COMP_NAMESPACE}::make_array(1, 2, 3, 4, 5);
int arr2[] = {1, 2, 3};
std::array<int, 3> arr3 = ${COMP_NAMESPACE}::to_array(arr2);
")
