contract B{

    uint x_;
    constructor(uint x){
        x_ = x;
    }

    function foo() returns(uint){
        return x_;
    }

    function set_x(uint x){
        x_ = x;
    }
}