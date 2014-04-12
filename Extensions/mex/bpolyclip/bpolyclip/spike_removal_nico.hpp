
#ifndef BPOLY_BOOST_EXTENSIONS_STRATEGIE_REMOVE_BY_NORMALIZED_WITH_EPS
#define BPOLY_BOOST_EXTENSIONS_STRATEGIE_REMOVE_BY_NORMALIZED_WITH_EPS

#include <algorithm>
#include <deque>

#include <boost/range.hpp>
#include <boost/typeof/typeof.hpp>

#include <boost/geometry/multi/core/tags.hpp>


#include <boost/geometry/core/coordinate_type.hpp>
#include <boost/geometry/core/cs.hpp>
#include <boost/geometry/core/interior_rings.hpp>
#include <boost/geometry/geometries/concepts/check.hpp>
#include <boost/geometry/strategies/side.hpp>
#include <boost/geometry/util/math.hpp>

#include <boost/geometry/algorithms/area.hpp>
#include <boost/geometry/algorithms/distance.hpp>
#include <boost/geometry/algorithms/perimeter.hpp>

#include <boost/geometry/iterators/ever_circling_iterator.hpp>

#include <boost/geometry/geometries/ring.hpp>
#include <boost/geometry/geometries/segment.hpp>

#include <boost/operators.hpp>


namespace boost {
namespace geometry {

#ifndef DOXYGEN_NO_DETAIL
namespace detail {
namespace remove_spikes {


template <typename Range, typename RangeOut, typename Policy>
struct range_remove_spikes {
    typedef typename strategy::side::services::default_strategy
    <
    typename cs_tag<Range>::type
    >::type side_strategy_type;

    typedef typename coordinate_type<Range>::type coordinate_type;


    static inline void apply(Range const &range, RangeOut &range_out, Policy const &policy) {
        std::size_t n = boost::size(range);

        if(n < 3) {
            return;
        }

        bool is_closed = boost::geometry::closure<Range>::value==boost::geometry::closed;

        typedef typename boost::range_const_iterator<Range>::type const_iterator;
        ever_circling_iterator<const_iterator> it(boost::begin(range), boost::end(range), true);
        ever_circling_iterator<const_iterator> next(boost::begin(range), boost::end(range), true);
        ever_circling_iterator<const_iterator> prev(boost::begin(range), boost::end(range), true);

        // If it is "closed", the iterator automatically skips the last (or actually the first coming after last) one.
        if(is_closed)
            n--;

        it++;
        next++;
        next++;

        bool needs_closing = false;

        std::deque<std::size_t> vertices;

        for(std::size_t i = 0;
                i < n;
                ++i, ++it, ++next) {
            // move next

            if(i==n-1) {
                if(vertices.size() > 0) {
                    // move next to appropriate value in second run through
                    for(int ii=1; ii<vertices[0]; ++ii, ++next)
                        ;
                } else // all points are invalid
                    break;
            }

            if(!policy(*prev, *it, *next)) {
                // It is not collinear, middle point (i == 1) will be kept
                vertices.push_back(i + 1);
                prev = it;
            }
        }

        // only if we have a polygon left we need to copy
        if (boost::size(vertices) > 2)
        {
            for(std::deque<std::size_t>::iterator fit = vertices.begin();
                    fit != vertices.end(); ++fit) {
                bg::append<Range, typename point_type<Range>::type >(range_out, *(range.begin() + *fit));
            }

            if(is_closed)
                range_out.push_back(range_out.front());
        }
    }
};


template <typename Polygon, typename PolygonOut, typename Policy>
struct polygon_remove_spikes {
    static inline void apply(Polygon const &polygon, PolygonOut &polygon_out, Policy const &policy) {
        typedef typename geometry::ring_type<Polygon>::type ring_type;
        typedef typename geometry::ring_type<PolygonOut>::type ring_type_out;

        ring_type_out r_out;
        typedef range_remove_spikes<ring_type, ring_type_out, Policy> per_range;
        per_range::apply(exterior_ring(polygon), r_out, policy);
        geometry::append(polygon_out, r_out);

        // if outer ring is empty we do not need to check inner rings
        if(geometry::num_points(r_out) == 0)
            return;

        typename interior_return_type<const Polygon>::type rings = interior_rings(polygon);
        typename interior_return_type<PolygonOut>::type rings_out = interior_rings(polygon_out);

        //interior_rings(polygon_out).resize(num_interior_rings(polygon));

        //BOOST_AUTO_TPL(it_out, boost::begin(rings_out));

        for(BOOST_AUTO_TPL(it, boost::begin(rings)); it != boost::end(rings); ++it) {
            ring_type_out r_tmp;
            per_range::apply(*it, r_tmp, policy);

            //++it_out;
            if(geometry::num_points(r_tmp) > 0)
                rings_out.push_back(r_tmp);
        }
    }
};


template <typename MultiGeometry, typename MultiGeometryOut, typename Policy, typename SinglePolicy>
struct multi_remove_spikes {
    static inline void apply(MultiGeometry const &multi, MultiGeometryOut &multi_out, Policy const &policy) {
        for(typename boost::range_const_iterator<MultiGeometry>::type
                it = boost::begin(multi);
                it != boost::end(multi);
                ++it) {
            typename boost::range_value<MultiGeometryOut>::type pout;
            SinglePolicy::apply(*it, pout, policy);

            if(geometry::num_points(geometry::exterior_ring(pout)) > 0)
                multi_out.push_back(pout);
        }
    }
};


}
} // namespace detail::remove_spikes
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
struct remove_spikes {
    static inline void apply(Geometry const &, GeometryOut &, Policy const &)
    {}
};


template <typename Ring, typename RingOut, typename Policy>
struct remove_spikes<ring_tag, Ring, RingOut, Policy>
        : detail::remove_spikes::range_remove_spikes<Ring, RingOut, Policy>
{};


template <typename Polygon, typename PolygonOut, typename Policy>
struct remove_spikes<polygon_tag, Polygon, PolygonOut, Policy>
        : detail::remove_spikes::polygon_remove_spikes<Polygon, PolygonOut, Policy>
{};


template <typename MultiPolygon, typename MultiPolygonOut, typename Policy>
struct remove_spikes<multi_polygon_tag, MultiPolygon, MultiPolygonOut, Policy>
        : detail::remove_spikes::multi_remove_spikes
        <
        MultiPolygon,
        MultiPolygonOut,
        Policy,
        detail::remove_spikes::polygon_remove_spikes
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
    \ingroup remove_spikes
    \tparam Geometry geometry type
    \param geometry the geometry to make remove_spikes
*/
template <typename Geometry, typename GeometryOut, typename Policy>
inline void remove_spikes(Geometry const &geometry, GeometryOut &geometry_out, Policy const &policy)
{
    concept::check<Geometry>();
    concept::check<GeometryOut>();

    dispatch::remove_spikes
    <
    typename tag<Geometry>::type,
             Geometry,
             GeometryOut,
             Policy
             >::apply(geometry, geometry_out, policy);
}



template <typename Point>
struct remove_elongated_spikes {
    typedef typename coordinate_type<Point>::type coordinate_type;
    coordinate_type m_area_div_peri;
    coordinate_type m_dist_div_peri;
    coordinate_type m_area_limit;
    coordinate_type m_distance_limit;
    coordinate_type m_zero;


