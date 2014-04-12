
#ifndef BPOLY_BOOST_EXTENSIONS_STRATEGIE_REMOVE_TOUCHES_NICO
#define BPOLY_BOOST_EXTENSIONS_STRATEGIE_REMOVE_TOUCHES_NICO

#include <algorithm>
#include <deque>

#include <boost/range.hpp>
#include <boost/typeof/typeof.hpp>
#include <boost/math/constants/constants.hpp>

#include <boost/geometry/multi/core/tags.hpp>

#include <boost/geometry/core/coordinate_type.hpp>
#include <boost/geometry/core/point_type.hpp>
#include <boost/geometry/core/cs.hpp>
#include <boost/geometry/core/interior_rings.hpp>
#include <boost/geometry/geometries/concepts/check.hpp>
#include <boost/geometry/geometries/point_xy.hpp>
#include <boost/geometry/strategies/side.hpp>
#include <boost/geometry/util/math.hpp>

#include <boost/geometry/algorithms/area.hpp>
#include <boost/geometry/algorithms/distance.hpp>
#include <boost/geometry/algorithms/perimeter.hpp>
#include <boost/geometry/algorithms/touches.hpp>
#include <boost/geometry/algorithms/convert.hpp>

#include <boost/geometry/iterators/ever_circling_iterator.hpp>

#include <boost/geometry/geometries/ring.hpp>
#include <boost/geometry/geometries/segment.hpp>

#include <boost/operators.hpp>

#include <cmath>

namespace boost {
namespace geometry {

#ifndef DOXYGEN_NO_DETAIL
namespace detail {
namespace remove_touch {


template <typename Range, typename RangeOut, typename Policy>
struct range_remove_touch {
    typedef typename strategy::side::services::default_strategy
    <
    typename cs_tag<Range>::type
    >::type side_strategy_type;

    typedef typename coordinate_type<RangeOut>::type coordinate_type;
    typedef typename point_type<RangeOut>::type point_type;

    typedef model::referring_segment<const point_type> segment_type;


