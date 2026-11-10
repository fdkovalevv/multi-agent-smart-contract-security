contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) constant public returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant public returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Owned {

    address public owner;

    address public newOwner;

    function Owned() public payable {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function changeOwner(address _owner) onlyOwner public {
        require(_owner != 0);
        newOwner = _owner;
    }

    function confirmOwner() public {
        require(newOwner == msg.sender);
        owner = newOwner;
        delete newOwner;
    }
}

contract Blocked {

    uint public blockedUntil;

    modifier unblocked {
        require(now > blockedUntil);
        _;
    }
}

contract BalancingToken is ERC20 {
    mapping (address => uint256) public balances;                                

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
}

contract DividendToken is BalancingToken, Blocked, Owned {

    using SafeMath for uint256;

    event DividendReceived(address indexed dividendReceiver, uint256 dividendValue);

    mapping (address => mapping (address => uint256)) public allowed;

    uint public totalReward;
    uint public lastDivideRewardTime;

                                             
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }

                                             
    modifier rewardTimePast() {
        require(now > lastDivideRewardTime + rewardDays);
        _;
    }

    struct TokenHolder {
        uint256 balance;
        uint    balanceUpdateTime;
        uint    rewardWithdrawTime;
    }

    mapping(address => TokenHolder) holders;

    uint public rewardDays = 0;

    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) unblocked public returns (bool) {
        return transferSimple(_to, _value);
    }

    function transferSimple(address _to, uint256 _value) internal returns (bool) {
        beforeBalanceChanges(msg.sender);
        beforeBalanceChanges(_to);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) unblocked public returns (bool) {
        beforeBalanceChanges(_from);
        beforeBalanceChanges(_to);
        var _allowance = allowed[_from][msg.sender];
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) onlyPayloadSize(2 * 32) unblocked public returns (bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) onlyPayloadSize(2 * 32) unblocked constant public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function reward() constant public returns (uint256) {
        if (holders[msg.sender].rewardWithdrawTime >= lastDivideRewardTime) {
            return 0;
        }
        uint256 balance;
        if (holders[msg.sender].balanceUpdateTime <= lastDivideRewardTime) {
            balance = balances[msg.sender];
        } else {
            balance = holders[msg.sender].balance;
        }
        return totalReward.mul(balance).div(totalSupply);
    }

    function withdrawReward() public returns (uint256) {
        uint256 rewardValue = reward();
        if (rewardValue == 0) {
            return 0;
        }
        if (balances[msg.sender] == 0) {
                                
            delete holders[msg.sender];
        } else {
            holders[msg.sender].rewardWithdrawTime = now;
        }
        require(msg.sender.call.gas(3000000).value(rewardValue)());
        DividendReceived(msg.sender, rewardValue);
        return rewardValue;
    }

                                                          
    function divideUpReward(uint inDays) rewardTimePast onlyOwner external payable {
        require(inDays >= 15 && inDays <= 45);
        lastDivideRewardTime = now;
        rewardDays = inDays;
        totalReward = this.balance;
    }

    function withdrawLeft() rewardTimePast onlyOwner external {
        require(msg.sender.call.gas(3000000).value(this.balance)());
    }

    function beforeBalanceChanges(address _who) public {
        if (holders[_who].balanceUpdateTime <= lastDivideRewardTime) {
            holders[_who].balanceUpdateTime = now;
            holders[_who].balance = balances[_who];
        }
    }
}

contract RENTCoin is DividendToken {

    string public constant name = "RentAway Coin";

    string public constant symbol = "RTW";

    uint32 public constant decimals = 18;

    function RENTCoin(uint256 initialSupply, uint unblockTime) public {
        totalSupply = initialSupply;
        balances[owner] = initialSupply;
        blockedUntil = unblockTime;
    }

    function manualTransfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) onlyOwner public returns (bool) {
        return transferSimple(_to, _value);
    }
}