# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

# the is_trivially_XXX traits were missing under some libstdc++ versions
# is_trivial was available though
comp_feature(is_trivially "#include <type_traits>
                           int main()
                           {
                               int a = std::is_trivially_copyable<int>::value;
                           }" COMP_CPP11_FLAG)
comp_workaround(is_trivially
"#include <type_traits>

namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_IS_TRIVIALLY
    using std::is_trivially_copyable;

    using std::is_trivially_constructible;
    using std::is_trivially_default_constructible;
    using std::is_trivially_copy_constructible;
    using std::is_trivially_move_constructible;

    using std::is_trivially_assignable;
    using std::is_trivially_copy_assignable;
    using std::is_trivially_move_assignable;

    using std::is_trivially_destructible;
#else
    template <typename T>
    struct is_trivially_copyable
    : std::integral_constant<bool, std::is_trivial<T>::value> {};

    template <typename T, typename ... Args>
    struct is_trivially_constructible
    : std::integral_constant<bool, std::is_constructible<T, Args...>::value
                            && std::is_trivial<typename std::remove_reference<T>::type>::value> {};

    template <typename T>
    struct is_trivially_default_constructible
    : std::integral_constant<bool, std::is_default_constructible<T>::value
                             && std::is_trivial<typename std::remove_reference<T>::type>::value> {};

    template <typename T>
    struct is_trivially_copy_constructible
    : std::integral_constant<bool, std::is_copy_constructible<T>::value
                             && std::is_trivial<typename std::remove_reference<T>::type>::value> {};

    template <typename T>
    struct is_trivially_move_constructible
    : std::integral_constant<bool, std::is_move_constructible<T>::value
                             && std::is_trivial<typename std::remove_reference<T>::type>::value> {};

    template <typename T, typename U>
    struct is_trivially_assignable
    : std::integral_constant<bool, std::is_assignable<T, U>::value
                             && std::is_trivial<typename std::remove_reference<T>::type>::value> {};

    template <typename T>
    struct is_trivially_copy_assignable
    : std::integral_constant<bool, std::is_copy_assignable<T>::value
                             && std::is_trivial<typename std::remove_reference<T>::type>::value> {};

    template <typename T>
    struct is_trivially_move_assignable
    : std::integral_constant<bool, std::is_move_assignable<T>::value
                             && std::is_trivial<typename std::remove_reference<T>::type>::value> {};

    template <typename T>
    struct is_trivially_destructible
    : std::integral_constant<bool, std::is_destructible<T>::value
                             && std::is_trivial<typename std::remove_reference<T>::type>::value> {};
#endif
}" COMP_CPP11_FLAG)

comp_unit_test(is_trivially
""
"
using namespace ${COMP_NAMESPACE};

// just instantiations
static_assert(is_trivially_copyable<int>::value, \"\");

static_assert(is_trivially_constructible<int, int>::value, \"\");
static_assert(is_trivially_default_constructible<int>::value, \"\");
static_assert(is_trivially_move_constructible<int>::value, \"\");
static_assert(is_trivially_copy_constructible<int>::value, \"\");

static_assert(is_trivially_assignable<int&, int>::value, \"\");
static_assert(is_trivially_copy_assignable<int>::value, \"\");
static_assert(is_trivially_move_assignable<int>::value, \"\");

static_assert(is_trivially_destructible<int>::value, \"\");
")