    static inline void apply(Range const &range, RangeOut &range_out, Policy const &policy) {
        std::size_t n = boost::size(range);

        if(n < 3) {
            return;
        }

        convert(range, range_out);

        bool is_closed = boost::geometry::closure<RangeOut>::value == boost::geometry::closed;

        //typedef typename boost::range_const_iterator<RangeOut>::type const_iterator;
        typedef typename boost::range_iterator<RangeOut>::type iterator;

        ever_circling_iterator<iterator> it(boost::begin(range_out), boost::end(range_out), true);
        ever_circling_iterator<iterator> next(boost::begin(range_out), boost::end(range_out), true);
        //ever_circling_iterator<iterator> prev(boost::begin(range_out), boost::end(range_out), true);

        ever_circling_iterator<iterator> tst_it(boost::begin(range_out), boost::end(range_out), true);
        ever_circling_iterator<iterator> tst_next(boost::begin(range_out), boost::end(range_out), true);
        ever_circling_iterator<iterator> tst_prev(boost::begin(range_out), boost::end(range_out), true);

        // If it is "closed", the iterator automatically skips the last (or actually the first coming after last) one.
        if(is_closed)
        { n--; }

        it++;
        next++;
        next++;

        bool needs_closing = false;

        for(std::size_t i = 0;
                i < n;
                ++i, ++it, ++next) {
            segment_type seg(*it, *next);
            tst_prev = next;
            tst_it = next; tst_it++;
            tst_next = tst_it; tst_next++;

            // cycle trough polygon and find touches
            while (tst_next != it) {
                policy(seg, *tst_prev, *tst_it, *tst_next);
                ++tst_prev; ++tst_it; ++tst_next;
            }


            // move next



            //if(i == n - 1) {
            //    if(vertices.size() > 0) {
            //        // move next to appropriate value in second run through
            //        for(int ii = 1; ii < vertices[0]; ++ii, ++next)
            //            ;
            //    } else // all points are invalid
            //    { break; }
            //}

            //if(!policy(*prev, *it, *next)) {
            //    // It is not collinear, middle point (i == 1) will be kept
            //    vertices.push_back(i + 1);
            //    prev = it;
            //}
        }

        // only if we have a polygon left we need to copy
        //if (boost::size(vertices) > 2) {
        //    for(std::deque<std::size_t>::iterator fit = vertices.begin();
        //            fit != vertices.end(); ++fit) {
        //        bg::append<Range, typename point_type<Range>::type >(range_out, *(range.begin() + *fit));
        //    }

        //    if(is_closed)
        //    { range_out.push_back(range_out.front()); }
        //}
    }
};


template <typename Polygon, typename PolygonOut, typename Policy>
struct polygon_remove_touch {
    static inline void apply(Polygon const &polygon, PolygonOut &polygon_out, Policy const &policy) {
        typedef typename geometry::ring_type<Polygon>::type ring_type;
        typedef typename geometry::ring_type<PolygonOut>::type ring_type_out;

        ring_type_out r_out;
        typedef range_remove_touch<ring_type, ring_type_out, Policy> per_range;
        per_range::apply(exterior_ring(polygon), r_out, policy);
        geometry::append(polygon_out, r_out);

        // if outer ring is empty we do not need to check inner rings
        if(geometry::num_points(r_out) == 0)
        { return; }

        typename interior_return_type<const Polygon>::type rings = interior_rings(polygon);
        typename interior_return_type<PolygonOut>::type rings_out = interior_rings(polygon_out);

        //interior_rings(polygon_out).resize(num_interior_rings(polygon));

        //BOOST_AUTO_TPL(it_out, boost::begin(rings_out));

        for(BOOST_AUTO_TPL(it, boost::begin(rings)); it != boost::end(rings); ++it) {
            ring_type_out r_tmp;
            per_range::apply(*it, r_tmp, policy);

            //++it_out;
            if(geometry::num_points(r_tmp) > 0)
            { rings_out.push_back(r_tmp); }
        }
    }
};


template <typename MultiGeometry, typename MultiGeometryOut, typename Policy, typename SinglePolicy>
struct multi_remove_touch {
    static inline void apply(MultiGeometry const &multi, MultiGeometryOut &multi_out, Policy const &policy) {
        for(typename boost::range_const_iterator<MultiGeometry>::type
                it = boost::begin(multi);
                it != boost::end(multi);
                ++it) {
            typename boost::range_value<MultiGeometryOut>::type pout;
            SinglePolicy::apply(*it, pout, policy);

            if(geometry::num_points(geometry::exterior_ring(pout)) > 0)
            { multi_out.push_back(pout); }
        }
    }
};


}
} // namespace detail::remove_touch
#endif // DOXYGEN_NO_DETAIL



#ifndef DOXYGEN_NO_DISPATCH
namespace dispatch {


template
<
typename Tag,
         typename Geometry,
         typename GeometryOut,
         typename Policy
         >
struct remove_touch {
    static inline void apply(Geometry const &, GeometryOut &, Policy const &)
    {}
};


template <typename Ring, typename RingOut, typename Policy>
struct remove_touch<ring_tag, Ring, RingOut, Policy>
        : detail::remove_touch::range_remove_touch<Ring, RingOut, Policy>
{};


template <typename Polygon, typename PolygonOut, typename Policy>
struct remove_touch<polygon_tag, Polygon, PolygonOut, Policy>
        : detail::remove_touch::polygon_remove_touch<Polygon, PolygonOut, Policy>
{};


template <typename MultiPolygon, typename MultiPolygonOut, typename Policy>
struct remove_touch<multi_polygon_tag, MultiPolygon, MultiPolygonOut, Policy>
        : detail::remove_touch::multi_remove_touch
        <
        MultiPolygon,
        MultiPolygonOut,
        Policy,
        detail::remove_touch::polygon_remove_touch
        <
        typename boost::range_value<MultiPolygon>::type,
        typename boost::range_value<MultiPolygonOut>::type,
        Policy
        >
        >
{};



} // namespace dispatch
#endif


/*!
    \ingroup remove_touch
    \tparam Geometry geometry type
    \param geometry the geometry to make remove_touch
*/
template <typename Geometry, typename GeometryOut, typename Policy>
inline void remove_touch(Geometry const &geometry, GeometryOut &geometry_out, Policy const &policy)
{
    concept::check<Geometry>();
    concept::check<GeometryOut>();

    dispatch::remove_touch
    <
    typename tag<Geometry>::type,
             Geometry,
             GeometryOut,
             Policy
             >::apply(geometry, geometry_out, policy);
}
//
//
//
//template <typename Point>
//struct remove_elongated_spikes {
//    typedef typename coordinate_type<Point>::type coordinate_type;
//    coordinate_type m_area_div_peri;
//    coordinate_type m_dist_div_peri;
//    coordinate_type m_area_limit;
//    coordinate_type m_distance_limit;
//    coordinate_type m_zero;
//
//
//    inline remove_elongated_spikes(coordinate_type const &area_div_peri = 0.001
//                                   , coordinate_type const &dist_div_peri = 0.001
//                                           , coordinate_type const &area_limit = 0.01
//                                                   , coordinate_type const &distance_limit = 1
//                                  )
//        : m_area_div_peri(area_div_peri)
//        , m_dist_div_peri(dist_div_peri)
//        , m_area_limit(area_limit)
//        , m_distance_limit(distance_limit)
//        , m_zero(coordinate_type())
//    {}
//
//
//    inline bool operator()(Point const &prev,
//                           Point const &current, Point const &next) const {
//        coordinate_type d1 = geometry::distance(prev, current);
//
//        if(d1 < m_distance_limit) {
//            geometry::model::ring<Point> triangle;
//            triangle.push_back(prev);
//            triangle.push_back(current);
//            triangle.push_back(next);
//            triangle.push_back(prev);
//
//            coordinate_type p = geometry::perimeter(triangle);
//
//            if(p > m_zero) {
//                coordinate_type a = geometry::math::abs(geometry::area(triangle));
//                coordinate_type prop1 = a / p;
//                coordinate_type prop2 = d1 / p;
//
//                bool remove = prop1 < m_area_div_peri
//                              && prop2 < m_dist_div_peri
//                              && a < m_area_limit;
//
//                /*
//                {
//                    coordinate_type d2 = geometry::distance(prev, next);
//                    std::cout << std::endl;
//                    std::cout << "Distance1: "  << d1 << std::endl;
//                    std::cout << "Distance2: "  << d2 << std::endl;
//                    std::cout << "Area:      "  << a << std::endl;
//                    std::cout << "Perimeter: "  << p << std::endl;
//                    std::cout << "Prop1:     "  << prop1 << std::endl;
//                    std::cout << "Prop2:     "  << prop2 << std::endl;
//                    std::cout << "Remove:    "  << (remove ? "true" : "false") << std::endl;
//                }
//                */
//
//                return remove;
//            }
//        }
//
//        return false;
//    }
//};

template <typename T> int sgn(T val)
{
    return (T(0) < val) - (val < T(0));
};

namespace constants {
            const double  d_zero = 0.0;
    const double pi = boost::math::constants::pi<double>();
const double pi_8 = boost::math::constants::pi<double>() / 8;
const double pi_3_8 = 3 * pi_8;
const double pi_5_8 = 5 * pi_8;
const double pi_7_8 = 7 * pi_8;
}

template <typename Point>
class remove_by_move_inside {
        typedef typename coordinate_type<Point>::type coordinate_type;
        coordinate_type m_zero;
        coordinate_type grid_limit;
        typedef model::referring_segment<const Point> segment_type;
        //typedef model::referring_segment<const Point> const_segment_type;
        double grid_limit_2;
        bool ignore_dist;

