# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("#include <exception>
					int main()
					{
						int count = std::uncaught_exceptions();
					}" uncaught_exceptions "${cpp17_flag}")
comp_gen_header(uncaught_exceptions "")
