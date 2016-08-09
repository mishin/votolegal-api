contract VotoLegal {
    address owner;

    mapping (uint => bytes32[]) public donations;
    mapping (bytes32 => uint)   public indexes;

    modifier ownerOnly {
        if (msg.sender == owner) _
    }

    function VotoLegal() {
        owner = msg.sender;
    }

    function addDonation(uint id_candidate, bytes32 id_donation) ownerOnly {
        indexes[id_donation] = id_candidate;

        donations[id_candidate].push(id_donation);
    }

    function getAllDonationsFromCandidate(uint id_candidate) constant returns (bytes32[]) {
        return donations[id_candidate];
    }

    function getDonation(bytes32 id_donation) constant returns (uint id_candidate) {
        id_candidate = 0;
        if (indexes[id_donation] > 0) {
            id_candidate = indexes[id_donation];
        }
    }

    function destroy() ownerOnly {
        selfdestruct(owner);
    }
}

