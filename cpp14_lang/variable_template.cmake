# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("template <typename T> T def = T(); int main() {}"
                    variable_template "${cpp14_flag}")
comp_gen_header(variable_template "")