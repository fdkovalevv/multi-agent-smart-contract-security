contract RTcoin {
    using SafeMath for uint256;
    
	address public owner;
    address public saleAgent;
    uint256 public totalSupply;
	string public name;
	uint8 public decimals;
	string public symbol;
	bool private allowEmission = true;
	mapping (address => uint256) balances;
    
    
    function RTcoin(string _name, string _symbol, uint8 _decimals) public {
		decimals = _decimals;
		name = _name;
		symbol = _symbol;
		owner = msg.sender;
	}
	
	
    function changeSaleAgent(address newSaleAgent) public onlyOwner {
        require (newSaleAgent!=address(0));
        uint256 tokenAmount = balances[saleAgent];
        if (tokenAmount>0) {
            balances[newSaleAgent] = balances[newSaleAgent].add(tokenAmount);
            balances[saleAgent] = balances[saleAgent].sub(tokenAmount);
            Transfer(saleAgent, newSaleAgent, tokenAmount);
        }
        saleAgent = newSaleAgent;
    }
	
	
	function emission(uint256 amount) public onlyOwner {
	    require(allowEmission);
	    require(saleAgent!=address(0));
	    totalSupply = amount * (uint256(10) ** decimals);
		balances[saleAgent] = totalSupply;
		Transfer(0x0, saleAgent, totalSupply);
		allowEmission = false;
	}
    
    
    function burn(uint256 _value) public {
        require(_value > 0);
        address burner;
        if (msg.sender==owner)
            burner = saleAgent;
        else
            burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
     
    event Burn(address indexed burner, uint indexed value);
	
	
	function transfer(address _to, uint256 _value) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    
    
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
	
	
	function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        owner = newOwner; 
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


	
	event Transfer(
		address indexed _from,
		address indexed _to,
		uint _value
	);
}