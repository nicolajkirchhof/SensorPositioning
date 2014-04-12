#include <boost/range.hpp>
#include <iterator>         // for std::iterator_traits, std::distance()

namespace Foo
{
    //
    // Our sample UDT. A 'Pair'
    // will work as a range when the stored
    // elements are iterators.
    //
    template< class T >
    struct Pair
    {
        T first, last;
    };

} // namespace 'Foo'

namespace boost
{
    //
    // Specialize metafunctions. We must include the range.hpp header.
    // We must open the 'boost' namespace.
    //

	template< class T >
	struct range_mutable_iterator< Foo::Pair<T> >
	{
		typedef T type;
	};

	template< class T >
	struct range_const_iterator< Foo::Pair<T> >
	{
		//
		// Remark: this is defined similar to 'range_iterator'
		//         because the 'Pair' type does not distinguish
		//         between an iterator and a const_iterator.
		//
		typedef T type;
	};

} // namespace 'boost'

namespace Foo
{
	//
	// The required functions. These should be defined in
	// the same namespace as 'Pair', in this case
	// in namespace 'Foo'.
	//

	template< class T >
	inline T range_begin( Pair<T>& x )
	{
		return x.first;
	}

	template< class T >
	inline T range_begin( const Pair<T>& x )
	{
		return x.first;
	}

	template< class T >
	inline T range_end( Pair<T>& x )
	{
		return x.last;
	}

	template< class T >
	inline T range_end( const Pair<T>& x )
	{
		return x.last;
	}

} // namespace 'Foo'

#include <vector>

int main(int argc, const char* argv[])
{
	typedef std::vector<int>::iterator  iter;
	std::vector<int>                    vec;
	Foo::Pair<iter>                     pair = { vec.begin(), vec.end() };
	const Foo::Pair<iter>&              cpair = pair;
	//
	// Notice that we call 'begin' etc with qualification.
	//
	iter i = boost::begin( pair );
	iter e = boost::end( pair );
	i      = boost::begin( cpair );
	e      = boost::end( cpair );
	boost::range_difference< Foo::Pair<iter> >::type s = boost::size( pair );
	s      = boost::size( cpair );
	boost::range_reverse_iterator< const Foo::Pair<iter> >::type
	ri     = boost::rbegin( cpair ),
	re     = boost::rend( cpair );

	return 0;
}

