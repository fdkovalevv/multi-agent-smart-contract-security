contract RuntimeCreateUserInput{

    function check(uint x){
        B b = new B(x);
        assert(b.foo() == 10);
    }

}