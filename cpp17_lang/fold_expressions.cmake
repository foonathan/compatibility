# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("template <typename ... Args>
					bool all(Args... args) {return (args && ...);}
					int main()
					{
						bool b = all(true, true, false, true);
					}"
                   fold_expressions "${cpp17_flag}")
comp_gen_header(fold_expressions "")
