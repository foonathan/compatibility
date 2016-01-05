# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(integer_sequence
        "#include <utility>

        int main()
        {
            std::make_index_sequence<4> f;
        }" COMP_CPP14_FLAG)
comp_workaround(integer_sequence
"
#include <type_traits>
#include <utility>

namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_INTEGER_SEQUENCE
    using std::integer_sequence;
    using std::index_sequence;
    using std::make_integer_sequence;
    using std::make_index_sequence;
    using std::index_sequence_for;
#else
    template <typename Integer, Integer... Ints>
    class integer_sequence
    {
    public:
        using value_type = Integer;

        static ${COMP_PREFIX}CONSTEXPR std::size_t size()
        {
            return sizeof...(Ints);
        }
    };

    template <std::size_t... Ints>
    using index_sequence = integer_sequence<std::size_t, Ints...>;

    namespace detail
    {
        template <typename Integer, class N, Integer ... Tail>
        struct make_integer_sequence
        : make_integer_sequence<Integer, std::integral_constant<Integer, N::value - 1>,
        N::value - 1, Tail...>
        {};

        template <typename Integer, Integer ... Tail>
        struct make_integer_sequence<Integer, std::integral_constant<Integer, 0>, Tail...>
        {
            using type = integer_sequence<Integer, Tail...>;
        };
    }

    template <typename Integer, Integer N>
    using make_integer_sequence = typename detail::make_integer_sequence<Integer,
                                            std::integral_constant<Integer, N>>::type;

    template <std::size_t N>
    using make_index_sequence = make_integer_sequence<std::size_t, N>;

    template <typename ... Ts>
    using index_sequence_for = make_index_sequence<sizeof...(Ts)>;
#endif
}" COMP_CPP11_FLAG cpp11_lang/constexpr)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(integer_sequence __cpp_lib_integer_sequence 201304)
endif()