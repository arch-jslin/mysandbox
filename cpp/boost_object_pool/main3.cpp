#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <boost/tr1/memory.hpp>
#include <boost/smart_ptr/make_shared.hpp>
#include "boost/pool/pool_alloc.hpp"
#include "ObjectPool.hpp"

using std::tr1::shared_ptr;
using std::tr1::weak_ptr;
using namespace psc;
using namespace utils;
using boost::allocate_shared;
using boost::singleton_pool;
using boost::pool_allocator;
using boost::pool_allocator_tag;
using boost::fast_pool_allocator;
using boost::fast_pool_allocator_tag;

typedef singleton_pool<pool_allocator_tag, sizeof(char)> pool_char;

typedef std::basic_string<char, std::char_traits<char>, pool_allocator<char> > string;

struct Map;
typedef weak_ptr<Map> wpMap;

const int TOTAL_FRAME_FOR_TEST = 200;
const int MAX_SIZE = 60;
const int DEBUG = 0;
const int MANUAL = 0;
const int PERFORMANCE_TEST = 0;

struct Cube : public std::tr1::enable_shared_from_this<Cube> {
    typedef shared_ptr<Cube> pointer_type;
    typedef weak_ptr<Cube>   wpointer_type;
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

int Cube::total_cube_created = 0;

typedef singleton_pool<pool_allocator_tag, sizeof(shared_ptr<void>)> pool_sptr;
typedef singleton_pool<fast_pool_allocator_tag, sizeof(Cube)+24> pool_cube;

struct Map : public std::tr1::enable_shared_from_this<Map> {
    typedef shared_ptr<Map> pointer_type;
    typedef weak_ptr<Map> wpointer_type;

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
            //cubes[i] = ObjectPool<Cube>::create(shared_from_this(), (i%4+1));
            cubes[i] = allocate_shared<Cube>(fast_pool_allocator<Cube>(), shared_from_this(), (i%4+1));
            cubes[i]->x_ = i;
        }
    }

    void new_cube() {
        if( !cubes[MAX_SIZE-1] ) {
            //cubes[MAX_SIZE-1] = ObjectPool<Cube>::create(shared_from_this(), clock()%4+1);
            cubes[MAX_SIZE-1] = allocate_shared<Cube>(fast_pool_allocator<Cube>(), shared_from_this(), clock()%4+1);
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
    std::vector< pCube, pool_allocator<pCube> > cubes;
};
typedef Map::pointer_type  pMap;
typedef Map::wpointer_type wpMap;

typedef singleton_pool<fast_pool_allocator_tag, sizeof(Map)+24> pool_map;

void Cube::update(int x) {
    if( DEBUG ) {
        printf("addr: %x, i: %d, cubes[%d]->x_: %d, color_: %d\n", this, x, x, x_, color_);
    }
    BOOST_ASSERT(x_ == x);
    if( owner_.lock()->below_empty(x_) ) {
        x_ -= 1;
        owner_.lock()->update_cube(shared_from_this(), x);
    }
}

void placement_new_fun()
{
    char buf[100] = {0};
    Map* m1 = new (buf+1) Map(1);
    printf("%d, %s\n", m1->data1, m1->data3);
    m1->~Map();
    printf("%d, %s\n", reinterpret_cast<Map*>(buf+1)->data1, reinterpret_cast<Map*>(buf+1)->data3);
}

int main()
{
    printf("Size of Map: %d\n", sizeof(Map));
    printf("Size of Cube: %d\n", sizeof(Cube));
    //pMap m1 = ObjectPool<Map>::create(1);
    //pMap m2 = ObjectPool<Map>::create(2);
    pMap m1 = allocate_shared<Map>(fast_pool_allocator<Map>(), 1);
    pMap m2 = allocate_shared<Map>(fast_pool_allocator<Map>(), 2);
    m1->init();
    m2->init();
    printf("Initial:\n");
    m1->render();
    m2->render();

    printf("%d, %d, %d, %d\n", sizeof(shared_ptr<void>), sizeof(shared_ptr<int>), sizeof(pMap), sizeof(pCube));

    for( int frame = 0; frame < TOTAL_FRAME_FOR_TEST; ++frame ) {
        if( !PERFORMANCE_TEST ) {
            printf("Frame %d:\n", frame);
        }

        // input should be here

        // artificial event causing rollback
        if( frame % 9 == 5 ) {
            if( DEBUG ) {
                printf("Before rollback...\n");
            }
            //ObjectPool<Map>::restore();
            //ObjectPool<Cube>::restore();
            pool_map::restore();
            pool_cube::restore();
            pool_char::restore();
            pool_sptr::restore();
            if( DEBUG ) {
                printf("Something happened! rollback!\n");
                printf("checking memory....\n");
                m1->debug_check_memory();
                m2->debug_check_memory();
                printf("View current state: \n");
                m1->render();
                m2->render();
                if( MANUAL ) {
                    system("pause");
                }
            }
        }

        // acting like some input event is triggered
        if( frame % 3 == 2 ) {
            int x1 = clock() % MAX_SIZE;  //arbitrary value within MAX_SIZE
            int x2 = time(0) % MAX_SIZE;  //arbitrary value within MAX_SIZE
            if( m1->cubes[x1] ) {
                if( DEBUG ) {
                    printf("killing m1 cube %x at %d, color %d\n", m1->cubes[x1].get(), x1, m1->cubes[x1]->color_);
                }
                m1->cubes[x1].reset();
            }
            if( m2->cubes[x2] ) {
                if( DEBUG ) {
                    printf("killing m2 cube %x at %d, color %d\n", m2->cubes[x2].get(), x2, m2->cubes[x2]->color_);
                }
                m2->cubes[x2].reset();
            }
        }

        // model update
        m1->update(frame);
        m2->update(frame);

        // backup after model update
        if( frame % 4 == 0 ) { // snapshot every 4 frames
            if( DEBUG ) {
                printf("Backup...\n");
            }
            pool_sptr::backup();
            //ObjectPool<Map>::backup();
            //ObjectPool<Cube>::backup();
            pool_cube::backup();
            pool_map::backup();
            pool_char::backup();
        }

        // render
        if( DEBUG ) {
            m1->render();
            m2->render();
            if( MANUAL ) {
                system("pause");
            }
        }
    }

    printf("end state:\n");
    m1->render();
    m2->render();

    //ObjectPool<Map>::destroy_all();
    //ObjectPool<Cube>::destroy_all();
    //pool_map::purge_memory(); // 2012.11.26 -- WHY I CAN'T PURGE IT HERE?
    //pool_cube::purge_memory();
    //pool_char::purge_memory(); // Of course, allocators using singleton_pool should be destroyed only at the end of all program.
    //pool_sptr::purge_memory();
    printf("program ends\n");
    system("pause");
    return 0;
}

