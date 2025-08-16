// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract ParkingSystem {
    //estructura
    struct Vehicle {
        string plateNumber;
        address owner;
        uint256 entryTime;
        bool isParked;
        uint256 spotNumber;
    }

    struct Payment {
        uint256 amount;
        uint256 timestamp;
    }

    struct PickupAuthorization {
        address authorizedPerson;
        uint256 expiryTime;
        bool isActive;
    }

    //mapeos principales
    mapping(string => Vehicle) public vehicles;
    mapping(string => Payment[]) public payments;
    mapping(string => PickupAuthorization) public pickupAuths;

    // Eventos
    event VehicleRegistered(string plateNumber, address owner);
    event VehicleParked(string plateNumber, uint256 spotNumber);
    event PaymentMade(string plateNumber, uint256 amount);
    event PickupAuthorized(string plateNumber, address authorizedPerson);

    // Modificador para verificar propietario
    modifier onlyOwner(string memory _plateNumber) {
        require(vehicles[_plateNumber].owner == msg.sender, "No eres el propietario");
        _;
    }

    //registro de vehiculo
    function registerVehicle(string memory _plateNumber) public {
        require(!vehicles[_plateNumber].isParked, "Vehiculo ya registrado");
        
        vehicles[_plateNumber] = Vehicle({
            plateNumber: _plateNumber,
            owner: msg.sender,
            entryTime: 0,
            isParked: false,
            spotNumber: 0
        });

        emit VehicleRegistered(_plateNumber, msg.sender);
    }

    //estacionar vehiculo
    function park(string memory _plateNumber, uint256 _spotNumber) public onlyOwner(_plateNumber) {
        require(!vehicles[_plateNumber].isParked, "Vehiculo ya esta estacionado");
        
        vehicles[_plateNumber].entryTime = block.timestamp;
        vehicles[_plateNumber].spotNumber = _spotNumber;
        vehicles[_plateNumber].isParked = true;

        emit VehicleParked(_plateNumber, _spotNumber);
    }

    // Realizar pago
    function pay(string memory _plateNumber) public payable onlyOwner(_plateNumber) {
        require(vehicles[_plateNumber].isParked, "Vehiculo no esta estacionado");

        payments[_plateNumber].push(Payment({
            amount: msg.value,
            timestamp: block.timestamp
        }));

        emit PaymentMade(_plateNumber, msg.value);
    }

    // Autorizar retiro de vehículo
    function authorizePickup(string memory _plateNumber, address _authorizedPerson, uint256 _expiryHours) public onlyOwner(_plateNumber) {
        require(vehicles[_plateNumber].isParked, "Vehiculo no esta estacionado");
        require(payments[_plateNumber].length > 0, "Pago pendiente");

        pickupAuths[_plateNumber] = PickupAuthorization({
            authorizedPerson: _authorizedPerson,
            expiryTime: block.timestamp + (_expiryHours * 1 hours),
            isActive: true
        });

        emit PickupAuthorized(_plateNumber, _authorizedPerson);
    }

    //retirar vehiculo
    function pickup(string memory _plateNumber) public {
        require(vehicles[_plateNumber].isParked, "Vehiculo no esta estacionado");
        require(payments[_plateNumber].length > 0, "Pago pendiente");

        PickupAuthorization memory auth = pickupAuths[_plateNumber];
        require(auth.isActive && block.timestamp <= auth.expiryTime, "Autorizacion expirada o invalida");
        require(msg.sender == vehicles[_plateNumber].owner || msg.sender == auth.authorizedPerson, "No autorizado");

        delete pickupAuths[_plateNumber];
        vehicles[_plateNumber].isParked = false;
        vehicles[_plateNumber].spotNumber = 0;
    }

    //consultas
    function getVehicleStatus(string memory _plateNumber) public view returns(bool, uint256, uint256) {
        Vehicle memory v = vehicles[_plateNumber];
        return (
            v.isParked,
            v.entryTime,
            v.spotNumber
        );
    }

    function getTotalPayments(string memory _plateNumber) public view returns(uint256) {
        uint256 total;
        for(uint i = 0; i < payments[_plateNumber].length; i++) {
            total += payments[_plateNumber][i].amount;
        }
        return total;
    }
}