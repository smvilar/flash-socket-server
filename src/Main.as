package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class Main extends Sprite
	{
		private var localIP:TextField;
		private var localPort:TextField;
		private var logField:TextField;
		private var message:TextField;
		
		private var server:Server = new Server(log);
		
		public function Main()
		{
			setupUI();
		}
		
		private function setupUI():void
		{
			localIP = createTextField(10, 10, "Local IP", "127.0.0.1");
			localPort = createTextField(10, 35, "Local port", "50000");
			createTextButton(170, 60, "Bind", bind);
			message = createTextField(10, 85, "Message", "This is a test message.");
			createTextButton(170, 110, "Send", send);
			logField = createTextField(10, 135, "Log", "", false, 200);
			
			stage.nativeWindow.activate();
		}
		
		private function bind(event:Event):void
		{
			server.bind(parseInt(localPort.text), localIP.text);
		}
		
		private function send(event:Event):void
		{
			server.broadcast(message.text);
		}
		
		private function log(text:String):void
		{
			logField.appendText(text + "\n");
			logField.scrollV = logField.maxScrollV;
			trace(text);
		}
		
		private function createTextField(x:int, y:int, label:String, defaultValue:String = '', editable:Boolean = true, height:int = 20):TextField
		{
			var format:TextFormat = new TextFormat("_sans", 12);
			
			var labelField:TextField = new TextField();
			labelField.defaultTextFormat = format;
			labelField.text = label;
			labelField.type = TextFieldType.DYNAMIC;
			labelField.width = 100;
			labelField.x = x;
			labelField.y = y;
			
			var input:TextField = new TextField();
			input.defaultTextFormat = format;
			input.text = defaultValue;
			input.type = TextFieldType.INPUT;
			input.border = editable;
			input.selectable = editable;
			input.width = 280;
			input.height = height;
			input.x = x + labelField.width;
			input.y = y;
			
			addChild(labelField);
			addChild(input);
			
			return input;
		}
		
		private function createTextButton(x:int, y:int, label:String, clickHandler:Function):TextField
		{
			var format:TextFormat = new TextFormat("_sans", 12);
			
			var button:TextField = new TextField();
			button.defaultTextFormat = format;
			button.htmlText = "<u><b>" + label + "</b></u>";
			button.type = TextFieldType.DYNAMIC;
			button.selectable = false;
			button.width = 180;
			button.x = x;
			button.y = y;
			button.addEventListener(MouseEvent.CLICK, clickHandler);
			
			addChild(button);
			return button;
		}  
	}
}