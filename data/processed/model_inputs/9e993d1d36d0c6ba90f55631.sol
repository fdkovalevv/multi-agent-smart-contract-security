contract ShadowingInFunctions {
    uint n = 2;
    uint x = 3;

    function test1() constant returns (uint n) {
        return n;                 
    }

    function test2() constant returns (uint n) {
        n = 1;
        return n;                 
    }

    function test3() constant returns (uint x) {
        uint n = 4;
        return n+x;                 
    }
}