contract alwaysFalse{
    address public owner;
    
    constructor() public payable{
        owner = msg.sender;
        require(msg.value == 1 ether);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function withdrawMoney() onlyOwner external{
                      
        if(msg.sender == owner){
            revert();
        }
        msg.sender.transfer(address(this).balance);
    }
}