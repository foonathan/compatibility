# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(exception_support
                    "#include <cstddef>

                    #if defined(__GNUC__) && !defined(__EXCEPTIONS)
                        #error \"no exception support\"
                    #elif defined(_MSC_VER) && !_HAS_EXCEPTIONS
                        #error \"no exception support\"
                    #endif

                    struct my_exception {};
                    int main()
                    {
                        try
                        {
                            throw my_exception();
                        }
                        catch (my_exception&) {}
                        catch (...) {}
                    }" COMP_CPP98_FLAG)
comp_workaround(exception_support
"#include <cstdlib>

#ifndef ${COMP_PREFIX}THROW
    #if ${COMP_PREFIX}HAS_EXCEPTION_SUPPORT
        #define ${COMP_PREFIX}THROW(Ex) throw (Ex)
    #else
        #define ${COMP_PREFIX}THROW(Ex) (Ex), std::abort()
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
" COMP_CPP98_FLAG)

