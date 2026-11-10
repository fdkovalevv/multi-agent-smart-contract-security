contract ConstructorCreateArgument{
    B b = new B(11);

    function check(){
        assert(b.foo() == 10);
    }

}