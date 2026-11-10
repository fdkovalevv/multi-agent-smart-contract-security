contract Overflow {
    uint private sellerBalance=0;
    
  constructor() public{
      
  }
    
    function add(uint value) public returns (bool){
    	require(sellerBalance + value >= value);
        sellerBalance += value; 
    } 
}