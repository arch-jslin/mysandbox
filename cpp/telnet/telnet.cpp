/* telnet.cpp
        A simple demonstration telnet client with Boost asio

        Parameters:
                hostname or address
                port - typically 23 for telnet service

        To end the application, send Ctrl-C on standard input
*/

#include <deque>
#include <iostream>
#include <boost/bind.hpp>
#include <boost/asio.hpp>
#include <boost/thread.hpp>
#include <boost/date_time/posix_time/posix_time_types.hpp>

#ifdef POSIX
#include <termios.h>
#endif

using boost::asio::ip::tcp;
using namespace std;

class telnet_client
{
public:
        telnet_client(boost::asio::io_service& io_service, tcp::resolver::iterator endpoint_iterator)
                : active_(true),
                  io_service_(io_service), socket_(io_service),
                  connect_timer_(io_service), connection_timeout(boost::posix_time::seconds(3))
        {
                connect_start(endpoint_iterator);
        }

        void write(const char msg) // pass the write data to the do_write function via the io service in the other thread
        {
                io_service_.post(boost::bind(&telnet_client::do_write, this, msg));
        }

        void close() // call the do_close function via the io service in the other thread
        {
                io_service_.post(boost::bind(&telnet_client::do_close, this, boost::system::error_code()));
        }

        bool active() // return true if the socket is still active
        {
                return active_;
        }

private:

        static const int max_read_length = 512; // maximum amount of data to read in one operation

        void connect_start(tcp::resolver::iterator endpoint_iterator)
        { // asynchronously connect a socket to the specified remote endpoint and call connect_complete when it completes or fails
                tcp::endpoint endpoint = *endpoint_iterator;
                socket_.async_connect(endpoint,
                        boost::bind(&telnet_client::connect_complete,
                                this,
                                boost::asio::placeholders::error,
                                ++endpoint_iterator));
                // start a timer that will expire and close the connection if the connection cannot connect within a certain time
                connect_timer_.expires_from_now(connection_timeout); //boost::posix_time::seconds(connection_timeout));
                connect_timer_.async_wait(boost::bind(&telnet_client::do_close, this, boost::asio::placeholders::error));
        }

        void connect_complete(const boost::system::error_code& error, tcp::resolver::iterator endpoint_iterator)
        { // the connection to the server has now completed or failed and returned an error
                if (!error) // success, so start waiting for read data
                {
                        connect_timer_.cancel(); // the connection was successful, so cancel the timeout
                        read_start();
                }
                else
                        do_close(error);
        }

        void read_start(void)
        { // Start an asynchronous read and call read_complete when it completes or fails
                socket_.async_read_some(boost::asio::buffer(read_msg_, max_read_length),
                        boost::bind(&telnet_client::read_complete,
                                this,
                                boost::asio::placeholders::error,
                                boost::asio::placeholders::bytes_transferred));
        }

        void read_complete(const boost::system::error_code& error, size_t bytes_transferred)
        { // the asynchronous read operation has now completed or failed and returned an error
                if (!error)
                { // read completed, so process the data
                        cout.write(read_msg_, bytes_transferred); // echo to standard output
                        read_start(); // start waiting for another asynchronous read again
                }
                else
                        do_close(error);
        }

        void do_write(const char msg)
        { // callback to handle write call from outside this class
                bool write_in_progress = !write_msgs_.empty(); // is there anything currently being written?
                write_msgs_.push_back(msg); // store in write buffer
                if (!write_in_progress) // if nothing is currently being written, then start
                        write_start();
        }

        void write_start(void)
        { // Start an asynchronous write and call write_complete when it completes or fails
                boost::asio::async_write(socket_,
                        boost::asio::buffer(&write_msgs_.front(), 1),
                        boost::bind(&telnet_client::write_complete,
                                this,
                                boost::asio::placeholders::error));
        }

        void write_complete(const boost::system::error_code& error)
        { // the asynchronous read operation has now completed or failed and returned an error
                if (!error)
                { // write completed, so send next write data
                        write_msgs_.pop_front(); // remove the completed data
                        if (!write_msgs_.empty()) // if there is anthing left to be written
                                write_start(); // then start sending the next item in the buffer
                }
                else
                        do_close(error);
        }

        void do_close(const boost::system::error_code& error)
        { // something has gone wrong, so close the socket & make this object inactive
                if (error == boost::asio::error::operation_aborted) // if this call is the result of a timer cancel()
                        return; // ignore it because the connection cancelled the timer
                if (error)
                        cerr << "Error: " << error.message() << endl; // show the error message
                else
                        cout << "Error: Connection did not succeed.\n";
                cout << "Press Enter to exit\n";
                socket_.close();
                active_ = false;
        }

private:
        bool active_; // remains true while this object is still operating
        boost::asio::io_service& io_service_; // the main IO service that runs this connection
        tcp::socket socket_; // the socket this instance is connected to
        boost::asio::deadline_timer connect_timer_;
        boost::posix_time::time_duration connection_timeout; // time to wait for the connection to succeed
        char read_msg_[max_read_length]; // data read from the socket
        deque<char> write_msgs_; // buffered write data
};

int main(int argc, char* argv[])
{
// on Unix POSIX based systems, turn off line buffering of input, so cin.get() returns after every keypress
// On other systems, you'll need to look for an equivalent
#ifdef POSIX
        termios stored_settings;
        tcgetattr(0, &stored_settings);
        termios new_settings = stored_settings;
        new_settings.c_lflag &= (~ICANON);
        new_settings.c_lflag &= (~ISIG); // don't automatically handle control-C
        tcsetattr(0, TCSANOW, &new_settings);
#endif
        try
        {
                if (argc != 3)
                {
                        cerr << "Usage: telnet <host> <port>\n";
                        return 1;
                }
                boost::asio::io_service io_service;
                // resolve the host name and port number to an iterator that can be used to connect to the server
                tcp::resolver resolver(io_service);
                tcp::resolver::query query(argv[1], argv[2]);
                tcp::resolver::iterator iterator = resolver.resolve(query);
                // define an instance of the main class of this program
                telnet_client c(io_service, iterator);
                // run the IO service as a separate thread, so the main thread can block on standard input
                boost::thread t(boost::bind(&boost::asio::io_service::run, &io_service));
                while (c.active()) // check the internal state of the connection to make sure it's still running
                {
                        char ch;
                        cin.get(ch); // blocking wait for standard input
                        if (ch == 3) // ctrl-C to end program
                                break;
                        c.write(ch);
                }
                c.close(); // close the telnet client connection
                t.join(); // wait for the IO service thread to close
        }
        catch (exception& e)
        {
                cerr << "Exception: " << e.what() << "\n";
        }
#ifdef POSIX // restore default buffering of standard input
        tcsetattr(0, TCSANOW, &stored_settings);
#endif
        return 0;
}

