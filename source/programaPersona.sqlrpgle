**FREE
// ============================================================================
// -- Programa.....:
// -- Descripcion..:
// -- Desarrollador:
// -- Fecha........:
// ============================================================================


// ======================= Control de opciones ================================
CTL-OPT DFTACTGRP(*NO) ACTGRP(*CALLER) OPTION(*SRCSTMT:*NODEBUGIO);

// ================== Definicion de archivo de pantalla =======================
DCL-F PERSDSPF WORKSTN(*EXT) USAGE(*INPUT:*OUTPUT)
               INDDS(DSIND) SFILE(PERDTASFL1:$reg);

// ================= Definicion de estructuras de datos =======================
DCL-DS dsIND;
    salir     IND POS(3);
    agregar   IND POS(6);
    confirmar IND POS(10);
    cancelar  IND POS(12);
    visualSFL IND POS(68);
    visualCTL IND POS(69);
    borrarSFL IND POS(70);
    finSFL    IND POS(71);
END-DS;

DCL-DS resQuery QUALIFIED;
    IDEPER  CHAR(18);
    NOMPER  CHAR(40);
    EDAPER  ZONED(3:0);
    GENPER  CHAR(1);
    USRREG  CHAR(32);
    FECREG  DATE;
END-DS;

// ================= Definicion de variables globales =========================
DCL-S $reg ZONED(4:0) INZ;

// ======================== Programa principal ================================
DOW NOT salir;
    cargarDatos();
    WRITE PIE1;
    EXFMT PERDTACTL1;

    IF agregar = *ON;
        OPCION = 'A';
        crearRegistro();
    ENDIF;

    IF $reg = 0;
        ITER;
    ENDIF;

    READC PERDTASFL1;
    DOW NOT %EOF(PERSDSPF);
    SELECT;
        WHEN OPCION = 'C';
            consultarRegistro();
        WHEN OPCION = 'M';
            modificarRegistro();
        WHEN OPCION = 'E';
            eliminaRegistro();
    ENDSL;
    READC PERDTASFL1;
    ENDDO;
ENDDO;

*INLR = *ON;
// ============================================================================


// =========================== Procesos internos ==============================
// ============================================================================
// -- Procedimiento: cargarDatos
// -- Descripcion..: Carga los datos al almacenados en la tabla DTASPER
// --                hacia el subfile PERDTASFL1.
// ============================================================================
DCL-PROC cargarDatos;
    borrarSFL = *ON;
    WRITE PERDTACTL1;
    borrarSFL = *OFF;
    $reg = 0;

    EXEC SQL DECLARE QRY_DATOS_PERSONA CURSOR FOR
                SELECT IDEPER, NOMPER, EDAPER, GENPER, USRREG, FECREG
                    FROM CJB4033071.DTASPERS;

    EXEC SQL OPEN QRY_DATOS_PERSONA;
    EXEC SQL FETCH QRY_DATOS_PERSONA INTO :resQuery;

    DOW SQLSTATE = '00000';
        $reg += 1;
        WRITE PERDTASFL1;
        EXEC SQL FETCH QRY_DATOS_PERSONA INTO :resQuery;
    ENDDO;

    EXEC SQL CLOSE QRY_DATOS_PERSONA;

    IF $reg > 0;
        visualSFL = *ON;
        visualCTL = *ON;
    ELSE;
        visualSFL = *OFF;
        visualCTL = *ON;
    ENDIF;

    finSFL = *ON;
END-PROC;

// ============================================================================
// -- Procedimiento: consultarRegistro
// -- Descripcion..:
// --
// ============================================================================
DCL-PROC consultarRegistro;
END-PROC;

// ============================================================================
// -- Procedimiento: crearRegistro
// -- Descripcion..:
// --
// ============================================================================
DCL-PROC crearRegistro;
END-PROC;

// ============================================================================
// -- Procedimiento: modificarRegistro
// -- Descripcion..:
// --
// ============================================================================
DCL-PROC modificarRegistro;
END-PROC;

// ============================================================================
// -- Procedimiento: eliminaRegistro
// -- Descripcion..:
// --
// ============================================================================
DCL-PROC eliminaRegistro;
END-PROC;

// ============================================================================
// -- Procedimiento: validarCampos
// -- Descripcion..:
// --
// ============================================================================
DCL-PROC validarCampos;
END-PROC;

