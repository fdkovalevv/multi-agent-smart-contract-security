contract ConstructorCreate{
    B b = new B();

    function check(){
        assert(b.foo() == 10);
    }

}