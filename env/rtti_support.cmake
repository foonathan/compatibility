# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

# small, dumb program using rtti
comp_check_feature("#include <typeinfo>
                    struct a {virtual ~a() {}};
                    struct b : a {};
                    int main()
                    {
                        a *ptr = new b;
                        b *b_ptr = dynamic_cast<b*>(ptr);
                        bool res = typeid(*b_ptr) == typeid(*ptr);
                    }" rtti_support "")
comp_gen_header(rtti_support
"
namespace ${COMP_NAMESPACE}
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
}
")
