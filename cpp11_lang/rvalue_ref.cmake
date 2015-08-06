# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("int main(){int&& rvalue = 5;}" rvalue_ref "${cpp11_flag}")
comp_gen_header(rvalue_ref "")