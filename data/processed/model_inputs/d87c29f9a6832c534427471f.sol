contract Overflow {
    uint private sellerBalance=0;
    
    function safe_add(uint value) returns (bool){
        require(value + sellerBalance >= sellerBalance);
        sellerBalance += value; 
    } 
}