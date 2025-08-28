# ProyectoFinalBootcamp
hecho por: 
- David Sagales Mamani 
- Amilcar Brandon Zamora Paredes

# ¿Como utilizar el codigo Vehiculo.sol?
Requisitos Previos
- Contrato desplegado en Remix IDE
- MetaMask conectado a una red de prueba
- ETH de prueba disponible
- Secuencia de Operaciones

Registrar un Vehículo
- Encuentra la función registerVehicle en la interfaz
- Ingresa el número de placa (ejemplo: "ABC123")
- Haz clic en "transact"
- Confirma la transacción en MetaMask

Estacionar el Vehículo
- Busca park en la interfaz
- Ingresa dos parámetros:
  + Número de placa (ejemplo: "ABC123")
  + Número de plaza (ejemplo: 1)
- Haz clic en "transact"

Realizar un Pago
- Encuentra la función pay
- Ingresa el número de placa
- En "Value", ingresa el monto en wei (ejemplo: 10000000000000000 para 0.01 ETH)
- Haz clic en "transact"

Autorizar Retiro
- Busca authorizePickup
- Ingresa tres parámetros:
  + Número de placa
  + Dirección Ethereum autorizada
  + Horas de validez (ejemplo: 24)
- Haz clic en "transact"

Retirar el Vehículo
- Encuentra pickup
- Ingresa el número de placa
- Haz clic en "transact"
- Verificación
- Para verificar cada operación:

Usa getVehicleStatus para comprobar el estado del vehículo
- La función devolverá tres valores:
  + Estado de estacionamiento (bool)
  + Tiempo de entrada (timestamp)
  + Número de plaza (uint256)
