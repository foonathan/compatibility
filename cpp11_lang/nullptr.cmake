# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("int main(){void *ptr = nullptr;}" nullptr "${cpp11_flag}")
comp_gen_header(nullptr
"
#ifndef ${COMP_PREFIX}NULLPTR
    #if ${COMP_PREFIX}HAS_NULLPTR
        #define ${COMP_PREFIX}NULLPTR nullptr

        namespace ${COMP_NAMESPACE}
        {
            typedef std::nullptr_t nullptr_t;
        }
    #else
        namespace ${COMP_NAMESPACE}
        {
            class nullptr_t
            {
            public:
                template<class T>
                inline operator T*() const
                { return 0; }

                template<class C, class T>
                inline operator T C::*() const
                { return 0; }

            private:
                void operator&() const;
            };
        }

        #define ${COMP_PREFIX}NULLPTR ${COMP_NAMESPACE}::nullptr_t()
    #endif
#endif
")