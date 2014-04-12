#include <iostream>
#include <vector>
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/foreach.hpp>
#include <boost/iterator/iterator_facade.hpp>
#include <boost/range.hpp>

struct Point
{
    Point(double x, double y) : x(x), y(y) {}
    double x, y;
};

struct Line {std::vector<Point> points;};

struct Ring {std::vector<Line> lines;};


/* Custom iterator type that flattens a 2D array into a 1D array */
template <class I, // Line iterator type
          class R  // Point reference type
         >
class RingIteratorImpl : public boost::iterator_facade<
        RingIteratorImpl<I,R>, Point, boost::forward_traversal_tag, R>
{
public:
    RingIteratorImpl() : lineIter_(0), pointIndex_(0) {}

    explicit RingIteratorImpl(I lineIter)
    :   lineIter_(lineIter), pointIndex_(0) {}

private:
    friend class boost::iterator_core_access;

    void increment()
    {
        ++pointIndex_;
        if (pointIndex_ >= lineIter_->points.size())
        {
            ++lineIter_;
            pointIndex_ = 0;
        }
    }

    bool equal(const RingIteratorImpl& other) const
    {
        return (lineIter_ == other.lineIter_) &&
               (pointIndex_ == other.pointIndex_);
    }

    R dereference() const {return lineIter_->points[pointIndex_];}

    I lineIter_;
    size_t pointIndex_;
};

typedef RingIteratorImpl<std::vector<Line>::iterator, Point&> RingIterator;
typedef RingIteratorImpl<std::vector<Line>::const_iterator, const Point&>
        ConstRingIterator;

namespace boost
{
    // Specialize metafunctions. We must include the range.hpp header.
    // We must open the 'boost' namespace.

    template <>
    struct range_mutable_iterator<Ring> { typedef RingIterator type; };

    template<>
    struct range_const_iterator<Ring> { typedef ConstRingIterator type; };

} // namespace 'boost'


// The required Range functions. These should be defined in the same namespace
// as Ring.

inline RingIterator range_begin(Ring& r)
    {return RingIterator(r.lines.begin());}

inline ConstRingIterator range_begin(const Ring& r)
    {return ConstRingIterator(r.lines.begin());}

inline RingIterator range_end(Ring& r)
    {return RingIterator(r.lines.end());}

inline ConstRingIterator range_end(const Ring& r)
    {return ConstRingIterator(r.lines.end());}


int main()
{
    Line l1, l2;
    Ring ring;

    {
        using namespace boost::assign; // bring 'operator+=()' into scope
        typedef Point P;
        l1.points += P(1.1,1.2), P(1.3,1.4), P(1.5,1.6);
        l2.points += P(2.1,2.2), P(2.3,2.4), P(2.5,2.6);
        ring.lines += l1, l2;
    }

    // Boost Foreach treats ring as a Boost Range.
    BOOST_FOREACH(Point p, ring)
    {
        std::cout << "(" << p.x << ", " << p.y << ") ";
    }
    std::cout << "\n";
}