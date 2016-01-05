# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(make_unique "#include <memory>
                          int main() {std::unique_ptr<int> ptr = std::make_unique<int>(4);}"
             COMP_CPP14_FLAG)
comp_workaround(make_unique
"#include <memory>
#include <type_traits>

namespace ${COMP_NAMESPACE}
{
    template <typename T, typename ... Args>
    auto make_unique(Args&&... args)
    -> typename std::enable_if<!std::is_array<T>::value,
                    std::unique_ptr<T>>::type
    {
#if ${COMP_PREFIX}HAS_MAKE_UNIQUE
        return std::make_unique<T>(std::forward<Args>(args)...);
#else
        return std::unique_ptr<T>(new T(std::forward<Args>(args)...));
#endif
    }

    template<class T>
    auto make_unique(std::size_t size)
    -> typename std::enable_if<std::is_array<T>::value,
                           std::unique_ptr<T>>::type
    {
#if ${COMP_PREFIX}HAS_MAKE_UNIQUE
        return std::make_unique<T>(size);
#else
        return std::unique_ptr<T>(new typename std::remove_extent<T>::type[size]());
#endif
    }
}" COMP_CPP11_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(make_unique __cpp_lib_make_unique 201304)
endif()
