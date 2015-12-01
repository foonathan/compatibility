# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("#include <type_traits>
					int main()
					{
						std::bool_constant b;
					}"
					bool_constant "${cpp17_flag}")
comp_gen_header(bool_constant
"
#include <type_traits>

namespace ${COMP_NAMESPACE}
{
	template <bool B>
	using bool_constant = std::integral_constant<bool, B>;

	typedef bool_constant<true> true_type;
	typedef bool_constant<false> false_type;
}
")
