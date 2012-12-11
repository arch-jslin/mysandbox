#ifndef MAP
#define MAP

#include <string>
#include <vector>
#include <boost/tr1/memory.hpp>
#include "Cube.hpp"
#include "ObjectPool.hpp"
#include "Conf.hpp"

namespace psc { namespace model {

// where should I put this?
typedef std::basic_string<char, std::char_traits<char>, boost::pool_allocator<char> > string;

struct Cube;
typedef std::tr1::shared_ptr<Cube> pCube;

struct Map : public std::tr1::enable_shared_from_this<Map> {

    typedef std::tr1::shared_ptr<Map> pointer_type;
    typedef std::tr1::weak_ptr<Map> wpointer_type;

    static pointer_type create(int const& i) {
        return utils::ObjectPoolRestorable<Map>::create(i);
    }

    Map(int i):
        data1(i*10),
        data2("name"),
        data3("name")
    {
        data2 += (i+48);
        for( int i = 0; i < MAX_SIZE; ++i ) {
            cubes.push_back(pCube()); //empty
        }
    }

    void init() {
        for( int i = 0; i < 10; ++i ) {
            cubes[i] = Cube::create(shared_from_this(), (i%4+1));
            //cubes[i] = allocate_shared<Cube>(fast_pool_allocator<Cube>(), shared_from_this(), (i%4+1));
            cubes[i]->x_ = i;
        }
    }

    void new_cube() {
        if( !cubes[MAX_SIZE-1] ) {
            cubes[MAX_SIZE-1] = Cube::create(shared_from_this(), clock()%4+1);
            //cubes[MAX_SIZE-1] = allocate_shared<Cube>(fast_pool_allocator<Cube>(), shared_from_this(), clock()%4+1);
            if( DEBUG ) {
                printf("new cube..%x\n", cubes[MAX_SIZE-1].get());
            }
        }
    }

    void render() {
        for( int i = 0; i < MAX_SIZE; ++i ) {
            if( cubes[i] ) {
                printf("%d", cubes[i]->color_);
            } else {
                printf("0");
            }
        }
        printf("\n");
    }

    void update(int frame) {
        if( frame % 3 == 1 ) new_cube();
        for( int i = 0; i < MAX_SIZE; ++i ) {
            if( cubes[i] ) {
                cubes[i]->update(i);
            }
        }
    }

    void debug_check_memory() {
        for( int i = 0; i < MAX_SIZE; ++i ) {
            if( cubes[i] ) {
                printf("addr: %x, i: %d, cubes[%d]->x_: %d, color_: %d\n", cubes[i].get(), i, i, cubes[i]->x_, cubes[i]->color_);
            }
        }
    }

    void update_cube(pCube c, int oldx) {
        cubes[c->x_] = cubes[oldx];
        cubes[oldx].reset();
    }

    bool below_empty(int x) {
        if( x > 0 && !cubes[x-1] )
            return true;
        return false;
    }

    ~Map() {
        if( !PERFORMANCE_TEST ) {
            printf("Map destructed: %s\n", data2.c_str());
        }
        data1 = 0;
    }
//////////////////////////
    int         data1;
    string      data2;
    const char* data3;

    //use pvoid for universal shared_ptr pool (of those you want to rollback)
    std::vector< pCube, boost::pool_allocator< std::tr1::shared_ptr<void> > > cubes;
};
typedef Map::pointer_type  pMap;
typedef Map::wpointer_type wpMap;

}} // end of namespace

#endif
