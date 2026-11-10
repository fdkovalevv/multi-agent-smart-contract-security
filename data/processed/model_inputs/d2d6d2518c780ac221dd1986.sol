contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x782495b7b3355efb2833d56ecb34dc22ad7dfcc4);
    address public trustee = 0x5a422fb07fc9270f5b310fc61f85b8e779cb29a2;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}