
#include <boost/multi_index_container.hpp>
#include <boost/multi_index/sequenced_index.hpp>
#include <boost/multi_index/ordered_index.hpp>
#include <boost/multi_index/key_extractors.hpp>
#include <cstdlib>
#include <ctime>
#include <cstdio>

int random(int const& n) { return rand()%n; }

struct vec2 {
    double x_, y_;
    vec2():x_(0), y_(0){}
    vec2(double const& x, double const& y):x_(x), y_(y){}
    vec2 operator-(vec2 const& o) const {
        return vec2(x_ - o.x_, y_ - o.y_);
    }
    double len_sq() const {
        return x_*x_ + y_*y_;
    }
    bool operator<(vec2 const& other) const {
        return len_sq() < other.len_sq();
    }
};

struct unit {
    static int UNIT_TOTAL;
    int id_;
    vec2 pos_;
    unit():id_(UNIT_TOTAL), pos_(random(200)/10.0, random(200)/10.0){
        printf("log: unit %d randomly generated at: %f, %f\n", id_, pos_.x_, pos_.y_);
        ++UNIT_TOTAL;
    }
    double distance_sq(unit const& other) const {
        return (other.pos_ - pos_).len_sq();
    }
    double abs() const {
        return pos_.len_sq();
    }
    double x() const {
        return pos_.x_;
    }
    double y() const {
        return pos_.y_;
    }
    bool operator<(unit const& other) const {
        return pos_ < other.pos_;
    }
};

int unit::UNIT_TOTAL = 0;

using boost::multi_index_container;
using boost::multi_index::indexed_by;
using boost::multi_index::sequenced;
using boost::multi_index::ordered_unique;
using boost::multi_index::ordered_non_unique;
using boost::multi_index::identity;
using boost::multi_index::member;
using boost::multi_index::mem_fun;
using boost::multi_index::const_mem_fun;

typedef multi_index_container <
    unit,
    indexed_by <
        sequenced<>,
        ordered_non_unique< member<unit, vec2, &unit::pos_> >
    >
> unit_list;

int main()
{
    srand(time(0));
    typedef unit_list::nth_index<1>::type unit_list_by_position;
    unit_list units;

    for( int i = 0; i < 100; ++i ) {
        units.push_back(unit());
    }

    unit_list_by_position& units_by_position = units.get<1>();

    unit_list_by_position::iterator lbx = units_by_position.begin();
    unit_list_by_position::iterator ubx = units_by_position.upper_bound(
        vec2(12, 8),
        [](vec2 const& p1, vec2 const& p2) {
            printf("p1(%f, %f), p2(%f, %f)\n", p1.x_, p1.y_, p2.x_, p2.y_);
            return (p2-p1).len_sq() < 1;
        });

    printf("\n\nNow picking out units within 10u distance: \n");

    for( unit_list_by_position::iterator it = lbx; it != ubx; ++it ) {
        printf(" -- %d : (%f, %f), distance_sq: %f\n", it->id_, it->pos_.x_, it->pos_.y_, it->abs());
    }

    system("pause");
    return 0;
}
