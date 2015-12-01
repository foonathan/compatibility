# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("#include <functional>
					void foo() {}
					int main()
					{
						std::invoke(foo);
					}" invoke "${cpp17_flag}")
comp_gen_header(invoke
"
#include <functional>
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
}
")
