
//AS3 TCP socket speed test
package {
    import flash.display.Sprite;
    import flash.errors.*;
    import flash.events.*;
    import flash.net.Socket;
    public class TestSocket extends Sprite 
    {
        var s:Socket;
        var data_len:uint = 0;
        var str:String = "";
        var time:Number = 0;
        
        public function TestSocket() {
            s = new Socket("localhost", 45678);
            s.addEventListener(Event.CONNECT, onConnect);
            s.addEventListener(ProgressEvent.SOCKET_DATA, onDataRecv);
            s.addEventListener(Event.CLOSE, onClose);
        }
        private function onDataRecv(e:ProgressEvent) {
            if( s.bytesAvailable ) {
                data_len += s.bytesAvailable;
                str += s.readUTFBytes(s.bytesAvailable);
            }
        }    
        private function onConnect(e:Event) {
            var date:Date = new Date();
            time = date.getTime();
        }    
        private function onClose(e:Event) {
            var date:Date = new Date();
            trace("Asserting Data: " + str.substr(0, 49) );
            trace( data_len );
            trace("Receiving Rate: " + (data_len / (date.getTime()-time) / 1024 / 1024 * 1000) + " MBytes per second." );
            trace("Connection closed.");
        }
    }
}