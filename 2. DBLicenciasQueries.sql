-- a Top de empresas que sus trabajadores presentan más licencias.
SELECT
    Q.nombreEmpresa,
    Q.rutEmpresa,
    Q.licenciasEmitidas
FROM
    (
        SELECT
            empresas.nombreEmpresa,
            empresas.rutEmpresa,
            COUNT(*) as licenciasEmitidas
        FROM
            empresas
            inner join licencias ON (empresas.idEmpresa = licencias.idEmpresa)
        GROUP BY
            empresas.nombreEmpresa,
            empresas.rutEmpresa
    ) as Q
ORDER BY
    Q.licenciasEmitidas DESC

-- b Las sucursales que reciben más documentación, segmentados por región o comuna, así como sucursales que no están aptas para recibir documentación.
--Reciben mas documentación
SELECT
    idSucursal,
    nombreSucursal,
    region,
    documentos
FROM
    (
        SELECT
            sucursales.idSucursal,
            sucursales.nombreSucursal,
            region,
            COUNT(*) as documentos
        FROM
            sucursales
            inner join licencias on (sucursales.idSucursal = licencias.idSucursal)
            INNER JOIN licenciaDocumentacionIngresada ON (
                licencias.idLicencia = licenciaDocumentacionIngresada.idLicencia
            )
        GROUP BY
            sucursales.idSucursal,
            sucursales.nombreSucursal,
            region
    ) as Q
order by
    documentos

    --No aptas recibir documentación
    SELECT
        idSucursal,
        nombreSucursal
    FROM
        sucursales
    where
        aptaRecibirDocumentacion = 0

--c Top de documentos que hacen que la licencia reinicie su flujo
SELECT
    nombreLicencia,
    documentosNoValidos
FROM
    (
        SELECT
            nombreLicencia,
            count(*) as documentosNoValidos
        FROM
            licenciaDocumentacionIngresada
            inner join tipoLicenciaDocumentacionRequerida on ( tipoLicenciaDocumentacionRequerida.idTipoLicenciaDocumentacionRequerida = licenciaDocumentacionIngresada.idTipoLicenciaDocumentacionRequerida)
            INNER JOIN tipoLicencia ON ( tipoLicencia.idTipoLicencia = tipoLicenciaDocumentacionRequerida.idTipoLicencia )
        where
            documentacionValida = 0
        GROUP by
            nombreLicencia
    ) as Q
ORDER BY
    documentosNoValidos DESC

--d Tiempos promedios, mínimos y máximos, desde el inicio del proceso hasta el cálculo del monto a pagar por cada licencia
SELECT
    MIN(DATEDIFF (day, registro, fechaAprobada)) as dias_minimo,
    AVG(DATEDIFF (day, registro, fechaAprobada)) as dias_promedio,
    MAX(DATEDIFF (day, registro, fechaAprobada)) as dias_maximo,
    count(*) as cantidad_licencias
FROM
    licencias
where
    aprobada = 1

--e Estadísticas de licencias manuales vs electrónicas vs mixtas
SELECT
    nombreLicencia,
    count(*) as cantidad
FROM
    tipoLicencia
    INNER JOIN Licencias ON (
        tipoLicencia.idTipoLicencia = Licencias.idTipoLicencia
    )
GROUP BY
    nombreLicencia

--f Los estados del proceso que almacenan la mayor cantidad de licencias
SELECT
    estado,
    count(*)
FROM
    Licencias
group by
    estado

--g Trabajadores que tienen licencia y son desafiliados
SELECT
    trabajador.rutTrabajador,
    trabajador.nombreTrabajador,
    empresas.nombreEmpresa
FROM
    licencias
    Inner join trabajador ON (trabajador.idTrabajador = licencias.idTrabajador)
    Inner join empresas ON (empresas.idEmpresa = licencias.idEmpresa)
    LEFT JOIN empresaAfiliada ON (empresas.idEmpresa = empresaAfiliada.idEmpresa)
WHERE
    empresaAfiliada.idEmpresa is NULL

--h Manejo de data histórica, de validación de procesos y log’s de cambios de estado o actualización de data relevante.
    -- Creación de Triggers on Insert|Update|Delete asociado a tabla Licencia->LicenciaLog

    CREATE TRIGGER  LicenciasLogTG ON licencias
AFTER
UPDATE
,
    DELETE AS IF EXISTS (
        SELECT
            *
        FROM
            Inserted
    ) -- UPDATE Statement was executed
INSERT INTO
    licenciasLog (
        idLicencia,
        idTipoLicencia,
        idSucursal,
        idEmpresa,
        idTrabajador,
        fechaIni,
        fechaFin,
        registro,
        rechazada,
        fechaRechazada,
        aprobada,
        fechaAprobada,
        pagada,
        fechaPago,
        monto,
        estado
    )
SELECT
    d.idLicencia,
    d.idTipoLicencia,
    d.idSucursal,
    d.idEmpresa,
    d.idTrabajador,
    d.fechaIni,
    d.fechaFin,
    d.registro,
    d.rechazada,
    d.fechaRechazada,
    d.aprobada,
    d.fechaAprobada,
    d.pagada,
    d.fechaPago,
    d.monto,
    d.estado
FROM
    Deleted d
    INNER JOIN Inserted i ON i.Id = d.Id
    ELSE -- DELETE Statement was executed
INSERT INTO
    licenciasLog (
        idLicencia,
        idTipoLicencia,
        idSucursal,
        idEmpresa,
        idTrabajador,
        fechaIni,
        fechaFin,
        registro,
        rechazada,
        fechaRechazada,
        aprobada,
        fechaAprobada,
        pagada,
        fechaPago,
        monto,
        estado
    )
SELECT
    i.idLicencia,
    i.idTipoLicencia,
    i.idSucursal,
    i.idEmpresa,
    i.idTrabajador,
    i.fechaIni,
    i.fechaFin,
    i.registro,
    i.rechazada,
    i.fechaRechazada,
    i.aprobada,
    i.fechaAprobada,
    i.pagada,
    i.fechaPago,
    i.monto,
    i.estado
FROM
    Deleted
GO
    -- Observador en el Codigo



