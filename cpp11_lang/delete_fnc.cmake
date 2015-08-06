# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("struct foo
                    {
                        foo(const foo&) = delete;
                    };
                    int main(){}"
                   delete_fnc "${cpp11_flag}")
comp_gen_header(delete_fnc "")
