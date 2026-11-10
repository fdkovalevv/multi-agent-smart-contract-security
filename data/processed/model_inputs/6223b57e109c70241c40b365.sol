contract Ownable {
               
    address public owner;

    address public newOwner;

                   
       
                                                                 
       
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

       
                                                                                           
               
       
    function Ownable() public {
        owner = msg.sender;
    }

       
                                                                                       
                                                             
       
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
}

contract ERC20 is Ownable {

    using SafeMath for uint256;

                                       
    string public standard;

    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 public initialSupply;

    bool public locked;

    uint256 public creationBlock;

    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowance;

                                                                                  
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords.mul(32).add(4));
        _;
    }

                                                                                        
    function ERC20(
        uint256 _initialSupply,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transferAllSupplyToOwner,
        bool _locked
    ) {
        standard = "ERC20 0.1";

        initialSupply = _initialSupply;

        if (_transferAllSupplyToOwner) {
            setBalance(msg.sender, initialSupply);
        } else {
            setBalance(this, initialSupply);
        }

        name = _tokenName;
                                            
        symbol = _tokenSymbol;
                                              
        decimals = _decimalUnits;
                                                  
        locked = _locked;
        creationBlock = block.number;
    }

                        
    function totalSupply() public constant returns (uint256) {
        return initialSupply;
    }

    function balanceOf(address _address) public constant returns (uint256) {
        return balances[_address];
    }

    function transfer(address _to, uint256 _value) public onlyPayloadSize(2) returns (bool) {
        require(locked == false);

        bool status = transferInternal(msg.sender, _to, _value);

        require(status == true);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (locked) {
            return false;
        }

        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        if (locked) {
            return false;
        }

        TokenRecipient spender = TokenRecipient(_spender);

        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (locked) {
            return false;
        }

        if (allowance[_from][msg.sender] < _value) {
            return false;
        }

        bool _success = transferInternal(_from, _to, _value);

        if (_success) {
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        }

        return _success;
    }

                           
    function setBalance(address _holder, uint256 _amount) internal {
        balances[_holder] = _amount;
    }

    function transferInternal(address _from, address _to, uint256 _value) internal returns (bool success) {
        if (_value == 0) {
            Transfer(_from, _to, 0);
            return true;
        }

        if (balances[_from] < _value) {
            return false;
        }

        setBalance(_from, balances[_from].sub(_value));
        setBalance(_to, balances[_to].add(_value));

        Transfer(_from, _to, _value);

        return true;
    }

}

contract MintingERC20 is ERC20 {

    using SafeMath for uint256;

    uint256 public maxSupply;

    mapping (address => bool) public minters;

    modifier onlyMinters () {
        require(true == minters[msg.sender]);
        _;
    }

    function MintingERC20(
        uint256 _initialSupply,
        uint256 _maxSupply,
        string _tokenName,
        uint8 _decimals,
        string _symbol,
        bool _transferAllSupplyToOwner,
        bool _locked
    )
        ERC20(_initialSupply, _tokenName, _decimals, _symbol, _transferAllSupplyToOwner, _locked)
    {
        minters[msg.sender] = true;
        maxSupply = _maxSupply;
    }

    function addMinter(address _newMinter) public onlyOwner {
        minters[_newMinter] = true;
    }

    function removeMinter(address _minter) public onlyOwner {
        minters[_minter] = false;
    }

    function mint(address _addr, uint256 _amount) public onlyMinters returns (uint256) {
        if (_amount == uint256(0)) {
            return uint256(0);
        }

        if (totalSupply().add(_amount) > maxSupply) {
            return uint256(0);
        }

        initialSupply = initialSupply.add(_amount);
        balances[_addr] = balances[_addr].add(_amount);
        Transfer(0, _addr, _amount);

        return _amount;
    }
}

contract Node is MintingERC20 {

    using SafeMath for uint256;

    NodePhases public nodePhases;

                                          
    bool public transferFrozen = true;

    function Node(
        uint256 _maxSupply,
        string _tokenName,
        string _tokenSymbol,
        uint8 _precision,
        bool _locked
    ) MintingERC20(0, _maxSupply, _tokenName, _precision, _tokenSymbol, false, _locked) {
        standard = "Node 0.1";
    }

    function setLocked(bool _locked) public onlyOwner {
        locked = _locked;
    }

    function setNodePhases(address _nodePhases) public onlyOwner {
        nodePhases = NodePhases(_nodePhases);
    }

    function unfreeze() public onlyOwner {
        if (nodePhases != address(0) && nodePhases.isFinished(1)) {
            transferFrozen = false;
        }
    }

    function buyBack(address _address) public onlyMinters returns (uint256) {
        require(address(_address) != address(0));

        uint256 balance = balanceOf(_address);
        setBalance(_address, 0);
        setBalance(this, balanceOf(this).add(balance));
        Transfer(_address, this, balance);

        return balance;
    }

    function transfer(address _to, uint _value) public returns (bool) {
        require(!transferFrozen);

        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(!transferFrozen);

        return super.transferFrom(_from, _to, _value);
    }

}