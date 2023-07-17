// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TokenJournal.sol";

contract DNSContract {

    address[] private _companyContractAddresses;
    string[] private _contractName;
    address private owner;
    TokenJournalized tokenContract;

    constructor(address contractAddress) {
        tokenContract = TokenJournalized(contractAddress);
        owner = msg.sender;
    }

    function addCompanyContract(string memory contractName, address contractAdress) public returns (bool) {
        if (tokenContract.isAuthorizedAdmin(msg.sender) == true) {
            _companyContractAddresses.push(contractAdress);
            _contractName.push(contractName);
            return true;
        }
        return false;
    }

    function getContractByName(string memory contractName) public view returns (address) {
        for (uint256 i = 0; i < _contractName.length; i++) {
            if (keccak256(abi.encodePacked(contractName)) == keccak256(abi.encodePacked(_contractName[i]))) {
                return _companyContractAddresses[i];
            }
        }
        return address(0);
    }

}