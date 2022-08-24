CREATE TABLE empresas(
  idEmpresa INT IDENTITY(1,1) PRIMARY KEY,
  rutEmpresa VARCHAR(45),
  nombreEmpresa VARCHAR(45),
  ciudad varchar(45),
  comuna varchar(45),
  region varchar(45),
  pais varchar(45)
)

CREATE TABLE empresaAfiliada(
  idEmpresaAfiliada INT IDENTITY(1,1) PRIMARY KEY,
  idEmpresa INT NOT NULL,
  CONSTRAINT fkEmpresaEmpresaAfiliada FOREIGN KEY(idEmpresa) REFERENCES empresas(idEmpresa)
)

CREATE TABLE trabajador(
  idTrabajador INT IDENTITY(1,1) PRIMARY KEY,
  rutTrabajador VARCHAR(45),
  nombreTrabajador VARCHAR(45),
  idEmpresa INT NOT NULL,
  CONSTRAINT fkEmpresaTrabajador FOREIGN KEY(idEmpresa) REFERENCES empresas(idEmpresa)
)

CREATE TABLE sucursales(
  idSucursal INT IDENTITY(1,1) PRIMARY KEY,
  nombreSucursal VARCHAR(45),
  aptaRecibirDocumentacion bit DEFAULT 1,
  ciudad varchar(45),
  comuna varchar(45),
  region varchar(45),
  pais varchar(45)
)

CREATE TABLE tipoLicencia(
  idTipoLicencia INT IDENTITY(1,1) PRIMARY KEY,
  nombreLicencia VARCHAR(45) NOT NULL,
  documentacionPresencial bit NOT NULL
)

CREATE TABLE tipoLicenciaDocumentacionRequerida(
  idTipoLicenciaDocumentacionRequerida INT IDENTITY(1,1) PRIMARY KEY,
  idTipoLicencia INT NOT NULL,
  CONSTRAINT fkTipoLicenciaTipoLicenciaDocumentacionRequerida FOREIGN KEY(idTipoLicencia) REFERENCES tipoLicencia(idTipoLicencia)
)

CREATE TABLE licencias(
  idLicencia INT IDENTITY(1,1) PRIMARY KEY,
  idTipoLicencia INT NOT NULL,
  idSucursal INT NOT NULL,
  idEmpresa INT NOT NULL,
  fechaIni DATETIME NOT NULL,
  fechaFin DATETIME NOT NULL,
  registro DATETIME DEFAULT GETDATE(),
  rechazada bit,
  fechaRechazada DATETIME,
  aprobada bit,
  fechaAprobada DATETIME,
  pagada bit,
  fechaPago DATETIME,
  monto NUMERIC DEFAULT 0,
  estado VARCHAR(45),
  CONSTRAINT fkEmpresaLicencia FOREIGN KEY(idEmpresa) REFERENCES empresas(idEmpresa),
  CONSTRAINT fkSucursalLicencia FOREIGN KEY(idSucursal) REFERENCES sucursales(idSucursal),
  CONSTRAINT fkTipoLicenciaLicencias FOREIGN KEY(idTipoLicencia) REFERENCES tipoLicencia(idTipoLicencia)
)

CREATE TABLE licenciasLog(
  idLicenciaLog INT IDENTITY(1,1) PRIMARY KEY,
  idLicencia INT,
  idTipoLicencia INT NOT NULL,
  idSucursal INT NOT NULL,
  idEmpresa INT NOT NULL,
  fechaIni DATETIME NOT NULL,
  fechaFin DATETIME NOT NULL,
  registro DATETIME,
  rechazada bit,
  fechaRechazada DATETIME,
  aprobada bit,
  fechaAprobada DATETIME,
  pagada bit,
  fechaPago DATETIME,
  monto NUMERIC DEFAULT 0,
  CONSTRAINT fkLicenciasLog FOREIGN KEY(idLicencia) REFERENCES licencias(idLicencia),
  CONSTRAINT fkEmpresaLicenciaLog FOREIGN KEY(idEmpresa) REFERENCES empresas(idEmpresa),
  CONSTRAINT fkSucursalLicenciaLog FOREIGN KEY(idSucursal) REFERENCES sucursales(idSucursal),
  CONSTRAINT fkTipoLicenciaLicenciasLog FOREIGN KEY(idTipoLicencia) REFERENCES tipoLicencia(idTipoLicencia),
  fecha_log DATETIME DEFAULT GETDATE(),
  estado VARCHAR(45)
)

CREATE TABLE licenciaDocumentacionIngresada(
  idLicenciaDocumentacionIngresada INT IDENTITY(1,1) PRIMARY KEY,
  idLicencia INT NOT NULL,
  idTipoLicenciaDocumentacionRequerida INT NOT NULL,
  fechaIngreso DATETIME,
  documentacionValida bit,
  CONSTRAINT fkLicenciaDocumentacionIngresadaLicencias FOREIGN KEY(idLicencia) REFERENCES licencias(idLicencia),
  CONSTRAINT fkLicenciaDocumentacionIngresadaTipoLicenciaDocumentacionRequerida FOREIGN KEY(idTipoLicenciaDocumentacionRequerida) REFERENCES tipoLicenciaDocumentacionRequerida(idTipoLicenciaDocumentacionRequerida)
)