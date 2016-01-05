# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(invoke "#include <functional>
                    void foo() {}
                    int main()
                    {
                        std::invoke(foo);
                    }" COMP_CPP17_FLAG)
comp_workaround(invoke
"#include <functional>
#include <type_traits>

// see http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2014/n4169.html
namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_INVOKE
    using std::invoke;
#else
  template<typename Functor, typename... Args>
  typename std::enable_if<
    std::is_member_pointer<typename std::decay<Functor>::type>::value,
    typename std::result_of<Functor&&(Args&&...)>::type
  >::type invoke(Functor&& f, Args&&... args)
  {
    return std::mem_fn(f)(std::forward<Args>(args)...);
  }

  template<typename Functor, typename... Args>
  typename std::enable_if<
    !std::is_member_pointer<typename std::decay<Functor>::type>::value,
    typename std::result_of<Functor&&(Args&&...)>::type
  >::type invoke(Functor&& f, Args&&... args)
  {
    return std::forward<Functor>(f)(std::forward<Args>(args)...);
  }
#endif
}" COMP_CPP11_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(invoke __cpp_lib_invoke 201411)
endif()
