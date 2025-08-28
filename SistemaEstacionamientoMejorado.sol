// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SistemaEstacionamiento {
    // Estructura para Vehiculo
    struct Vehiculo {
        string matricula;
        address propietario;
        uint256 horaEntrada;
        bool estaEstacionado;
        uint256 numeroLugar;
        uint256 totalPagos;  // Acumulador de pagos para optimizar consultas
    }

    // Estructura para Pago (mantenemos para registro historico, pero usamos acumulador para total
    struct Pago {
        uint256 monto;
        uint256 marcaTiempo;
    }

    // Estructura para Autorización de Retiro
    struct AutorizacionRetiro {
        address personaAutorizada;
        uint256 tiempoExpiracion;
        bool estaActiva;
    }

    // Mapeos principales
    mapping(string => Vehiculo) public vehiculos;
    mapping(string => Pago[]) public pagos;
    mapping(string => AutorizacionRetiro) public autorizacionesRetiro;
    mapping(uint256 => bool) public lugaresOcupados;  // Nuevo: Para rastrear lugares de estacionamiento disponibles

    // Direccion del administrador del contrato (dueño del estacionamiento
    address public administrador;

    // Eventos
    event VehiculoRegistrado(string matricula, address propietario);
    event VehiculoEstacionado(string matricula, uint256 numeroLugar);
    event PagoRealizado(string matricula, uint256 monto);
    event RetiroAutorizado(string matricula, address personaAutorizada);
    event VehiculoRetirado(string matricula, address retiradoPor);  // evento para retiro
    event FondosRetirados(address to, uint256 monto);  // evento para retiro de fondos

    // Modificador para verificar propietario del vehiculo
    modifier soloPropietario(string memory _matricula) {
        require(vehiculos[_matricula].propietario == msg.sender, "No eres el propietario");
        _;
    }

    // Modificador para verificar administrador
    modifier soloAdministrador() {
        require(msg.sender == administrador, "No eres el administrador");
        _;
    }

    // Constructor: Asigna al desplegador como administrador
    constructor() {
        administrador = msg.sender;
    }

    // Registro de vehiculo
    function registrarVehiculo(string memory _matricula) public {
        require(vehiculos[_matricula].propietario == address(0), "Vehiculo ya registrado");  //Verifica si ya existe
        
        vehiculos[_matricula] = Vehiculo({
            matricula: _matricula,
            propietario: msg.sender,
            horaEntrada: 0,
            estaEstacionado: false,
            numeroLugar: 0,
            totalPagos: 0
        });

        emit VehiculoRegistrado(_matricula, msg.sender);
    }

    // Estacionar vehiculo
    function estacionar(string memory _matricula, uint256 _numeroLugar) public soloPropietario(_matricula) {
        require(vehiculos[_matricula].propietario != address(0), "Vehiculo no registrado");  //Asegura que este registrado
        require(!vehiculos[_matricula].estaEstacionado, "Vehiculo ya esta estacionado");
        require(!lugaresOcupados[_numeroLugar], "Lugar ocupado");  //Verifica disponibilidad
        
        lugaresOcupados[_numeroLugar] = true;  // Marca como ocupado
        vehiculos[_matricula].horaEntrada = block.timestamp;
        vehiculos[_matricula].numeroLugar = _numeroLugar;
        vehiculos[_matricula].estaEstacionado = true;

        emit VehiculoEstacionado(_matricula, _numeroLugar);
    }

    // Realizar pago
    function pagar(string memory _matricula) public payable soloPropietario(_matricula) {
        require(vehiculos[_matricula].estaEstacionado, "Vehiculo no esta estacionado");
        require(msg.value > 0, "Monto de pago debe ser mayor a cero");  //Validacion basica

        pagos[_matricula].push(Pago({
            monto: msg.value,
            marcaTiempo: block.timestamp
        }));

        vehiculos[_matricula].totalPagos += msg.value;  //Actualiza acumulador

        emit PagoRealizado(_matricula, msg.value);
    }

    // Autorizar retiro de vehículo
    function autorizarRetiro(string memory _matricula, address _personaAutorizada, uint256 _horasExpiracion) public soloPropietario(_matricula) {
        require(vehiculos[_matricula].estaEstacionado, "Vehiculo no esta estacionado");
        require(pagos[_matricula].length > 0, "Pago pendiente");
        require(_personaAutorizada != address(0), "Direccion invalida");  //Validacion de direccion
        require(_horasExpiracion >= 1 && _horasExpiracion <= 24, "Horas de expiracion deben ser entre 1 y 24");  //Rango razonable

        autorizacionesRetiro[_matricula] = AutorizacionRetiro({
            personaAutorizada: _personaAutorizada,
            tiempoExpiracion: block.timestamp + (_horasExpiracion * 1 hours),
            estaActiva: true
        });

        emit RetiroAutorizado(_matricula, _personaAutorizada);
    }

    // Retirar vehículo
    function retirar(string memory _matricula) public {
        require(vehiculos[_matricula].estaEstacionado, "Vehiculo no esta estacionado");
        require(vehiculos[_matricula].totalPagos > 0, "Pago pendiente");  //Usa acumulador en lugar de length

        AutorizacionRetiro memory auth = autorizacionesRetiro[_matricula];
        bool esAutorizado = (msg.sender == vehiculos[_matricula].propietario) || 
                            (auth.estaActiva && block.timestamp <= auth.tiempoExpiracion && msg.sender == auth.personaAutorizada);
        require(esAutorizado, "No autorizado para retirar");

        // Libera el lugar de estacionamiento
        lugaresOcupados[vehiculos[_matricula].numeroLugar] = false;  //Libera el spot

        delete autorizacionesRetiro[_matricula];
        vehiculos[_matricula].estaEstacionado = false;
        vehiculos[_matricula].numeroLugar = 0;
        // No reseteamos totalPagos ni pagos, para mantener historial, pero podrías agregar opcion para limpiar si quieres

        emit VehiculoRetirado(_matricula, msg.sender);
    }

    // Función para que el administrador retire fondos acumulados
    function retirarFondos(address payable _destino, uint256 _monto) public soloAdministrador {
        require(_monto <= address(this).balance, "Fondos insuficientes");
        require(_destino != address(0), "Direccion invalida");

        _destino.transfer(_monto);

        emit FondosRetirados(_destino, _monto);
    }

    // Consultas
    function obtenerEstadoVehiculo(string memory _matricula) public view returns(bool, uint256, uint256) {
        Vehiculo memory v = vehiculos[_matricula];
        return (
            v.estaEstacionado,
            v.horaEntrada,
            v.numeroLugar
        );
    }

    function obtenerTotalPagos(string memory _matricula) public view returns(uint256) {
        return vehiculos[_matricula].totalPagos;  //Usa acumulador, evita iteracion costosa
    }
}