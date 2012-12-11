// Isolate these to a specific translation unit.
#include <boost/tr1/memory.hpp>
#include "ObjectPool.hpp"

// Mark some classes that you want to be restorable
// can include headers or use forward declarations.
#include "Map.hpp"
#include "Cube.hpp"

namespace psc {
namespace utils {

// used for basic_string => pooled string, or other possible uses
typedef boost::singleton_pool<char, sizeof(char)>
    pool_char;

// used for shared_ptrs stored in STL containers
typedef boost::singleton_pool<std::tr1::shared_ptr<void>, sizeof(std::tr1::shared_ptr<void>) >
    pool_sptr;

// Ok... whatever, singleton_pool is already thread-safe, and it should be invisible outside of this translation unit.
pool_char::pool_type char_backup_;
pool_sptr::pool_type sptr_backup_;

// And some unified restore // backup implementation here.

void pools_backup()
{
    ObjectPoolRestorable<model::Cube>::backup();
    ObjectPoolRestorable<model::Map>::backup();

    char_backup_.purge_memory(); // This is only temporary.
    // When backup, we'll have to check if backup buffer is already all used or there's still empty slot.
    pool_char::clone_to(char_backup_);

    sptr_backup_.purge_memory();
    pool_sptr::clone_to(sptr_backup_);
}

void pools_restore()
{
    ObjectPoolRestorable<model::Cube>::restore();
    ObjectPoolRestorable<model::Map>::restore();

    pool_char::restore(char_backup_);

    pool_sptr::restore(sptr_backup_);
}

} // utils
} // psc
