# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("template <typename A, typename B> struct foo {};
                    template <typename A> using bar = foo<A, int>;
                    int main(){}" alias_template "${cpp11_flag}")
comp_gen_header(alias_template "")
