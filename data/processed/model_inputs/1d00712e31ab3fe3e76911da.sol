contract Tokensale {
    uint public hardcap = 10000 ether;

    function Tokensale() {}

    function fetchCap() public constant returns(uint) {
        return hardcap;
    }
}

contract Presale is Tokensale {
                                
                                                                                        
    function Presale() Tokensale() {
        hardcap = 1000 ether;                                                                                        
    }
}