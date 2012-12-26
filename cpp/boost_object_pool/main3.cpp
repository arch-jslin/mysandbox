#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <boost/tr1/memory.hpp>
#include "Map.hpp"
#include "Cube.hpp"
#include "Conf.hpp"

using std::tr1::shared_ptr;
using std::tr1::weak_ptr;
using namespace psc;
using namespace utils;
using namespace model;

//deprecated, just kept for future reference.

//typedef singleton_pool<pool_allocator_tag, sizeof(shared_ptr<void>)> pool_sptr;
//typedef singleton_pool<pool_allocator_tag, 20> pool_spcb;
//typedef singleton_pool<fast_pool_allocator_tag, sizeof(Cube)+24> pool_cube;

//typedef singleton_pool<fast_pool_allocator_tag, sizeof(Map)+24> pool_map;

//end of deprecated

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
    pMap m1 = Map::create(1);
    pMap m2 = Map::create(2);
    //pMap m1 = allocate_shared<Map>(fast_pool_allocator<Map>(), 1);
    //pMap m2 = allocate_shared<Map>(fast_pool_allocator<Map>(), 2);
    m1->init();
    m2->init();
    printf("Initial:\n");
    m1->render();
    m2->render();

    // deprecated, kept only for reference.
    //printf("%d, %d, %d, %d, %d\n", sizeof(shared_ptr<void>), sizeof(shared_ptr<int>), sizeof(pMap), sizeof(boost::detail::sp_counted_impl_pda<Map*, boost::detail::sp_ms_deleter<Map> , fast_pool_allocator<Map> >));

    for( int frame = 1; frame < TOTAL_FRAME_FOR_TEST; ++frame ) {
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
            //pool_map::restore();
            //pool_cube::restore();
            //pool_char::restore();
            //pool_spcb::restore();
            //pool_sptr::restore();
            utils::pools_restore(frame - (frame%4)-1 /* serve as random */ ); // we test this first.. arbitrary rollback for 4 frames.
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

        // backup after model update EVERY FRAME.
        if( DEBUG ) {
            printf("Backup...\n");
        }
        utils::pools_backup(frame);

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

