# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

# small, dumb program using rtti
comp_feature(rtti_support
                    "#include <typeinfo>
                    struct a {virtual ~a() {}};
                    struct b : a {};
                    int main()
                    {
                        a *ptr = new b;
                        b *b_ptr = dynamic_cast<b*>(ptr);
                        bool res = typeid(*b_ptr) == typeid(*ptr);
                    }" COMP_CPP98_FLAG)
comp_workaround(rtti_support
"namespace ${COMP_NAMESPACE}
{
    template <class Derived, class Base>
    Derived polymorphic_downcast(Base *ptr)
    {
    #if ${COMP_PREFIX}HAS_RTTI_SUPPORT
        return dynamic_cast<Derived>(ptr);
    #else
        return static_cast<Derived>(ptr);
    #endif
    }

    template <class Derived, class Base>
    Derived polymorphic_downcast(Base &ref)
    {
    #if ${COMP_PREFIX}HAS_RTTI_SUPPORT
        return dynamic_cast<Derived>(ref);
    #else
        return static_cast<Derived>(ref);
    #endif
    }
}" COMP_CPP98_FLAG)