    public :
        inline remove_by_move_inside(coordinate_type const &gl, bool const &ignore_distance = false)
            : m_zero(coordinate_type()),
            grid_limit(gl), grid_limit_2(((double)gl)/2), ignore_dist(ignore_distance)
        {}

        inline void operator()(segment_type const &seg, Point const &prev,
                               Point &current, Point const &next) const {
            if (!ignore_dist && bg::distance(seg, current) > grid_limit)
            { return; }
            
            typedef model::d2::point_xy<double> point_dbl;

            // calculate vector that points inside of polygon
            // in essence this is vi = prev + next - 2*current
           
            Point vi;
            point_dbl vi_dbl, current_dbl, zero_pt(constants::d_zero, constants::d_zero);
            assign_point(vi, current);
            multiply_value(vi, -2);
            add_point(vi, prev);
            add_point(vi, next);
            
            // copy to double to ensure calculation works
            assign_point(vi_dbl, vi);
            assign_point(current_dbl, current);

            // calculate unit vector and multiply with grid size
            double length_vi = distance(zero_pt, vi_dbl);
            divide_value(vi_dbl, length_vi);
            multiply_value(vi_dbl, (double)grid_limit);

            // check if segments intersect
            segment_type s_pc(prev, current);
            segment_type s_cn(prev, current);

            while(bg::intersects(seg, s_pc) || bg::intersects(seg, s_cn))
            {
            // moves the point to the other side of the segment
            double dist = (double)(bg::distance(seg, current)+grid_limit);
            point_dbl move_to_seg(vi_dbl);
            bg::multiply_value(move_to_seg, dist);
            add_point(current_dbl, move_to_seg);
            assign_point(current, current_dbl);
            }
            
            // idea: increase distance to line by using increasing grid distances
            while (bg::distance(seg, current) < grid_limit);{
                add_point(current_dbl, vi_dbl);
                assign_point(current, current_dbl);
            } 
            }
        };
}
} //namespace boost::geometry

#endif //BPOLY_BOOST_EXTENSIONS_STRATEGIE_REMOVE_TOUCHES_NICO