contract EvalBiz {
	address public owner;

	struct Rating {
		address author;
		uint score;
		string comments;
	}
	mapping (bytes32 => Rating[]) public ratings;

	function EvalBiz() {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		if(msg.sender != owner) throw;                        
		_;
    }

    function sendRating(bytes32 key, uint score, string comments) public {
        Rating memory r;
        r.author = msg.sender;
        r.score = score;
        r.comments = comments;
    	ratings[key].push(r);
    }

                                                                                            
                                                                             
       
}