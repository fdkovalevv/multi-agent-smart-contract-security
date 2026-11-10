contract Owned {
    
    address public owner;
    mapping(address => bool) public owners;

    function Owned() public {
        owner = msg.sender;
        owners[msg.sender] = true;
    }

    modifier onlyOwners{
        address sen = msg.sender;
        require(owners[msg.sender] == true);
        _;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerOrigin{
        require(tx.origin == owner);
        _;
    }

    function addOwner(address newOwner) public onlyOwners{
        owners[newOwner] = true;
    }

    function removeOwner() public onlyOwners{
        owners[msg.sender] = false;
    }

    function removeOwner(address newOwner) public onlyOwner{
        owners[newOwner] = false;
    }

    function isOwner(address o) public view returns(bool){
        return owners[o] == true;
    }
}