# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("constexpr int foo() {int i = 0; return i;} int main() {}"
                   general_constexpr "${cpp14_flag}")
comp_gen_header(general_constexpr "")
