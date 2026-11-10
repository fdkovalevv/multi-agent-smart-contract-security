contract Tokensale {
    uint hardcap = 10000 ether;

    function Tokensale() {}

    function fetchCap() public constant returns(uint) {
        return hardcap;
    }
}

contract Presale is Tokensale {
    uint hardcap = 1000 ether;

    function Presale() Tokensale() {}
}