# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("#include <type_traits>
					int main()
					{
						std::void_t<int, char> *ptr;
					}"
					void_t "${cpp17_flag}")
comp_gen_header(void_t
"
// see proposal: http://www.open-std.org/JTC1/sc22/WG21/docs/papers/2014/n3911.pdf
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
}
")
