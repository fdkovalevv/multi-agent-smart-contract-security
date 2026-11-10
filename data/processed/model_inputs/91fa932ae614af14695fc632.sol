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