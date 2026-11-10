contract Ownable {
    address public godOwner;
    mapping (address => bool) public owners;

    constructor() public{
        godOwner = msg.sender;
        owners[msg.sender] = true;
    }

    modifier onlyGodOwner {
        require(msg.sender == godOwner);
        _;
    }

    modifier onlyOwner {
        require(owners[msg.sender] == true);
        _;
    }

    function addOwner(address _newOwner) onlyGodOwner public{
        owners[_newOwner] = true;
    }

    function removeOwner(address _oldOwner) onlyGodOwner public{
        owners[_oldOwner] = false;
    }

    function transferOwnership(address newGodOwner) public onlyGodOwner {
        godOwner = newGodOwner;
        owners[newGodOwner] = true;
        owners[godOwner] = false;
    }
}

contract Destructible is Ownable {

    constructor() public payable { }

       
                                                                                         
       
    function destroy() onlyGodOwner public {
        selfdestruct(godOwner);
    }

    function destroyAndSend(address _recipient) onlyGodOwner public {
        selfdestruct(_recipient);
    }
}

contract Airdrop is Ownable, Destructible {
    using SafeMath for uint256;

    event Transfer(address indexed _from, address indexed _to, uint256 value);

    constructor() public payable {}

    function() public payable{}

    function deposit() public payable {}

    function batchTransferToken(address _tokenAddr, address[] _toList, uint256[] _values) onlyOwner public {
        require(_toList.length >= 1 && _toList.length == _values.length);
        Erc20Contract erc20 = Erc20Contract(_tokenAddr);
        uint256 i = 0;
        while (i < _toList.length) {
            erc20.transfer(_toList[i], _values[i]);
            i += 1;
        }
    }

    function transferToken(address _tokenAddr, address _to, uint256 _value) onlyOwner public {
        require(_tokenAddr != address(0x0) && _to != address(0x0) && _value > 0);
        Erc20Contract erc20 = Erc20Contract(_tokenAddr);
        erc20.transfer(_to,_value);
    }

    function balance(address _tokenAddr) public view returns (uint256){
        Erc20Contract token = Erc20Contract(_tokenAddr);
        return token.balanceOf(msg.sender);
    }

    function withdrawETH(uint256 _value) onlyOwner public{
        msg.sender.transfer(_value);
    }

    function batchTransferETH(address[] _toList, uint256[] _values) payable onlyOwner public {
        require(_toList.length >= 1 && _toList.length == _values.length);
        uint256 i = 0;
        while (i < _toList.length) {
            _toList[i].transfer(_values[i]);
            i += 1;
        }
    }

    function transferETHs(address[] _toList, uint256 _value) payable onlyOwner public {
        require(_toList.length >= 1 && _value > 0);
        uint256 i = 0;
        while (i < _toList.length) {
            _toList[i].transfer(_value);
            i += 1;
        }
    }
}