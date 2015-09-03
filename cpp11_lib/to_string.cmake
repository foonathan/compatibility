# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("#include <string>
                    int main()
                    {
                        std::to_string(5);
                        std::to_string(5ul);
                        std::to_string(5.0);
                    }" to_string "${cpp11_flag}")
comp_gen_header(to_string
"
#include <string>

#if !${COMP_PREFIX}HAS_TO_STRING
    #include <cfloat>
    #include <cstdio>
#endif

namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_TO_STRING
    using std::to_string;
#else
    std::string to_string(int value)
    {
        char buf[4 * sizeof(value)];
        std::sprintf(buf, \"%d\", value);
        return buf;
    }

    std::string to_string(long value)
    {
        char buf[4 * sizeof(value)];
        std::sprintf(buf, \"%ld\", value);
        return buf;
    }

    std::string to_string(long long value)
    {
        char buf[4 * sizeof(value)];
        std::sprintf(buf, \"%lld\", value);
        return buf;
    }

    std::string to_string(unsigned value)
    {
        char buf[4 * sizeof(value)];
        std::sprintf(buf, \"%u\", value);
        return buf;
    }

    std::string to_string(unsigned long value)
    {
        char buf[4 * sizeof(value)];
        std::sprintf(buf, \"%lu\", value);
        return buf;
    }

    std::string to_string(unsigned long long value)
    {
        char buf[4 * sizeof(value)];
        std::sprintf(buf, \"%llu\", value);
        return buf;
    }
    
    std::string to_string(float value)
    {
        char buf[FLT_MAX_10_EXP + 20];
        std::sprintf(buf, \"%f\", value);
        return buf;
    }

    std::string to_string(double value)
    {
        char buf[DBL_MAX_10_EXP + 20];
        std::sprintf(buf, \"%f\", value);
        return buf;
    }
    
    std::string to_string(long double value)
    {
        char buf[LDBL_MAX_10_EXP + 20];
        std::sprintf(buf, \"%fL\", value);
        return buf;
    }
#endif
}
"
)
