contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x51e0ddd9998364a2eb38588679f0d2c42653e4a6);
    address public trustee = 0xe7535ddfcbefe5c318d271476d068d5f7cf77290;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}