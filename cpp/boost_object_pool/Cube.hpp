#ifndef CUBE
#define CUBE

#include <boost/tr1/memory.hpp>
#include "ObjectPool.hpp"
#include "Conf.hpp"

namespace psc { namespace model {

struct Map;
typedef std::tr1::weak_ptr<Map> wpMap;

struct Cube : public std::tr1::enable_shared_from_this<Cube> {
    typedef std::tr1::shared_ptr<Cube> pointer_type;
    typedef std::tr1::weak_ptr<Cube>   wpointer_type;

    static pointer_type create(wpMap const& owner, int const& color) {
        return utils::ObjectPoolRestorable<Cube>::create(owner, color);
    }

    int color_;
    int x_;
    wpMap owner_;
    Cube(wpMap const& o, int color): color_(color), x_(MAX_SIZE-1), owner_(o) {
        total_cube_created += 1;
        if( !PERFORMANCE_TEST ) {
            printf("total cube created: %d\n", total_cube_created);
        }
    }

    ~Cube(){
        if( !PERFORMANCE_TEST ) {
            printf("Cube: %x, x = %d, color = %d destructed.\n", this, x_, color_);
        }
        color_ = -1;
        x_ = -1;
    }

    void update(int x);

    static int total_cube_created;
};
typedef Cube::pointer_type pCube;
typedef Cube::wpointer_type wpCube;

}} // end of namespace

#endif

