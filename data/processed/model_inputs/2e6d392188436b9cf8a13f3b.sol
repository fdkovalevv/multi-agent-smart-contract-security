contract RuntimeUserInputCall{

    function check(address b){
        assert(B(b).foo() == 10);
    }

}