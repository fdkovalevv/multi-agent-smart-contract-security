contract Token {
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);

	function balanceOf(address _owner) constant returns (uint256 balance);
	function transfer(address _to, uint256 _value) returns (bool success);
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
	function approve(address _spender, uint256 _value) returns (bool success);
	function allowance(address _owner, address _spender) constant returns (uint256 remaining);
}

contract EtherianToken is Token{

	struct Receipt {  
		address minter;
		address beneficiary;
		string data;
	}

	                                                                       
	struct Account {
		uint balance;
		mapping (address => uint) allowanceOf;
		bool minter;
	}

	                                  
	modifier when_minter(address _minter) {
		if (!accounts[_minter].minter) throw;
		_;
	}

	                                  
	modifier when_owns(address _owner, uint _amount) {
		if (accounts[_owner].balance < _amount) throw;
		_;
	}

	                                   
	modifier when_has_allowance(address _owner, address _spender, uint _amount) {
		if (accounts[_owner].allowanceOf[_spender] < _amount) throw;
		_;
	}

	                                             
	modifier when_no_eth {
		if (msg.value > 0) throw;
		_;
	}

	                        
	modifier when_non_zero(uint _value) {
		if (_value == 0) throw;
		_;
	}

	                                     
	uint constant public base = 1;

	                         
	uint public totalSupply;

	                                          
    mapping (uint => Receipt) public receipts;

	                                                   
	mapping (address => Account) public accounts;

	                                                                          
	function EtherianToken(address _minter) when_no_eth {
	    _minter = _minter == 0x0 ? msg.sender : _minter;
		accounts[_minter].minter = true;
	}

    function mint(address _beneficiary,string _data) when_minter(msg.sender){
		totalSupply++;
        receipts[totalSupply].minter = msg.sender;
        receipts[totalSupply].beneficiary = _beneficiary;
        receipts[totalSupply].data = _data;
        accounts[_beneficiary].balance++;
    }

	                                
	function balanceOf(address _who) constant returns (uint256) {
		return accounts[_who].balance;
	}

	           
	function transfer(address _to, uint256 _value) when_no_eth when_owns(msg.sender, _value) returns (bool) {
		Transfer(msg.sender, _to, _value);
		accounts[msg.sender].balance -= _value;
		accounts[_to].balance += _value;

		return true;
	}

	                         
	function transferFrom(address _from, address _to, uint256 _value) when_no_eth when_owns(_from, _value) when_has_allowance(_from, msg.sender, _value) returns (bool) {
		Transfer(_from, _to, _value);
		accounts[_from].allowanceOf[msg.sender] -= _value;
		accounts[_from].balance -= _value;
		accounts[_to].balance += _value;

		return true;
	}

	                     
	function approve(address _spender, uint256 _value) when_no_eth returns (bool) {
		Approval(msg.sender, _spender, _value);
		accounts[msg.sender].allowanceOf[_spender] += _value;

		return true;
	}

	                      
	function allowance(address _owner, address _spender) constant returns (uint256) {
		return accounts[_owner].allowanceOf[_spender];
	}

	                                                               
	function() {
		throw;
	}

}