// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;


contract votes {

    address public owner;

    constructor () public {
        owner = msg.sender;
    }

    mapping (string => bytes32) id_candidate;
    mapping(string => uint) votes_candidate;

    string [] candidates;
    bytes32 [] voters;

    function AddCandidate (string memory _name, uint _age, string memory _dni ) public {

        bytes32 hash_candidate = keccak256(abi.encodePacked(_name, _age, _dni));

        id_candidate[_name] = hash_candidate;

        candidates.push(_name);
    }

    function getCandidates () public view returns(string[] memory ) {
        return candidates;
    }

    function Vote (string memory _candidate) public {

        bytes32 hash_voter = keccak256(abi.encodePacked(msg.sender));

        for( uint i=0; i < voters.length; i++ ) {
            require(voters[i] != hash_voter, "you already vote");
        }
        voters.push(hash_voter);
        votes_candidate[_candidate]++;
    }

    function getVotes ( string memory _candidateName) public view returns(uint) {
        return votes_candidate[_candidateName];
    }


    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function getResults () public view returns(string memory) {

        string memory results = "";

        for( uint i=0; i < candidates.length; i++ ) {
            results =  string(abi.encodePacked( results , "(" ,candidates[i] , ",", uint2str(getVotes(candidates[i])), ")-----" ));
        }
        return results;
    }

    function getWinner () public view returns(string memory) {

        string memory winner = candidates[0];
        bool flag;

        for( uint i=1 ; i < candidates.length; i++ ) {    

            if(getVotes(winner) < getVotes(candidates[i])) {
                winner = candidates[i];
                flag = false;
            }else{
                if(getVotes(winner) == getVotes(candidates[i])) {
                    flag = true;
                }
            }
        } 

        if(flag == true){
            winner = "there is a tie";
        }

        return winner;  
    }

}

