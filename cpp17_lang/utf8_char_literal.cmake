# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("int main() {char c = u8'A';}"
                   utf8_char_literal "${cpp17_flag}")
comp_gen_header(utf8_char_literal
"
#ifndef ${COMP_PREFIX}UTF8_CHAR_LITERAL
    #define ${COMP_PREFIX}UTF8_CHAR_LITERAL_IMPL(Str) u8##Str[0]
    #define ${COMP_PREFIX}UTF8_CHAR_LITERAL(Str) ${COMP_PREFIX}UTF8_CHAR_LITERAL_IMPL(Str)
#endif
")
