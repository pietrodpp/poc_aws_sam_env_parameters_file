@ECHO OFF
setlocal
setlocal EnableDelayedExpansion

SET @CMDS="sam"
SET @MSG_NOT_FOUND_ERR="SAM command wasn't found. Be sure AWS SAM is properly installed."
SET ARGS=%*

:: check if sam is installed
where %@CMDS% >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    CALL :PRINT_ERR_MSG %@MSG_NOT_FOUND_ERR%
    goto END_MAIN
)

:: check for override-paramter using file path value
:Loop
IF "%~1"=="" GOTO Continue
SET _ARGS=%_ARGS% %1
IF "%~1"=="--parameter-overrides" (
    :NESTED_LOOP
    SET _ARG_2=%2
    SET _SUB_ARG_2=!_ARG_2:~0,2!
    IF NOT "!_SUB_ARG_2!"=="--" (
        CALL :IS_A_FILE !_ARG_2!
        SET CALL_RESPONSE=!errorlevel!
        IF !CALL_RESPONSE!==0 (
            CALL :CAT OUTPUT_VAR, !_ARG_2!
            SET _ARGS=%_ARGS% !OUTPUT_VAR!
        ) ELSE (
            SET _ARGS=%_ARGS% %2
        )
        SHIFT
        GOTO NESTED_LOOP
    )
)

SHIFT
GOTO Loop

:Continue

:: execute sam command
%@CMDS% %_ARGS%

::END MAIN
goto END_MAIN

:END_MAIN
EXIT /B %ERRORLEVEL%

:PRINT_ERR_MSG
ECHO [ERROR] %~1
EXIT /B %ERRORLEVEL%

:: check if the given param is a valid file path
:IS_A_FILE
SET IS_A_FILE_ARG_1=%1
IF EXIST %IS_A_FILE_ARG_1% (
    EXIT /B 0
) ELSE (
    EXIT /B -1
)

:: concatenate file params. Also skip comment line
:CAT
SET FILE_PATH=%2
FOR /f "delims=" %%G IN (%FILE_PATH%) DO (
    :: skip comments
    SET CAT_FOR_F_ARG=%%G
    SET COMMENT_CHAR=!CAT_FOR_F_ARG:~0,1!
    IF NOT !COMMENT_CHAR!==# (
        CALL SET OUTPUT=%%OUTPUT%% %%G
    )
)
CALL SET %1=%OUTPUT:~1%
EXIT /B %errorlevel%

:END_MAIN
endlocal
EXIT /B %ERRORLEVEL%