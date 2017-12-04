import std.stdio;

import kiss.event;
import kiss.socket.acceptor;
import kiss.socket.tcp;

import std.socket;
import std.functional;
import std.exception;

void catchException(E)(lazy E runer) @trusted nothrow
{
	try{
		runer();
	} catch (Exception e){
		collectException(writeln(e.toString));
	}
}

void main()
{
	writeln("Listen Port: 8081");
	EventLoop loop = new EventLoop();

	Acceptor acceptor = new Acceptor(loop, AddressFamily.INET);

	acceptor.bind(parseAddress("0.0.0.0",8081)).listen(1024).setReadData((EventLoop loop, Socket socket) @trusted nothrow {
				catchException((){
					TCPSocket sock = new TCPSocket(loop, socket);

					sock.setReadData((in ubyte[] data)@trusted nothrow {
						catchException((){
							writeln("read Data: ", cast(string)data);

							sock.write(new WarpTcpBuffer(data.dup,(in ubyte[] wdata, size_t size) @trusted nothrow{
									catchException((){
										writeln("Writed Suessed Size : ", size, "  Data : ", cast(string)wdata);
									}());
								}));
						}());
					}).setClose(()@trusted nothrow {
						catchException((){
							writeln("The Socket is Cloesed!");
						}());
					}).watch;
			}());
		}).watch;

	loop.join;
}