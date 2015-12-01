# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

comp_check_feature("#include <map>
                    int main()
                    {
                        std::map<int, int> m;
                        m.try_emplace(5, 5);
                        m.insert_or_assign(10, 5);
                    }"
                    map_insertion "${cpp17_flag}")
comp_gen_header(map_insertion
"
namespace ${COMP_NAMESPACE}
{
#if ${COMP_PREFIX}HAS_MAP_INSERTION
    template <class Map, typename Key, typename ... Args>
    std::pair<typename Map::iterator, bool>
        try_emplace(Map &m, Key &&key, Args&&... args)
    {
        return m.try_emplace(std::forward<Key>(key), std::forward<Args>(args)...);
    }

    template <class Map, typename Key, typename ... Args>
    typename Map::iterator
        try_emplace(Map &m, typename Map::const_iterator hint, Key &&key, Args&&... args)
    {
        return m.try_emplace(hint, std::forward<Key>(key), std::forward<Args>(args)...);
    }

    template <class Map, typename Key, typename M>
    std::pair<typename Map::iterator, bool>
        insert_or_assign(Map &m, Key &&key, M &&obj)
    {
        return m.insert_or_assign(std::forward<Key>(key), std::forward<M>(obj));
    }

    template <class Map, typename Key, typename M>
    typename Map::iterator
        insert_or_assign(Map &m, typename Map::const_iterator hint, Key &&key, M &&obj)
    {
        return m.insert_or_assign(hint, std::forward<Key>(key), std::forward<M>(obj));
    }
#else
    template <class Map, typename Key, typename ... Args>
    std::pair<typename Map::iterator, bool>
        try_emplace(Map &m, Key &&key, Args&&... args)
    {
        auto iter = m.find(key);
        if (iter != m.end())
            return {iter, false};
        iter = m.insert(typename Map::value_type(std::forward<Key>(key), std::forward<Args>(args)...));
        return {iter, true};
    }

    template <class Map, typename Key, typename ... Args>
    typename Map::iterator
        try_emplace(Map &m, typename Map::const_iterator hint, Key &&key, Args&&... args)
    {
        auto iter = m.find(key);
        if (iter != m.end())
            return iter;
        iter = m.insert(hint, typename Map::value_type(std::forward<Key>(key), std::forward<Args>(args)...));
        return iter;
    }

    template <class Map, typename Key, typename M>
    std::pair<typename Map::iterator, bool>
        insert_or_assign(Map &m, Key &&key, M &&obj)
    {
        auto iter = m.find(key);
        if (iter != m.end())
        {
            iter->second = std::forward<M>(obj);
            return {iter, false};
        }
        iter = m.insert(typename Map::value_type(std::forward<Key>(key), std::forward<M>(m)));
        return {iter, true};
    }

    template <class Map, typename Key, typename M>
    typename Map::iterator
        insert_or_assign(Map &m, typename Map::const_iterator hint, Key &&key, M &&obj)
    {
        auto iter = m.find(key);
        if (iter != m.end())
        {
            iter->second = std::forward<M>(obj);
            return iter;
        }
        iter = m.insert(hint, typename Map::value_type(std::forward<Key>(key), std::forward<M>(m)));
        return iter;
    }
#endif
}
")