// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedVoting {
    address public administrator;
    bool public votingActive;
    uint8 public candidateCount; 
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    mapping(uint8 => Candidate) public candidates;
    mapping(address => bool) public voters;

    event Voted(address indexed voter, uint8 candidateId);
    event VotingStatusChanged(bool isActive);

    modifier onlyAdministrator() {
        require(msg.sender == administrator, "Only the administrator can call this function");
        _;
    }

    modifier onlyDuringVoting() {
        require(votingActive, "Voting is not active");
        _;
    }

    constructor() {
        administrator = msg.sender;
        votingActive = false;
        candidateCount = 0;
    }

    function addCandidate(string memory _name) external onlyAdministrator {
        candidates[candidateCount] = Candidate(_name, 0);
        candidateCount++;
    }

    function startVoting() external onlyAdministrator {
        require(!votingActive, "Voting is already active");
        votingActive = true;
        emit VotingStatusChanged(true);
    }

    function stopVoting() external onlyAdministrator onlyDuringVoting {
        votingActive = false;
        emit VotingStatusChanged(false);
    }

    function vote(uint8 _candidateId) external onlyDuringVoting {
        require(!voters[msg.sender], "You have already voted");
        require(_candidateId < candidateCount, "Invalid candidateId");

        voters[msg.sender] = true;
        candidates[_candidateId].voteCount++;

        emit Voted(msg.sender, _candidateId);
    }

    function getCandidate(uint8 _candidateId) external view returns (string memory, uint256) {
        require(_candidateId < candidateCount, "Invalid candidateId");
        Candidate storage candidate = candidates[_candidateId];
        return (candidate.name, candidate.voteCount);
    }

    function hasVoted() external view returns (bool) {
        return voters[msg.sender];
    }

    function isVotingActive() external view returns (bool) {
        return votingActive;
    }
}
