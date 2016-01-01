# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(container_erasure
        "#include <experimental/deque>
        #include <experimental/forward_list>
        #include <experimental/list>
        #include <experimental/map>
        #include <experimental/set>
        #include <experimental/string>
        #include <experimental/unordered_map>
        #include <experimental/unordered_set>
        #include <experimental/vector>
        #include <vector>

        bool f() {return true;}

        int main()
        {
            std::vector<int> vec;
            std::experimental::erase(vec, 3);
            std::experimental::erase_if(vec, f);
        }" COMP_CPP17_FLAG)
comp_workaround(container_erasure
"
#include <deque>
#include <forward_list>
#include <list>
#include <map>
#include <set>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#if ${COMP_PREFIX}HAS_CONTAINER_ERASURE
    #include <experimental/deque>
    #include <experimental/forward_list>
    #include <experimental/list>
    #include <experimental/map>
    #include <experimental/set>
    #include <experimental/string>
    #include <experimental/unordered_map>
    #include <experimental/unordered_set>
    #include <experimental/vector>
#else
    #include <algorithm>
#endif

namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_CONTAINER_ERASURE
    using std::experimental::erase;
    using std::experimental::erase_if;
#else
    template <class C, class T, class A, class Pred>
    void erase_if(std::basic_string<C, T, A> &c, Pred p)
    {
        c.erase(std::remove_if(c.begin(), c.end(), p), c.end());
    }

    template <class T, class A, class Pred>
    void erase_if(std::deque<T, A> &c, Pred p)
    {
        c.erase(std::remove_if(c.begin(), c.end(), p), c.end());
    }

    template <class T, class A, class Pred>
    void erase_if(std::forward_list<T, A> &c, Pred p)
    {
        c.remove_if(p);
    }

    template <class T, class A, class Pred>
    void erase_if(std::list<T, A> &c, Pred p)
    {
        c.remove_if(p);
    }

    template <class T, class A, class Pred>
    void erase_if(std::vector<T, A> &c, Pred p)
    {
        c.erase(std::remove_if(c.begin(), c.end(), p), c.end());
    }

    namespace detail
    {
        template <class Container, class Pred>
        void erase_if_loop(Container &c, Pred p)
        {
            typename Container::iterator i = c.begin(), last = c.end();
            while (i != last)
            {
                if (p(*i))
                    i = c.erase(i);
                else
                    ++i;
            }
        }
    }

    template <class K, class T, class C, class A, class Pred>
    void erase_if(std::map<K, T, C, A> &c, Pred p)
    {
        detail::erase_if_loop(c, p);
    }

    template <class K, class T, class C, class A, class Pred>
    void erase_if(std::multimap<K, T, C, A> &c, Pred p)
    {
        detail::erase_if_loop(c, p);
    }

    template <class K, class C, class A, class Pred>
    void erase_if(std::set<K, C, A> &c, Pred p)
    {
        detail::erase_if_loop(c, p);
    }

    template <class K, class C, class A, class Pred>
    void erase_if(std::multiset<K, C, A> &c, Pred p)
    {
        detail::erase_if_loop(c, p);
    }

    template <class K, class T, class H, class E, class A, class Pred>
    void erase_if(std::unordered_map<K, T, H, E, A> &c, Pred p)
    {
        detail::erase_if_loop(c, p);
    }

    template <class K, class T, class H, class E, class A, class Pred>
    void erase_if(std::unordered_multimap<K, T, H, E, A> &c, Pred p)
    {
        detail::erase_if_loop(c, p);
    }

    template <class K, class H, class E, class A, class Pred>
    void erase_if(std::unordered_set<K, H, E, A> &c, Pred p)
    {
        detail::erase_if_loop(c, p);
    }

    template <class K, class H, class E, class A, class Pred>
    void erase_if(std::unordered_multiset<K, H, E, A> &c, Pred p)
    {
        detail::erase_if_loop(c, p);
    }

    template <class C, class T, class A, class U>
    void erase(std::basic_string<C, T, A> &c, const U &value)
    {
        c.erase(std::remove(c.begin(), c.end(), value), c.end());
    }

    template <class T, class A, class U>
    void erase(std::deque<T, A> &c, const U &value)
    {
        c.erase(std::remove(c.begin(), c.end(), value), c.end());
    }

    namespace detail
    {
        template <typename U>
        struct erase_value
        {
            const U *ptr;

            template <typename T>
            bool operator()(const T &val) const
            {
                return val == *ptr;
            }
        };
    }

    template <class T, class A, class U>
    void erase(std::forward_list<T, A> &c, const U &value)
    {
        c.remove_if(detail::erase_value<U>{&value});
    }

    template <class T, class A, class U>
    void erase(std::list<T, A> &c, const U &value)
    {
        c.remove_if(detail::erase_value<U>{&value});
    }

    template <class T, class A, class U>
    void erase(std::vector<T, A> &c, const U &value)
    {
        c.erase(std::remove(c.begin(), c.end(), value), c.end());
    }

    template <class K, class T, class C, class A, class U>
    void erase(std::map<K, T, C, A> &c, const U &value)
    {
        detail::erase_if_loop(c, detail::erase_value<U>{&value});
    }

    template <class K, class T, class C, class A, class U>
    void erase(std::multimap<K, T, C, A> &c, const U &value)
    {
        detail::erase_if_loop(c, detail::erase_value<U>{&value});
    }

    template <class K, class C, class A, class U>
    void erase(std::set<K, C, A> &c, const U &value)
    {
        detail::erase_if_loop(c, detail::erase_value<U>{&value});
    }

    template <class K, class C, class A, class U>
    void erase(std::multiset<K, C, A> &c, const U &value)
    {
        detail::erase_if_loop(c, detail::erase_value<U>{&value});
    }

    template <class K, class T, class H, class E, class A, class U>
    void erase(std::unordered_map<K, T, H, E, A> &c, const U &value)
    {
        detail::erase_if_loop(c, detail::erase_value<U>{&value});
    }

    template <class K, class T, class H, class E, class A, class U>
    void erase(std::unordered_multimap<K, T, H, E, A> &c, const U &value)
    {
        detail::erase_if_loop(c, detail::erase_value<U>{&value});
    }

    template <class K, class H, class E, class A, class U>
    void erase(std::unordered_set<K, H, E, A> &c, const U &value)
    {
        detail::erase_if_loop(c, detail::erase_value<U>{&value});
    }

    template <class K, class H, class E, class A, class U>
    void erase(std::unordered_multiset<K, H, E, A> &c, const U &value)
    {
        detail::erase_if_loop(c, detail::erase_value<U>{&value});
    }
#endif
}" COMP_CPP11_FLAG)
