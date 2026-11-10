contract Registrar
{
	address public registrar;		
	
	uint256 public fee_registration;
	uint256 public fee_msg;
	uint256 public cnt_registrations;
	
	struct Registration {
		address adr;
		string hash;
		string gnid;
	}	
	
	mapping(address=>Registration) public regadr;	
	mapping(address=>Message[]) public msgs;
	mapping(address=>Message[]) public sent;
	mapping(address=>bool) public preregister;	
	
	Registration[] public regs;
	
	function Registrar() {
		registrar=msg.sender;
	}
	
	function register(string hash) {
		updateRegistration(hash,'');		
	}
	
	function unregister() {
		delete regadr[msg.sender];
	}
	
	function updateRegistration(string hash,string gnid) {		
		if((msg.value>=fee_registration)||(preregister[msg.sender])) {			
			regadr[msg.sender]=Registration(msg.sender,hash,gnid);
			regs.push(regadr[msg.sender]);
			if(fee_registration>0) registrar.send(this.balance);
			preregister[msg.sender]=false;
			cnt_registrations++;
		} else throw;
	}
	
	function preRegister(address preReg) {
		if(msg.sender!=registrar) throw;
		preReg.send(msg.value);		
		preregister[preReg]=true;
	}
	
	function getMsgs() returns (Message[]) {
		return msgs[msg.sender];	
	}
	
	function setRegistrationPrice(uint256 price) {
		if(msg.sender!=registrar) throw;
		fee_registration=price;
	}
	
	function setMsgPrice(uint256 price) {
		if(msg.sender!=registrar) throw;
		fee_msg=price;
	}
	
	function sendMsg(address to,string hash) {
		if(msg.value>=fee_msg) {	
			    Message m = new  Message(this,msg.sender,to,hash);
				msgs[to].push(m);	
			    sent[msg.sender].push(m);
			if(fee_msg>0) registrar.send(this.balance);
		} else throw;		
	}
	
	function ackMsg(uint256 msgid,string hash) {
		Message message =Message(msgs[msg.sender][msgid]);
		message.ack(hash);
	}
	
	function() {
		if(msg.value>0) {
			registrar.send(msg.value);
		}
	}
}