    inline remove_elongated_spikes(coordinate_type const &area_div_peri = 0.001
                                   , coordinate_type const &dist_div_peri = 0.001
                                           , coordinate_type const &area_limit = 0.01
                                                   , coordinate_type const &distance_limit = 1
                                  )
        : m_area_div_peri(area_div_peri)
        , m_dist_div_peri(dist_div_peri)
        , m_area_limit(area_limit)
        , m_distance_limit(distance_limit)
        , m_zero(coordinate_type())
    {}


    inline bool operator()(Point const &prev,
                           Point const &current, Point const &next) const {
        coordinate_type d1 = geometry::distance(prev, current);

        if(d1 < m_distance_limit) {
            geometry::model::ring<Point> triangle;
            triangle.push_back(prev);
            triangle.push_back(current);
            triangle.push_back(next);
            triangle.push_back(prev);

            coordinate_type p = geometry::perimeter(triangle);

            if(p > m_zero) {
                coordinate_type a = geometry::math::abs(geometry::area(triangle));
                coordinate_type prop1 = a / p;
                coordinate_type prop2 = d1 / p;

                bool remove = prop1 < m_area_div_peri
                              && prop2 < m_dist_div_peri
                              && a < m_area_limit;

                /*
                {
                    coordinate_type d2 = geometry::distance(prev, next);
                    std::cout << std::endl;
                    std::cout << "Distance1: "  << d1 << std::endl;
                    std::cout << "Distance2: "  << d2 << std::endl;
                    std::cout << "Area:      "  << a << std::endl;
                    std::cout << "Perimeter: "  << p << std::endl;
                    std::cout << "Prop1:     "  << prop1 << std::endl;
                    std::cout << "Prop2:     "  << prop2 << std::endl;
                    std::cout << "Remove:    "  << (remove ? "true" : "false") << std::endl;
                }
                */

                return remove;
            }
        }

        return false;
    }
};


template <typename Point>
class remove_by_normalized_nico {
    typedef typename coordinate_type<Point>::type coordinate_type;
    coordinate_type m_zero;
    coordinate_type m_limit;
    double dir_limit;

public :
    inline remove_by_normalized_nico(coordinate_type const &lm, double const &dl = 1e-6)
        : m_zero(coordinate_type())
        , m_limit(lm) , dir_limit(dl)
    {}

