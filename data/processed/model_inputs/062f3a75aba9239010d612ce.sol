contract UnusedVariables {
    int a = 1;

    function unusedArg(int x) public view returns (int z) {
        z = x + a;  
    }

                                                           
    function unusedReturn(int x, int y) public pure returns (int m, int n,int o) {
        m = y - x;
        o = m/2;
    }

                         
    function neverAccessed(int test) public pure returns (int) {
        int z = 10;

        if (test > z) {
            return test - z;
        }

        return z;
    }
    
    function tupleAssignment(int p) public returns (int q, int r){
        (q, , r) = unusedReturn(p,2);
        
    }

}