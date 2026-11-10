contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) public constant returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;
    mapping(address => uint256) balances;

    function transfer(address _to, uint256 _value) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {
    mapping(address => mapping(address => uint256)) allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        var _allowance = allowed[_from][msg.sender];

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {

        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract Ownable {
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);

    event MintFinished();


    bool public mintingFinished = false;
    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }

    function destroy(uint256 _amount, address destroyer) public onlyOwner {
        uint256 myBalance = balances[destroyer];
        if (myBalance > _amount) {
            totalSupply = totalSupply.sub(_amount);
            balances[destroyer] = myBalance.sub(_amount);
        }
        else {
            if (myBalance != 0) totalSupply = totalSupply.sub(myBalance);
            balances[destroyer] = 0;
        }
    }

    function finishMinting() public onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }

    function getTotalSupply() public constant returns (uint256){
        return totalSupply;
    }
}

contract XgoldCrowdsaleToken is MintableToken {
    string public name;

    string public symbol;

    uint8 public decimals;

    function XgoldCrowdsaleToken() public {
        name = "XGOLD COIN";
        symbol = "XGC";
        decimals = 18;
    }
}