    inline bool operator()(Point const &prev,
                           Point const &current, Point const &next) const {
        coordinate_type const x1 = get<0>(prev);
        coordinate_type const y1 = get<1>(prev);
        coordinate_type const x2 = get<0>(current);
        coordinate_type const y2 = get<1>(current);

        coordinate_type dx1 = x2 - x1;
        coordinate_type dy1 = y2 - y1;

        // Duplicate points (can be created by removing spikes)
        // can be removed as well. (Can be seen as a spike without length)
        // TEST REMOVE WITH EPS
        //if (geometry::math::equals(dx1, 0) && geometry::math::equals(dy1, 0))
        if(geometry::math::abs(dx1) < m_limit && geometry::math::abs(dy1) < m_limit) {
            return true;
        }

        coordinate_type dx2 = get<0>(next) - x2;
        coordinate_type dy2 = get<1>(next) - y2;

        // If middle point is duplicate with next, also.
        // TEST REMOVE WITH EPS
        //if (geometry::math::equals(dx2, 0) && geometry::math::equals(dy2, 0))
        if(geometry::math::abs(dx2) < m_limit && geometry::math::abs(dy2) < m_limit) {
            return true;
        }

        // Normalize the vectors -> this results in points+direction
        // and is comparible between geometries
        double const magnitude1 = std::sqrt((double)(dx1 * dx1 + dy1 * dy1));
        double const magnitude2 = std::sqrt((double)(dx2 * dx2 + dy2 * dy2));

        if(magnitude1 > m_zero && magnitude2 > m_zero) {
            double dtx1 = ((double)dx1) / magnitude1;
            double dty1 = ((double)dy1) / magnitude1;
            double dtx2 = ((double)dx2) / magnitude2;
            double dty2 = ((double)dy2) / magnitude2;

            // If the directions are opposite, it can be removed
            if(geometry::math::abs(dtx1 + dtx2) < dir_limit
                    && geometry::math::abs(dty1 + dty2) < dir_limit) {
                return true;
            }
        }

        return false;
    }
};

template <typename Point>
class remove_by_distance_nico {
    typedef typename coordinate_type<Point>::type coordinate_type;
    coordinate_type m_zero;
    //double dir_limit;
    coordinate_type distance;
    typedef model::referring_segment<const Point> segment_type;
    

public :
    inline remove_by_distance_nico(coordinate_type const &lm)
        : m_zero(coordinate_type()),
         distance(lm)
    {}

    inline bool operator()(Point const &prev,
                           Point const &current, Point const &next) const {

        segment_type s_pc(prev, current);
        
        // Duplicate points (can be created by removing spikes)
        // can be removed as well. (Can be seen as a spike without length)
        // TEST REMOVE WITH EPS
  
        if(bg::length(s_pc) < distance) {
            return true;
        }

        // Test if distances to segments are to small
        if (bg::distance(s_pc, next) < distance)
        {
            return true;
        }

        segment_type s_cn(current, next);

        // If middle point is duplicate with next, also.
        // TEST REMOVE WITH EPS
        if(bg::length(s_cn) < distance) {
            return true;
        }

        // Test if distances to segments are to small
        if (bg::distance(s_cn, prev) < distance)
        {
            return true;
        }


        segment_type s_pn(prev, next);

        // If middle point is duplicate with next, also.
        // TEST REMOVE WITH EPS
        if(bg::length(s_pn) < distance) {
            return true;
        }

        // Test if distances to segments are to small
        if (bg::distance(s_pn, current) < distance)
        {
            return true;
        }

        

        //coordinate_type const x1 = get<0>(prev);
        //coordinate_type const y1 = get<1>(prev);
        //coordinate_type const x2 = get<0>(current);
        //coordinate_type const y2 = get<1>(current);

        //coordinate_type dx1 = x2 - x1;
        //coordinate_type dy1 = y2 - y1;


        // Normalize the vectors -> this results in points+direction
        // and is comparible between geometries
        //double const magnitude1 = std::sqrt((double)(dx1 * dx1 + dy1 * dy1));
        //double const magnitude2 = std::sqrt((double)(dx2 * dx2 + dy2 * dy2));
        //double const magnitude1 = (double)bg::distance(pzero, pd1);
        //double const magnitude2 = (double)bg::distance(pzero, pd2);


        //if(magnitude1 > m_zero && magnitude2 > m_zero) {
        //    double dtx1 = ((double)dx1) / magnitude1;
        //    double dty1 = ((double)dy1) / magnitude1;
        //    double dtx2 = ((double)dx2) / magnitude2;
        //    double dty2 = ((double)dy2) / magnitude2;

        //    // If the directions are opposite, it can be removed
        //    if(geometry::math::abs(dtx1 + dtx2) < dir_limit
        //            && geometry::math::abs(dty1 + dty2) < dir_limit) {
        //        return true;
        //    }
        //}

        return false;
    }
};


}
} //namespace boost::geometry

#endif //BPOLY_BOOST_EXTENSIONS_STRATEGIE_REMOVE_BY_NORMALIZED_WITH_EPS