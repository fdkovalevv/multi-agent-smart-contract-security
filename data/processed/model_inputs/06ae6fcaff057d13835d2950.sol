contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0xa2f1ccba9395d7fcb155bba8bc92db9bafaeade7);
    address public trustee = 0x208e4a03118380b4f63cf056ecbfe0a241a41b46;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}