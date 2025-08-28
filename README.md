# ProyectoFinalBootcamp
hecho por: 
- David Sagales Mamani 
- Amilcar Brandon Zamora Paredes

#
#
# ¿Como utilizar el contrato SistemaEstacionamientoMejorado.sol?
+ El contrado puede correr en la misma pagina de Remix no es necesario conectar a MetaMask. Bebe primero crear un achivo .sol copiar y pegar el codigo, compilar y finalmente hacer Deploy "Publicar".

Paso 1: Registrar Vehículo
- Función: registrarVehiculo.
- Datos: Ingresa _matricula (ej. "ABC123" como string).
- Orden: Primero siempre, ya que otros pasos requieren registro.
- En Remix: Expande el contrato desplegado, ingresa en el campo, clic en botón. Confirma en MetaMask.
- Verifica: Llama obtenerEstadoVehiculo("ABC123") (devuelve false, 0, 0).

Paso 2: Estacionar Vehículo
- Función: estacionar.
- Datos: _matricula (ej. "ABC123"), _numeroLugar (ej. 1 como uint256). Elige un número no ocupado (verifica con lugaresOcupados(1) si es false).
- Orden: Después de registrar. Requiere ser propietario.
- En Remix: Ingresa valores, confirma transacción.
- Verifica: obtenerEstadoVehiculo devuelve true, timestamp actual, 1.

Paso 3: Realizar Pago
- Función: pagar.
- Datos: _matricula (ej. "ABC123"). En Remix, en "Value" pon monto (ej. 0.001 ETH = 1000000000000000 wei).
- Orden: Después de estacionar. Puedes pagar múltiples veces.
- En Remix: Ingresa matrícula, pon Value, confirma.
- Verifica: obtenerTotalPagos("ABC123") devuelve el total.

Paso 4: Autorizar Retiro (Opcional)
- Función: autorizarRetiro.
- Datos: _matricula (ej. "ABC123"), _personaAutorizada (otra dirección MetaMask, ej. 0x123...), _horasExpiracion (ej. 2).
- Orden: Después de pagar al menos una vez.
- En Remix: Ingresa valores, confirma.
- Nota: Si no autorizas, el propietario aún puede retirar.

Paso 5: Retirar Vehículo
- Función: retirar.
- Datos: _matricula (ej. "ABC123").
- Orden: Último, después de pagar. Si autorizaste, usa la cuenta autorizada.
- En Remix: Ingresa, confirma. Libera el lugar automáticamente.
- Verifica: obtenerEstadoVehiculo devuelve false, timestamp viejo, 0. lugaresOcupados(1) es false.

Paso Extra: Retirar Fondos (Solo Admin)
- Función: retirarFondos.
- Datos: _destino (tu dirección), _monto (en wei, ej. balance total).
- Orden: Cuando quieras, después de pagos.
- En Remix: Usa la cuenta del desplegador (admin).

#
#
# ¿Como utilizar el codigo Vehiculo.sol?
Requisitos Previos
- Contrato desplegado en Remix IDE
- MetaMask conectado a una red de prueba
- ETH de prueba disponible
- Secuencia de Operaciones
- 
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
