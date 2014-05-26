
//#include "Map.hpp"
//#include "Cube.hpp"
//#include "Conf.hpp"

// This file is main3 + ggpo related basic code, to test it in a rather cleaner runtime dll environment.
#include "ggponet.h"

//#include <boost/tr1/memory.hpp>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <cstring>

//using std::tr1::shared_ptr;
//using std::tr1::weak_ptr;
//using namespace psc;
//using namespace utils;
//using namespace model;

//deprecated, just kept for future reference.

//typedef singleton_pool<pool_allocator_tag, sizeof(shared_ptr<void>)> pool_sptr;
//typedef singleton_pool<pool_allocator_tag, 20> pool_spcb;
//typedef singleton_pool<fast_pool_allocator_tag, sizeof(Cube)+24> pool_cube;

//typedef singleton_pool<fast_pool_allocator_tag, sizeof(Map)+24> pool_map;

//end of deprecated


bool test_ggpo_begin_game(char* name) { // do nothing?
    return true;
}

bool test_ggpo_advance_frame(int flags) {
    return true;
}

bool test_ggpo_load_state(unsigned char* buf, int len) {
    return true;
}

bool test_ggpo_save_state(unsigned char** buf, int *len, int* checksum, int frame) {
    return true;
}

void test_ggpo_free_buffer(void* buf) {
}

bool test_ggpo_net_log(char* filename, unsigned char* buffer, int len) {
    return true;
}

bool test_ggpo_net_event(GGPOEvent* e) {
    return true;
}

//
//void Cube::update(int x) {
//    if( DEBUG ) {
//        printf("addr: %x, i: %d, cubes[%d]->x_: %d, color_: %d\n", this, x, x, x_, color_);
//    }
//    BOOST_ASSERT(x_ == x);
//    if( owner_.lock()->below_empty(x_) ) {
//        x_ -= 1;
//        owner_.lock()->update_cube(shared_from_this(), x);
//    }
//}
//
//void placement_new_fun()
//{
//    char buf[100] = {0};
//    Map* m1 = new (buf+1) Map(1);
//    printf("%d, %s\n", m1->data1, m1->data3);
//    m1->~Map();
//    printf("%d, %s\n", reinterpret_cast<Map*>(buf+1)->data1, reinterpret_cast<Map*>(buf+1)->data3);
//}

