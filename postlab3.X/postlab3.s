;*******************************************************************************
; Universidad del Valle de Guatemala
; IE2023 ProgramaciÃ³n de Microcontroladores
; Autor: ALDO AVILA
; Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
; Proyecto: POSTLABORATORIO 3
; Hardware: PIC16F887
; Creado: 13/08/22
;******************************************************************************* 
PROCESSOR 16F887
#include <xc.inc>
;******************************************************************************* 
; Palabra de configuraciÃ³n    
;******************************************************************************* 
; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
;******************************************************************************* 
; Variables    
;******************************************************************************* 
PSECT udata_bank0
 W_TEMP:
    DS 1
 STATUS_TEMP:
    DS 1
 CONT20MS:
    DS 1
 CONTADOR:
    DS 1
;******************************************************************************* 
; Vector Reset    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0000
    goto MAIN
;******************************************************************************* 
; Vector ISR Interrupciones    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0004
PUSH:
    MOVWF W_TEMP	    ; guardamos el valor de w
    SWAPF STATUS, W	    ; movemos los nibles de status en w
    MOVWF STATUS_TEMP	    ; guardamos el valor de w en variable. 
			    ; temporal de status
ISR:  
    BTFSS INTCON, 2	    ; EstÃ¡ encendido el bit T0IF?
    GOTO  RRBIF 
    BCF INTCON, 2	    ; apagamos la bandera de T0IF
    INCF CONT20MS	    ; incrementamos la variable
    MOVLW 178
    MOVWF TMR0		    ; reinicamos el valor de N en TMR0
    GOTO POP
RRBIF:
    BTFSS INTCON, 0	    ; EstÃ¡ encendido el bit RBIF?
    GOTO POP
    BCF INTCON, 0
POP:
    SWAPF STATUS_TEMP, W    ; movemos los nibles de status de nuevo y los
			    ; cargamos a W
    MOVWF STATUS	    ; movemos el valor de W al registro STATUS
    SWAPF W_TEMP, F	    ; Movemos los nibles de W en el registro temporal
    SWAPF W_TEMP, W	    ; Movemos los nibles de vuelta para tenerlo en W
    RETFIE		    ; Retornamos de la interrupciÃ³n
;******************************************************************************* 
; CÃ³digo Principal    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0100
MAIN:
    BANKSEL OSCCON
    
    BSF OSCCON, 6	; IRCF2 SelecciÃ³n de 2 MHz
    BCF OSCCON, 5	; IRCF1
    BSF OSCCON, 4	; IRCF0
    
    BSF OSCCON, 0	; SCS Reloj Interno
    
    BANKSEL TRISC
    CLRF TRISC		; Limpiar el registro TRISB
    
    BANKSEL ANSEL
    CLRF ANSEL
    CLRF ANSELH
    
    ; ConfiguraciÃ³n TMR0
    BANKSEL OPTION_REG
    BCF OPTION_REG, 5	; T0CS: FOSC/4 COMO RELOJ (MODO TEMPORIZADOR)
    BCF OPTION_REG, 3	; PSA: ASIGNAMOS EL PRESCALER AL TMR0
    
    BSF OPTION_REG, 2
    BSF OPTION_REG, 1
    BCF OPTION_REG, 0	; PS2-0: PRESCALER 1:128 SELECIONADO 
    
    
    BANKSEL PORTC
    CLRF PORTC		; Se limpia el puerto C
    CLRF CONT20MS	; Se limpia la variable cont50ms
    
    MOVLW 178
    MOVWF TMR0		; CARGAMOS EL VALOR DE N = DESBORDE 50mS
    
    BCF INTCON, 2	; Apagamos la bandera T0IF del TMR0
    BSF INTCON, 5	; Habilitando la interrupcion T0IE TMR0
    
    BSF INTCON, 7	; Habilitamos el GIE interrupciones globales
    CLRF CONTADOR
        
LOOP:

    MOVF CONTADOR, W	; MOVEMOS LO QUE ESTE EN CONTADOR A W
    PAGESEL TABLA	; NOS UBICAMOS EN LA PAGINA DONDE SE ENCUENTRA LA TABLA
    CALL TABLA		; LLAMAMOS A LA TABLA
    MOVWF PORTC		;MOVEMOS LOS DATOS DE W AL PORTC
VERIFICACION:    
    MOVF CONT20MS, W
    SUBLW 50
    BTFSS STATUS, 2	; verificamos bandera z
    GOTO VERIFICACION
    CLRF CONT20MS
    INCF CONTADOR, F	; Incrementamos el Puerto C
    GOTO LOOP		; Regresamos a la etiqueta LOOP

;******************************************************************************* 
; TABLA   
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x64
TABLA:
    ADDWF PCL, F
    RETLW 0b0111111	;0
    RETLW 0b0000110	;1 
    RETLW 0b1011011	;2 
    RETLW 0b1001111	;3 
    RETLW 0b1100110	;4 
    RETLW 0b1101101	;5 
    RETLW 0b1111101	;6 
    RETLW 0b0000111	;7 
    RETLW 0b1111111	;8 
    RETLW 0b1101111	;9 
    RETLW 0b1110111	;A 
    RETLW 0b1111100	;b
    RETLW 0b0111001	;C 
    RETLW 0b1011110	;d 
    RETLW 0b1111001	;E
    RETLW 0b1110001	;F 
;******************************************************************************* 
; Fin de CÃ³digo    
;******************************************************************************* 
END

