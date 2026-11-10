contract owned {
    address public owner;

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnerShip(address newOwer) public onlyOwner {
        owner = newOwer;
    }

}

contract SelfDesctructionContract is owned {
   
   string  public someValue;
   modifier ownerRestricted {
      require(owner == msg.sender);
      _;
   } 
 
   function SelfDesctructionContract() {
      owner = msg.sender;
   }
   
   function setSomeValue(string value){
      someValue = value;
   } 

   function destroyContract() ownerRestricted {
     selfdestruct(owner);
   }
}