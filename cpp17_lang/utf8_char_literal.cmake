# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(utf8_char_literal "int main() {char c = u8'A';}" COMP_CPP17_FLAG)
comp_workaround(utf8_char_literal
"#ifndef ${COMP_PREFIX}UTF8_CHAR_LITERAL
    #define ${COMP_PREFIX}UTF8_CHAR_LITERAL_IMPL(Str) u8##Str[0]
    #define ${COMP_PREFIX}UTF8_CHAR_LITERAL(Str) ${COMP_PREFIX}UTF8_CHAR_LITERAL_IMPL(Str)
#endif" COMP_CPP11_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(utf8_char_literal __cpp_unicode_characters 201411)
endif()
