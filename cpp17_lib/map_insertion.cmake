# Copyright (C) 2015-2016 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(map_insertion
                    "#include <map>
                    int main()
                    {
                        std::map<int, int> m;
                        m.try_emplace(5, 5);
                        m.insert_or_assign(10, 5);
                    }" COMP_CPP17_FLAG)
comp_workaround(map_insertion
"#include <utility>

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
        typename Map::iterator iter = m.find(key);
        if (iter != m.end())
            return {iter, false};
        return m.insert(typename Map::value_type(std::forward<Key>(key), std::forward<Args>(args)...));
    }

    template <class Map, typename Key, typename ... Args>
    typename Map::iterator
        try_emplace(Map &m, typename Map::const_iterator hint, Key &&key, Args&&... args)
    {
        typename Map::iterator iter = m.find(key);
        if (iter != m.end())
            return iter;
        return m.insert(hint, typename Map::value_type(std::forward<Key>(key), std::forward<Args>(args)...)).first;
    }

    template <class Map, typename Key, typename M>
    std::pair<typename Map::iterator, bool>
        insert_or_assign(Map &m, Key &&key, M &&obj)
    {
        typename Map::iterator iter = m.find(key);
        if (iter != m.end())
        {
            iter->second = std::forward<M>(obj);
            return {iter, false};
        }
        return m.insert(typename Map::value_type(std::forward<Key>(key), std::forward<M>(obj)));
    }

    template <class Map, typename Key, typename M>
    typename Map::iterator
        insert_or_assign(Map &m, typename Map::const_iterator hint, Key &&key, M &&obj)
    {
        typename Map::iterator iter = m.find(key);
        if (iter != m.end())
        {
            iter->second = std::forward<M>(obj);
            return iter;
        }
        m.insert(hint, typename Map::value_type(std::forward<Key>(key), std::forward<M>(obj))).first;
    }
#endif
}" COMP_CPP11_FLAG)

if(COMP_API_VERSION VERSION_GREATER 1.0)
    comp_sd6_macro(map_insertion __cpp_lib_map_insertion 201411)
    comp_sd6_macro(map_insertion __cpp_lib_unordered_map_insertion 201411)
    comp_sd6_macro(map_insertion __cpp_lib_map_try_emplace 201411)
    comp_sd6_macro(map_insertion __cpp_lib_unordered_map_try_emplace 201411)
endif()

comp_unit_test(map_insertion
"
#include <map>
"
"
std::map<int, int> map;
auto res = ${COMP_NAMESPACE}::try_emplace(map, 0, 0);
REQUIRE(res.second == true);
REQUIRE(res.first->second == 0);

res = ${COMP_NAMESPACE}::try_emplace(map, 0, 1);
REQUIRE(res.second == false);
REQUIRE(res.first->second == 0);

res = ${COMP_NAMESPACE}::insert_or_assign(map, 1, 1);
REQUIRE(res.second == true);
REQUIRE(res.first->second == 1);

res = ${COMP_NAMESPACE}::insert_or_assign(map, 1, 2);
REQUIRE(res.second == false);
REQUIRE(res.first->second == 2);
")