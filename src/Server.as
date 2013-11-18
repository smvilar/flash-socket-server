package
{
	import flash.errors.EOFError;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.text.TextField;
	import flash.utils.Dictionary;

	public class Server
	{
		private const MESSAGE_SET_NAME:String = "setName";
		private const MESSAGE_SEND_TO:String = "sendTo";
		private const MESSAGE_GET_ALL_NAMES:String = "getAllNames";
		
		private var serverSocket:ServerSocket = new ServerSocket();
		private var clients:Vector.<Socket> = new Vector.<Socket>();
		private var clientNames:Dictionary = new Dictionary(true);
		private var log:Function;
		
		public function Server(logFunction:Function)
		{
			log = logFunction;
		}
		
		public function bind(port:int, ip:String):void
		{
			if (serverSocket.bound)
			{
				serverSocket.close();
				serverSocket = new ServerSocket();
			}
			serverSocket.bind(port, ip);
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, onConnect);
			serverSocket.listen();
			log("Bound to: " + serverSocket.localAddress + ":" + serverSocket.localPort);
		}
		
		public function broadcast(message:String):void
		{
			for each (var clientSocket:Socket in clients)
			{
				try
				{
					if (clientSocket != null && clientSocket.connected)
					{
						clientSocket.writeUTFBytes(message);
						clientSocket.flush();
						log("Sent message to " + clientSocket.remoteAddress + ":" + clientSocket.remotePort);
					}
					else log("No socket connection.");
				}
				catch (error:Error)
				{
					log(error.message);
				}
			}
		}
		
		private function onConnect(event:ServerSocketConnectEvent):void
		{
			var clientSocket:Socket = event.socket;
			clientSocket.addEventListener(ProgressEvent.SOCKET_DATA, onClientSocketData);
			clientSocket.addEventListener(Event.CLOSE, onClientSocketClose);
			log("Connection from " + clientSocket.remoteAddress + ":" + clientSocket.remotePort);
			
			clients.push(clientSocket);
			
			setName(clientSocket, "unnamed");
		}
		
		private function onClientSocketData(event:ProgressEvent):void
		{
			var clientSocket:Socket = event.target as Socket;		
			try {
				while (clientSocket.bytesAvailable > 0)
				{
					var messageType:String = clientSocket.readUTF();
					
					switch (messageType) {
						case MESSAGE_SET_NAME:
						{
							setName(clientSocket, clientSocket.readUTF());
							break;
						}
						case MESSAGE_SEND_TO:
						{
							var name:String = clientSocket.readUTF();
							var msg:String = clientSocket.readUTF();
							var params:Object = (clientSocket.bytesAvailable > 0) ? clientSocket.readObject() : null;
							sendMessageTo(name, msg, params);
							break;
						}
						case MESSAGE_GET_ALL_NAMES:
						{
							sendAllNamesTo(clientSocket);
							break;
						}
					}
				}
			} catch (e:EOFError) {
				log("End of file error.");
			}
		}
		
		private function setName(clientSocket:Socket, name:String):void
		{
			clientNames[clientSocket] = name;
			log("Giving name " + clientNames[clientSocket] + " to " + clientSocket.remoteAddress + ":" + clientSocket.remotePort);
		}
		
		private function sendMessageTo(name:String, msg:String, params:Object):void
		{
			for (var client:Object in clientNames)
			{
				var clientSocket:Socket = client as Socket;
				var clientName:String = clientNames[client];
				if (clientName == name)
				{
					clientSocket.writeUTF(msg);
					clientSocket.writeObject(params);
					clientSocket.flush();
				}
			}
		}
		
		private function sendAllNamesTo(clientSocket:Socket):void
		{
			var names:Array = [];
			for each (var clientName:String in clientNames)
			{
				names.push(clientName);
			}
			clientSocket.writeUTF("allNames");
			clientSocket.writeObject(names);
			clientSocket.flush();
		}
		
		private function onClientSocketClose(event:Event):void
		{
			var clientSocket:Socket = event.target as Socket;
			clientSocket.removeEventListener(ProgressEvent.SOCKET_DATA, onClientSocketData);
			clientSocket.removeEventListener(Event.CLOSE, onClientSocketClose);
			log("Closed connection with name " + clientNames[clientSocket]);
			
			clients.splice(clients.indexOf(clientSocket), 1);
			delete clientNames[clientSocket];
		}
	}
}
