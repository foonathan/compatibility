# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(void_t "#include <type_traits>
                    int main()
                    {
                        std::void_t<int, char> *ptr;
                    }" COMP_CPP17_FLAG)
comp_workaround(void_t
"// see proposal: http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n3911.pdf
namespace ${COMP_NAMESPACE}
{
    namespace detail
    {
        template <typename...>
        struct voider
        {
            typedef void type;
        };
    }

    template <typename ... Ts>
    using void_t = typename detail::voider<Ts...>::type;
}" COMP_CPP1_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(void_t __cpp_lib_void_t 201411)
endif()
