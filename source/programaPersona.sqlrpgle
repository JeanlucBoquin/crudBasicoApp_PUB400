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
                SELECT IDEPER, NOMPER, EDAPER,
                       GENPER, USRREG, FECREG
                    FROM CJB4033071.DTASPERS;

    EXEC SQL OPEN QRY_DATOS_PERSONA;
    EXEC SQL FETCH QRY_DATOS_PERSONA INTO :resQuery;

    DOW SQLSTATE = '00000';
        SFL_NUMDNI = resQuery.IDEPER;
        SFL_NOMBRE = resQuery.NOMPER;
        SFL_EDAD   = %CHAR(resQuery.EDAPER);
        SFL_GENERO = resQuery.GENPER;
        SFL_USRING = resQuery.USRREG;
        SFL_FECING = %CHAR(resQuery.FECREG);
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
// -- Descripcion..: Consulta registro de DTASPERS
// ============================================================================
DCL-PROC consultarRegistro;
    DCL-S NOMCOM CHAR(40);

    EXEC SQL SELECT IDEPER, NOMPER, EDAPER, GENPER
                INTO :NUMDNI, :NOMCOM, :EDAD, :GENERO
                FROM CJB4033071.DTASPERS
                WHERE IDEPER = :SFL_NUMDNI;

    NOMBPAR1 = %SUBST(NOMCOM:1:20);
    NOMBPAR2 = %SUBST(NOMCOM:21:20);

    EXFMT PERDTAWIN1;
END-PROC;

// ============================================================================
// -- Procedimiento: crearRegistro
// -- Descripcion..:
// --
// ============================================================================
DCL-PROC crearRegistro;
    DCL-S nombreCompleto CHAR(40);

    DOW cancelar = *OFF;
        EXFMT PERDTAWIN2;
        IF confirmar = *ON;
            IF validarCampos();
                nombreCompleto = %TRIM(NOMBPAR1) + ' ' + %TRIM(NOMBPAR2);
                EXEC SQL INSERT INTO CJB4033071.DTASPERS
                        (IDEPER, NOMPER, EDAPER, GENPER, USRREG, FECREG)
                        VALUES
                        (:NUMDNI, :nombreCompleto, :EDAD, :GENERO, 
                         CURRENT_USER, CURRENT_DATE);
                IF SQLSTATE = '00000';
                    EXFMT PERDTAWIN5;
                    LEAVE;
                ELSE;
                    EXFMT PERDTAWIN6;
                    LEAVE;
                ENDIF;
            ENDIF;
        ENDIF;
    ENDDO;
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
// -- Descripcion..: Eliminar registro de DTASPERS
// ============================================================================
DCL-PROC eliminaRegistro;
    DCL-S NOMCOM CHAR(40);

    EXEC SQL SELECT IDEPER, NOMPER, EDAPER, GENPER
                INTO :NUMDNI, :NOMCOM, :EDAD, :GENERO
                FROM CJB4033071.DTASPERS
                WHERE IDEPER = :SFL_NUMDNI;

    NOMBPAR1 = %SUBST(NOMCOM:1:20);
    NOMBPAR2 = %SUBST(NOMCOM:21:20);

    DOW cancelar = *OFF;
        EXFMT PERDTAWIN4;
        IF confirmar = *ON;
            EXEC SQL DELETE FROM CJB4033071.DTASPERS
                        WHERE IDEPER = :SFL_NUMDNI;
            IF SQLSTATE = '00000';
                EXFMT PERDTAWIN5;
                LEAVE;
            ELSE;
                EXFMT PERDTAWIN6;
                LEAVE;
            ENDIF;
        ENDIF;
    ENDDO;
    CLEAR cancelar;
END-PROC;

// ============================================================================
// -- Procedimiento: validarCampos
// -- Descripcion..:
// --
// ============================================================================
DCL-PROC validarCampos;
    DCL-PI validarCampos IND;
    END-PI;

    DCL-S caracteresValidos CHAR(10) INZ('0123456789');
    DCL-S existePersona ZONED(2);
    DCL-S nombreCompleto CHAR(40);

    // msgErr01 = *ON;
    IF NUMDNI = '';
        RETURN *OFF;
    ENDIF;

    IF %CHECK(caracteresValidos:%TRIM(NUMDNI)) <> 0;
        RETURN *OFF;
    ENDIF;

    IF OPCION = 'A';
        EXEC SQL SELECT COUNT(NUMDNI)
                    INTO :existePersona
                    FROM CJB4033071.DTASPERS
                    WHERE IDEPER = :SFL_NUMDNI;
        IF existePersona > 0 AND SQLSTATE = '00000';
            RETURN *OFF;
        ENDIF;
    ENDIF;

    nombreCompleto = %TRIM(NOMBPAR1) + ' ' + %TRIM(NOMBPAR2);
    IF nombreCompleto = '';
        RETURN *OFF;
    ENDIF;

    IF EDAD = '';
        RETURN *OFF;
    ENDIF;

    IF %CHECK(caracteresValidos:%TRIM(EDAD)) <> 0;
        RETURN *OFF;
    ENDIF;

    IF GENERO = '';
        RETURN *OFF;
    ENDIF;

    IF GENERO <> 'M' OR GENERO <> 'F' OR GENERO <> 'X';
        RETURN *OFF;
    ENDIF;

    RETURN *ON;
END-PROC;

