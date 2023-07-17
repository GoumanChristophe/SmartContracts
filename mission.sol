// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./dns.sol";

contract MissionContract {

    address[] private _companyContractAddresses;
    string[] private _contractName;

    address[] private _CompanyAdmins;
    address[] private _CompanyEmployees;

    address private owner;
    BoolMissionsStruct[] private _BoolMissions;
    event DebugLog(string message, bool value);


    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    struct BoolMissionsStruct {
        uint256 index;
        string mission;
        string description;
        uint256 reward;
        string tag;
        uint256 timestamp;
        bool ended;
    }

    struct missionStatus {
        string mission;
        string description;
        uint256 reward;
        string tag;
        uint256 timestamp;
        bool succeed;
        bool ended;
        bool confirmed;
        uint256 valitadedAt;
    }

    mapping (address => string[]) private validatedMissions;
    mapping (address => uint256[]) private validationDate;
    mapping (address => string[]) private inValidationMission;

    TokenJournalized tokenContract;
    DNSContract dns;

    modifier onlyCompanyAndOwner() {
        bool found = false;

        for (uint256 i; i != _CompanyAdmins.length; i++) {
            if (msg.sender == _CompanyAdmins[i]) {
                found = true;
                break;
            }
        }

        require(found, "Not administrator of this contract... Access denied !");
        _;
    }

    constructor(address dsnAddress, address token) {
        tokenContract = TokenJournalized(token);
        dns = DNSContract(dsnAddress);
        owner = msg.sender;
        _CompanyAdmins.push(msg.sender);
    }

    function addAContractAdministrator(address admin) public onlyCompanyAndOwner returns (bool) {
        _CompanyAdmins.push(admin);
        return true;
    }

    function deleteAContractAdministrator(address userToDelete) public onlyCompanyAndOwner returns (bool) {
        for (uint256 i = 0; i <= _CompanyAdmins.length; i++) {
            if (_CompanyAdmins[i] == userToDelete) {
                delete (_CompanyAdmins[i]);
                break;
            }
        }
        return true;
    }

/********************************************** Ex : Arriver à l'heure **********************************************************/
//possible tags : ponctuality, rigor,production, efficiency,partner
    function createABoolMission(string memory missionName, string memory missionDesc, uint256 reward, string memory tag) public onlyCompanyAndOwner returns (bool) {
        require(keccak256(abi.encodePacked(tag)) == keccak256(abi.encodePacked("punctuality")) || keccak256(abi.encodePacked(tag)) == keccak256(abi.encodePacked("rigor")) || keccak256(abi.encodePacked(tag)) == keccak256(abi.encodePacked("production")) || keccak256(abi.encodePacked(tag)) == keccak256(abi.encodePacked("efficiency")) || keccak256(abi.encodePacked(tag)) == keccak256(abi.encodePacked("partner")), "Tag not allowed");
        _BoolMissions.push(BoolMissionsStruct(_BoolMissions.length, missionName, missionDesc, reward, tag ,block.timestamp, false));
        return true;
    }

/*********************************************************************************************************************************/

    function getBoolMission(string memory missionName) public view returns (BoolMissionsStruct memory) {
        for (uint256 i = 0; i != _BoolMissions.length; i++) {
            if ((keccak256(abi.encodePacked(missionName))) == (keccak256(abi.encodePacked(_BoolMissions[i].mission)))) {
                return _BoolMissions[i];
            }
        }
        return (BoolMissionsStruct(0, "none", "none", 0,"none", 0, true));
    }


    function getAllAdmins() public view returns (address[] memory) {
        return _CompanyAdmins;
    }

    function validateBoolMission(string memory missionName, address employee, bool isCompleted) public onlyCompanyAndOwner  {
        bool missionExists = false;
        for (uint256 i = 0; i < _BoolMissions.length; i++) {
            if (keccak256(abi.encodePacked(_BoolMissions[i].mission)) == keccak256(abi.encodePacked(missionName))) {
                missionExists = true;
                break;
            }
        }
        require(isCompleted, "The Mission is not completed");
        
        
        inValidationMission[employee].push(missionName);
    }

    function validateBoolMissions(string[] memory missionNames, address[] memory employees, bool[] memory isCompletedArray) public onlyCompanyAndOwner  {
        require(missionNames.length == employees.length && employees.length == isCompletedArray.length, "The input arrays must have the same length");

        for (uint256 j = 0; j < missionNames.length; j++) {
            validateBoolMission(missionNames[j], employees[j], isCompletedArray[j]);
        }
    }


    function confirmMission(address employee, string memory missionName) public onlyCompanyAndOwner payable {
        bool missionExists = false;
        for (uint256 i = 0; i < inValidationMission[employee].length; i++) {
            if (keccak256(abi.encodePacked(inValidationMission[employee][i])) == keccak256(abi.encodePacked(missionName))) {
                missionExists = true;
                break;
            }
        }
        require(missionExists, "The mission is not in validation");
        validatedMissions[employee].push(missionName);
        validationDate[employee].push(block.timestamp);
        uint256 reward = getBoolMission(missionName).reward * 1 ether;
        (bool sent, bytes memory data) = employee.call{value: reward}("");
        require(sent, "Failed to send Ether");
        (bool tax, bytes memory datax) = owner.call{value: reward * 8 / 100}("");
        require(tax, "Failed to send Ether");
        
        // Supprimer la mission validée de la liste inValidationMission
        for (uint256 i = 0; i < inValidationMission[employee].length; i++) {
            if (keccak256(abi.encodePacked(inValidationMission[employee][i])) == keccak256(abi.encodePacked(missionName))) {
                delete inValidationMission[employee][i];
                break;
            }
        }
    }

    function deleteBoolMission(string memory missionName) public onlyCompanyAndOwner {
        for (uint256 i = 0; i < _BoolMissions.length; i++) {
            if (keccak256(abi.encodePacked(_BoolMissions[i].mission)) == keccak256(abi.encodePacked(missionName))) {
                delete (_BoolMissions[i]);
                break;
            }
        }
    }

    function setBoolMissionAsEnded (string memory missionName) public onlyCompanyAndOwner {
        for (uint256 i = 0; i < _BoolMissions.length; i++) {
            if (keccak256(abi.encodePacked(_BoolMissions[i].mission)) == keccak256(abi.encodePacked(missionName))) {
                _BoolMissions[i].ended = true;
                break;
            }
        }
    }

    function getEmployeeValidatedMissions(address employee) public view returns (string[] memory) {
        return validatedMissions[employee];
    }

    function createMissions(string[] memory missionNames, string[] memory descriptions, uint256[] memory reward, string[] memory tag) public onlyCompanyAndOwner  {
        require(missionNames.length == reward.length && reward.length == tag.length && tag.length == missionNames.length, "The input arrays must have the same length");

        for (uint256 j = 0; j < missionNames.length; j++) {
            createABoolMission(missionNames[j], descriptions[j], reward[j], tag[j]);
        }
    }

    function getEmployeeMissionsStatus(address employee) public view returns (missionStatus[] memory) {
        missionStatus[] memory missions = new missionStatus[](_BoolMissions.length);
        for (uint256 i = 0; i < _BoolMissions.length; i++) {
            bool status;
            if (isMissionValidatedByEmployee(_BoolMissions[i].mission, employee)) {
                status = true;
            } else {
                status = false;
            }
            missions[i].mission = _BoolMissions[i].mission;
            missions[i].succeed = status;
            missions[i].reward = _BoolMissions[i].reward;
            missions[i].description = _BoolMissions[i].description;
            missions[i].ended = _BoolMissions[i].ended;
            missions[i].tag = _BoolMissions[i].tag;
            
            // Vérifier si la mission est validée et confirmée par l'employé
            bool missionConfirmed = false;
            for (uint256 y = 0; y < validatedMissions[employee].length; y++) {
                if (keccak256(abi.encodePacked(_BoolMissions[i].mission)) == keccak256(abi.encodePacked(validatedMissions[employee][y]))) {
                    missions[i].valitadedAt = validationDate[employee][y];
                    missions[i].confirmed = true;
                    missionConfirmed = true;
                    break;
                }
            }
            
            // Si la mission n'est pas confirmée, réinitialiser les valeurs correspondantes
            if (!missionConfirmed) {
                missions[i].valitadedAt = 0;
                missions[i].confirmed = false;
            }
        }
        return missions;
    }


    function isMissionValidatedByEmployee(string memory mission, address employee) public view returns (bool) {
        for (uint256 i = 0; i != inValidationMission[employee].length; i++) {
            if (keccak256(abi.encodePacked(mission)) == keccak256(abi.encodePacked(inValidationMission[employee][i])))
                return true;
        }
        return false;
    }

        function isMissionValidatedAndConfirmedByEmployee(string memory mission, address employee) public view returns (bool) {
        for (uint256 i = 0; i != validatedMissions[employee].length; i++) {
            if (keccak256(abi.encodePacked(mission)) == keccak256(abi.encodePacked(validatedMissions[employee][i])))
                return true;
        }
        return false;
    }
    
}