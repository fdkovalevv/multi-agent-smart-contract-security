contract privatePass {

  uint private owner;
  constructor(uint i_owner) public {
    owner = i_owner;
  }
  
                                               
                                                                                                                                                                                                                                                                                                                                       
  function resetOwner() external {
  	owner = 0;
  }

  function getOwner() external returns(uint256){
  	return owner;
  }
}