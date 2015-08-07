# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

# small, dumb program using exceptions
comp_check_feature("struct my_exception {};
                    int main()
                    {
                        try
                        {
                            throw my_exception();
                        }
                        catch (my_exception&) {}
                        catch (...) {}
                    }" exception_support "")
comp_gen_header(exception_support
"
#include <cstdlib>

#ifndef ${COMP_PREFIX}THROW
    #if ${COMP_PREFIX}HAS_EXCEPTION_SUPPORT
        #define ${COMP_PREFIX}THROW(Ex) throw (Ex)
    #else
        #define ${COMP_PREFIX}THROW(Ex) std::abort()
    #endif
#endif

#ifndef ${COMP_PREFIX}RETHROW
    #if ${COMP_PREFIX}HAS_EXCEPTION_SUPPORT
        #define ${COMP_PREFIX}RETHROW throw
    #else
        #define ${COMP_PREFIX}RETHROW std::abort()
    #endif
#endif

#ifndef ${COMP_PREFIX}TRY
    #if ${COMP_PREFIX}HAS_EXCEPTION_SUPPORT
        #define ${COMP_PREFIX}TRY try
    #else
        #define ${COMP_PREFIX}TRY if (true)
    #endif
#endif

#ifndef ${COMP_PREFIX}CATCH_ALL
    #if ${COMP_PREFIX}HAS_EXCEPTION_SUPPORT
        #define ${COMP_PREFIX}CATCH_ALL catch(...)
    #else
        #define ${COMP_PREFIX}CATCH_ALL if (false)
    #endif
#endif
")

