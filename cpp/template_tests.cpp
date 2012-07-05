#include <iostream>

//Here it's just a list to hold compile-time int
//somewhat resembles the OCaml syntax there.

template<int... Args>             //  let rec list l = match l with
struct List;

template<>                        //    []   -> Empty
struct List<>{};

template<int Head, int... Tail>
struct List<Head, Tail...>{
    enum{ value = Head };         //    h::t -> let v = h
    typedef List<Tail...> _Tail;  //            let _t = list t
};

//and how to output it

void show_list(){
    std::cout << std::endl;
}

template<int Head, int... Tail>
void show_list( List<Head, Tail...> ){
    std::cout << Head;
    show_list( List<Tail...>() );
}

template<int Head>
void show_list( List<Head> ){
    std::cout << Head;
    show_list();
}

//Now this is a little bit more pattern matching to construct a b-tree

struct Empty{};

template<int T>
struct Leaf : public Empty{
    enum{ value = T };
};

template<int T, class L, class R>
struct Node : public Leaf<T>{
    typedef L Left;
    typedef R Right;
};

//and again, how to show it.

template<int I, class Y, class Z >
void show_tree(Node<I ,Y, Z> tree) {
    std::cout << "{" << I << ":";
    show_tree(typename Node<I, Y, Z>::Left());
    std::cout << "|";
    show_tree(typename Node<I, Y, Z>::Right());
    std::cout << "}";
}

template<int T>
void show_tree(Leaf<T> tree) {
    std::cout << "{" << T << "}";
}

void show_tree(Empty tree) {}

//------------------------------------

int main()
{
    //this is a compile-time list
    List<3, 2, 1, 5, 4> l;

    show_list( l );

    //this is a compile-time tree
    Node<3, Node<2, Leaf<1>, Node<5, Leaf<4>, Empty>>, Empty> tree;

    show_tree( tree );

    return 0;
}



