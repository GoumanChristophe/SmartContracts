// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TokenJournalized {
    address[] private _companyAddresses;
    address[] private _adminAddresses;
    address private owner;


    constructor() {
        _companyAddresses.push(msg.sender);
        _adminAddresses.push(msg.sender);
        owner = msg.sender;
    }

    modifier onlyForCompany() {
        bool found = false;
        for (uint256 i = 0; i < _companyAddresses.length; i++) {
            if (_companyAddresses[i] == msg.sender) {
                found = true;
                break;
            }
        }
        for (uint256 i = 0; i < _adminAddresses.length; i++) {
            if (_adminAddresses[i] == msg.sender) {
                found = true;
                break;
            }
        }
        require(found, "Access denied");
        _;
    }

    modifier onlyAdminAddresses() {
        bool found = false;
        for (uint256 i = 0; i < _adminAddresses.length; i++) {
            if (_adminAddresses[i] == msg.sender) {
                found = true;
                break;
            }
        }
        require(found, "Access denied");
        _;
    }

    function addCompany(address company) public onlyAdminAddresses returns (bool) {
        _companyAddresses.push(company);
        return true;
    }

    function addAdmin(address company) public onlyAdminAddresses returns (bool) {
        _adminAddresses.push(company);
        return true;
    }

    function deleteCompany(address company) public onlyAdminAddresses returns (bool) {
        for (uint256 i = 0; i < _companyAddresses.length; i++) {
            if (_companyAddresses[i] == company) {
                delete _companyAddresses[i];
                break;
            }
        }
        return true;
    }

    function deleteAdmin(address admin) public onlyAdminAddresses returns (bool) {
        for (uint256 i = 0; i < _adminAddresses.length; i++) {
            if (_adminAddresses[i] == admin) {
                delete _companyAddresses[i];
                break;
            }
        }
        return true;
    }


    function getCompanyAddresses() public onlyAdminAddresses view returns (address[] memory) {
        return _companyAddresses;
    }

    function getAdminAddresses() public onlyAdminAddresses view returns (address[] memory) {
        return _adminAddresses;
    }

    function isAuthorizedCompany(address author) public view returns (bool) {
        for (uint256 i = 0; i != _companyAddresses.length; i++) {
            if (author == _companyAddresses[i])
                return true;
        }
        return false;
    }

    function isAuthorizedAdmin(address author) public view returns (bool) {
        for (uint256 i = 0; i != _adminAddresses.length; i++) {
            if (author == _adminAddresses[i])
                return true;
        }
        return false;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}