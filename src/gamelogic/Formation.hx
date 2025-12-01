import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;

class Formation implements MessageListener implements Updateable {

    public function update(dt:Float) {}


	public function receiveMessage(msg:Message):Bool {
		return false;
	}
}