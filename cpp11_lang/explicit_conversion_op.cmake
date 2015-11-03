# Copyright (C) 2015 Jonathan M�üler <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("struct foo
                    {
                        explicit operator int() {return 5;}
                        explicit operator bool() {return true;}
                    };
                    int main()
                    {
                        foo f;
                        int i = static_cast<int>(f);
                        bool b = static_cast<bool>(f);
                        if (f) {}
                    }"
                   explicit_conversion_op "${cpp11_flag}")
comp_gen_header(explicit_conversion_op "")