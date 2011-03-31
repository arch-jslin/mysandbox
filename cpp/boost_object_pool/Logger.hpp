#ifndef __LOGGER__
#define __LOGGER__

#include <iostream>
#include <sstream>
#include <boost/thread/tss.hpp>

class Logger {
    typedef boost::thread_specific_ptr< std::ostringstream > pOSS;
    typedef boost::mutex::scoped_lock scoped_lock;

public:
    static Logger& i() {
        static Logger singleton;
        return singleton;
    }

    template<typename T>
    Logger& buf(T const& in) {
        if( oss_.get() == 0 )
            oss_.reset(new std::ostringstream);
        *oss_ << in;
        return *this;
    }

    template<typename T>
    Logger& buf(T const* in) {
        if( oss_.get() == 0 )
            oss_.reset(new std::ostringstream);
        *oss_ << in;
        return *this;
    }

    Logger& endl() {
        if( oss_.get() == 0 )
            oss_.reset(new std::ostringstream);
        scoped_lock l(io_mutex_);
        std::cout << oss_->str() << std::endl;
        oss_->str("");
        return *this;
    }

    Logger& out() {
        if( oss_.get() == 0 )
            oss_.reset(new std::ostringstream);
        scoped_lock l(io_mutex_);
        std::cout << oss_->str();
        oss_->str("");
        return *this;
    }

private:
    Logger(){}
    Logger(Logger const&);
    static boost::mutex io_mutex_;
    pOSS oss_;
};

boost::mutex Logger::io_mutex_;

#endif
