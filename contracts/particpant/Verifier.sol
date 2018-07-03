pragma solidity ^0.4.18;

import "../EIP820/EIP820Implementer.sol";
import "../EIP820/IEIP820Implementer.sol";
import "./IParticipant.sol";
import "./Participant.sol";


contract Verifier is Participant {
    mapping (address => bool) public verifiers;
    mapping(bytes32 =>  mapping(address => bool)) public allowedInterfaces;
    

    function Verifier(address _participantRegistry, address _eip820RegistryAddr) Participant(_participantRegistry, _eip820RegistryAddr) public { 
        setInterfaceImplementation("IVerifier", this);
        toggleParticipantType(true);
    }

    function canImplementInterfaceForAddress(address addr, bytes32 interfaceHash) public view returns(bytes32) {
        return EIP820_ACCEPT_MAGIC;
    }

    function isAllowed(address _ifaceImpAddr, string ifaceLabel) public returns (bool) {
        // verifier participant is enabled
        require(_isAllowed(this, "Verifier"));
        // sender is defined in verifiers
        require(verifiers[msg.sender] == true);
        // that the permission for the requested interface is enabled
        require(allowedInterfaces[keccak256(ifaceLabel)][_ifaceImpAddr]);
        return true;
    }

    /// @dev dynamic function (name + params) forwarder
    /// @dev example: forward(CRC, 0, 'Minting Data Here', ISomeInterface) 
    function forward(address destination, uint value, bytes data, string ifaceLabel) public {
        address _ifaceImpAddr = interfaceAddr(destination, ifaceLabel);
        if (_ifaceImpAddr != 0) {
            require(isAllowed(_ifaceImpAddr, ifaceLabel) == true);
            _forward(destination, value, data);
        } else {
            revert();
        }
        //jaycen todo all events
        //Forwarded(destination, value, data);
    }
    
    function toggleVerifier(address _verifier, bool _toggle) public {
        verifiers[_verifier] = _toggle;
    }

    function toggleParticipantType(bool _toggle) public {
        _toggleParticipantType("Verifier", this, _toggle);
    }
    
    function toggleInterface(string _ifaceLabel, address _ifaceImpAddr, bool _toggle) public {
        address ifaceImpAddr = interfaceAddr(_ifaceImpAddr, _ifaceLabel);
        if (ifaceImpAddr != 0) {
            allowedInterfaces[keccak256(_ifaceLabel)][ifaceImpAddr] = _toggle;
        } else {
            revert();
        }
    }
}