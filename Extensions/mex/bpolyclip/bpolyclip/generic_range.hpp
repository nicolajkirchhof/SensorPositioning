//#include "stdafx.h"

namespace bg = boost::geometry;

namespace generic_range {
//
// Our sample UDT. A 'Pair'
// will work as a range when the stored
// elements are iterators.
//
template< class T >
struct Pair {
    T first, last;

};

} // namespace 'generic_range'

namespace boost {
//
// Specialize metafunctions. We must include the range.hpp header.
// We must open the 'boost' namespace.
//

template< class T >
struct range_mutable_iterator< generic_range::Pair<T> > {
    typedef T type;
};

template< class T >
struct range_const_iterator< generic_range::Pair<T> > {
    //
    // Remark: this is defined similar to 'range_iterator'
    //         because the 'Pair' type does not distinguish
    //         between an iterator and a const_iterator.
    //
    typedef T type;
};

} // namespace 'boost'
namespace generic_range {
//
// The required functions. These should be defined in
// the same namespace as 'Pair', in this case
// in namespace 'generic_range'.
//

template< class T >
inline T range_begin(Pair<T> &x)
{
    return x.first;
}

template< class T >
inline T range_begin(const Pair<T> &x)
{
    return x.first;
}

template< class T >
inline T range_end(Pair<T> &x)
{
    return x.last;
}

template< class T >
inline T range_end(const Pair<T> &x)
{
    return x.last;
}

} // namespace 'generic_range'