int main()
{
//    printf("Size of Map: %d\n", sizeof(Map));
//    printf("Size of Cube: %d\n", sizeof(Cube));
//    pMap m1 = Map::create(1);
//    pMap m2 = Map::create(2);
//    //pMap m1 = allocate_shared<Map>(fast_pool_allocator<Map>(), 1);
//    //pMap m2 = allocate_shared<Map>(fast_pool_allocator<Map>(), 2);
//    m1->init();
//    m2->init();


    GGPOSession* ggpo_ = 0;
    GGPOSessionCallbacks ggpo_callbacks_;

    ggpo_callbacks_.begin_game      = test_ggpo_begin_game;
    ggpo_callbacks_.advance_frame   = test_ggpo_advance_frame;
    ggpo_callbacks_.load_game_state = test_ggpo_load_state;
    ggpo_callbacks_.save_game_state = test_ggpo_save_state;
    ggpo_callbacks_.free_buffer     = test_ggpo_free_buffer;
    ggpo_callbacks_.on_event        = test_ggpo_net_event;
    ggpo_callbacks_.log_game_state  = test_ggpo_net_log;

    GGPOErrorCode result = ggpo_start_session(&ggpo_, &ggpo_callbacks_, "psc::TestGGPO", 2, sizeof(int), 7000);
    printf("GGPO Error: %d\n", result);

    ggpo_set_disconnect_timeout(ggpo_, 3000);
    ggpo_set_disconnect_notify_start(ggpo_, 3000);

    GGPOPlayer p1, p2;
    GGPOPlayerHandle h1, h2;

    p1.size = p2.size = sizeof(GGPOPlayer);
    p1.type = GGPO_PLAYERTYPE_LOCAL;            // local player
    p2.type = GGPO_PLAYERTYPE_REMOTE;           // remote player
    p1.player_num = 1;
    p2.player_num = 2;
    strncpy(p2.u.remote.ip_address, "127.0.0.1\0", 10);// ip addess of the player
    p2.u.remote.port = 7001;                    // port of that player
    printf("%s:%d\n", p2.u.remote.ip_address, p2.u.remote.port);

    result = ggpo_add_player(ggpo_, &p1,  &h1);
    printf("GGPO Error: %d\n", result);
    ggpo_set_frame_delay(ggpo_, h1, 2);         // only set frame delay for self

    result = ggpo_add_player(ggpo_, &p2,  &h2);
    printf("GGPO Error: %d\n", result);

    printf("GGPO: connecting...\n");

//
//    printf("Initial:\n");
//    m1->render();
//    m2->render();
//
//    // deprecated, kept only for reference.
//    //printf("%d, %d, %d, %d, %d\n", sizeof(shared_ptr<void>), sizeof(shared_ptr<int>), sizeof(pMap), sizeof(boost::detail::sp_counted_impl_pda<Map*, boost::detail::sp_ms_deleter<Map> , fast_pool_allocator<Map> >));
//
//    for( int frame = 1; frame < TOTAL_FRAME_FOR_TEST; ++frame ) {
//        if( !PERFORMANCE_TEST ) {
//            printf("Frame %d:\n", frame);
//        }
//
//        // input should be here
//
//        // artificial event causing rollback
//        if( frame % 9 == 5 ) {
//            if( DEBUG ) {
//                printf("Before rollback...\n");
//            }
//            //ObjectPool<Map>::restore();
//            //ObjectPool<Cube>::restore();
//            //pool_map::restore();
//            //pool_cube::restore();
//            //pool_char::restore();
//            //pool_spcb::restore();
//            //pool_sptr::restore();
//            utils::pools_restore(frame - (frame%4)-1 /* serve as random */ ); // we test this first.. arbitrary rollback for 4 frames.
//            if( DEBUG ) {
//                printf("Something happened! rollback!\n");
//                printf("checking memory....\n");
//                m1->debug_check_memory();
//                m2->debug_check_memory();
//                printf("View current state: \n");
//                m1->render();
//                m2->render();
//                if( MANUAL ) {
//                    system("pause");
//                }
//            }
//        }
//
//        // acting like some input event is triggered
//        if( frame % 3 == 2 ) {
//            int x1 = clock() % MAX_SIZE;  //arbitrary value within MAX_SIZE
//            int x2 = time(0) % MAX_SIZE;  //arbitrary value within MAX_SIZE
//            if( m1->cubes[x1] ) {
//                if( DEBUG ) {
//                    printf("killing m1 cube %x at %d, color %d\n", m1->cubes[x1].get(), x1, m1->cubes[x1]->color_);
//                }
//                m1->cubes[x1].reset();
//            }
//            if( m2->cubes[x2] ) {
//                if( DEBUG ) {
//                    printf("killing m2 cube %x at %d, color %d\n", m2->cubes[x2].get(), x2, m2->cubes[x2]->color_);
//                }
//                m2->cubes[x2].reset();
//            }
//        }
//
//        // model update
//        m1->update(frame);
//        m2->update(frame);
//
//        // backup after model update EVERY FRAME.
//        if( DEBUG ) {
//            printf("Backup...\n");
//        }
//        utils::pools_backup(frame);
//
//        // render
//        if( DEBUG ) {
//            m1->render();
//            m2->render();
//            if( MANUAL ) {
//                system("pause");
//            }
//        }
//    }
//
//    printf("end state:\n");
//    m1->render();
//    m2->render();

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

