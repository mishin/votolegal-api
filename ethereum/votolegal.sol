contract VotoLegal {
    address owner;

    mapping (bytes32 => bytes32[]) public donations;

    modifier ownerOnly {
        if (msg.sender == owner) _
    }

    function VotoLegal() {
        owner = msg.sender;
    }

    function addDonation(bytes32 cpf, bytes32 id_donation) ownerOnly {
        donations[cpf].push(id_donation);
    }

    function getAllDonationsFromCandidate(bytes32 cpf) constant returns (bytes32[]) {
        return donations[cpf];
    }

    function destroy() ownerOnly {
        selfdestruct(owner);
    }
}

