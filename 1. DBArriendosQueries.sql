--a Indicar cuales arrendatarios sus arriendos vencen el próximo mes.
SELECT
    distinct Arrendatario.rutArrendatario,
    Arrendatario.nombre
FROM
    Arriendos
    INNER JOIN Arrendatario ON (
        Arriendos.idArrendatario = Arrendatario.idArrendatario
    )
WHERE
    MONTH(Arriendos.fechaFin) = MONTH(DATEADD(MONTH, 1, GETDATE()))
    AND YEAR(Arriendos.fechaFin) = YEAR(DATEADD(MONTH, 1, GETDATE())) 
    
--b	Indicar cuales propietarios tienen al menos una propiedad sin arrendar
SELECT
    Propietarios.idPropietario,
    Propietarios.nombre,
    Propietarios.rutPropietario
FROM
    Propietarios
WHERE
    (
        SELECT
            COUNT(Propiedad.idPropiedad)
        FROM
            Propiedad
            LEFT JOIN Arriendos ON (
                Propiedad.idPropiedad = Arriendos.idPropiedad
                and Arriendos.idPropietarios = Propiedad.idPropietario
            )
        WHERE
            Propietarios.idPropietario = Propiedad.idPropietario
            and Arriendos.idPropietarios is NULL
    ) > 0

--c Indicar cuantas propiedades tiene cada propietario por cada país
SELECT
    Propietarios.idPropietario,
    Propietarios.nombre,
    Propietarios.rutPropietario,
    Propiedad.pais,
    COUNT(idPropiedad) as propiedad_pais 
FROM
    Propietarios INNER JOIN Propiedad ON (Propietarios.idPropietario = Propiedad.idPropietario)
GROUP BY  
    Propietarios.idPropietario,
    Propietarios.nombre,
    Propietarios.rutPropietario,
    Propiedad.pais

--d	Indicar cuales propietarios son también arrendatarios
SELECT
    Propietarios.idPropietario,
    Propietarios.nombre,
    Propietarios.rutPropietario
FROM
    Propietarios
    INNER JOIN Arrendatario ON ( Propietarios.rutPropietario = Arrendatario.rutArrendatario )
    INNER JOIN Arriendos ON ( Arriendos.idArrendatario = Arrendatario.idArrendatario )
    INNER JOIN Propiedad ON ( Propietarios.idPropietario = Propiedad.idPropietario )
GROUP BY
    Propietarios.idPropietario,
    Propietarios.nombre,
    Propietarios.rutPropietario

--e	Indicar cuales arrendatarios arriendan fuera de chile
SELECT
    Arrendatario.idArrendatario,
    Arrendatario.nombre,
    Arrendatario.rutArrendatario
FROM
    Arrendatario
    INNER JOIN Arriendos ON (Arriendos.idArrendatario=Arrendatario.idArrendatario) 
    INNER JOIN Propiedad ON (Propiedad.idPropiedad=Arriendos.idPropiedad)
    WHERE LOWER(Propiedad.pais) <> 'chile'
GROUP BY  
    Arrendatario.idArrendatario,
    Arrendatario.nombre,
    Arrendatario.rutArrendatario

--f	Indicar cuales son los 3 países que el monto promedio de arriendo son los más altos.
SELECT
    TOP 3
    Q.pais,
    Q.promedio_pais
FROM (
    SELECT
        Propiedad.pais,
        AVG(Arriendos.monto) as promedio_pais
    FROM
        Arriendos
        INNER JOIN Propiedad ON (Propiedad.idPropiedad=Arriendos.idPropiedad)
        GROUP BY Propiedad.pais
    ) as Q 
ORDER BY Q.promedio_pais DESC

--g	Indicar el monto promedio, mínimo y máximo que pagan arrendatarios que también son propietarios
SELECT    
    COALESCE(AVG(monto),0) as promedio,
    COALESCE(MIN(monto),0) as minimo,
    COALESCE(MAX(monto),0) as maximo
FROM
    Propietarios
    INNER JOIN Arrendatario ON ( Propietarios.rutPropietario = Arrendatario.rutArrendatario )
    INNER JOIN Arriendos ON ( Arriendos.idArrendatario = Arrendatario.idArrendatario )
    INNER JOIN Propiedad ON ( Propietarios.idPropietario = Propiedad.idPropietario )