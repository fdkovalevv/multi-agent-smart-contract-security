contract no_privatePass {

  uint public owner;
  constructor(uint i_owner) public {
    owner = i_owner;
  }
  
                                               
  function resetOwner() external {
  	owner = 0;
  }
}