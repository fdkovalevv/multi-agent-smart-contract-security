contract GasModel{
    uint x = 100;
    function check() external{
        uint a = gasleft();
        x = x + 1;
        uint b = gasleft();
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
                      
        assert(b > a);
    }
}