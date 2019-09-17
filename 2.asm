;-------------------------------------------------------;
; Programa: Compara i16                                 ;
; Autores: Breno Tostes, Matheus Avellar, Pedro Possato ;
; Data: 2019.09.16                                      ;
;-------------------------------------------------------;

BANNER EQU 2
CLEARBANNER EQU 3

ORG 200H
  PTR_V1: DW VAR1
  PTR_V2: DW VAR2
  VAR1: DW 100
  VAR2: DW 200

ORG 0H
MAIN:
  OUT CLEARBANNER ; Limpa o banner
  LDS #500H       ; Começa uma pilha em 0x0500
  LDA VAR1        ; Empilha o LOW byte do endereço de V1
  PUSH
  LDA VAR1+1      ; Empilha o HIGH byte do endereço de V1
  PUSH
  LDA VAR2        ; Empilha o LOW byte do endereço de V2
  PUSH
  LDA VAR2+1      ; Empilha o HIGH byte do endereço de V2
  PUSH

  JSR Compara     ; Chama a subrotina
                  ; Temos o valor de retorno no acumulador
  JP POSITIVO     ; Se for um valor positivo, vamos imprimir
  JZ POSITIVO     ; Ou zero, que também é um valor positivo(!!),
                  ; mas aparentemente JP discorda da matemática
  LDA #2DH        ; Senão, imprimimos "-1"
  OUT BANNER
  LDA #31H
  OUT BANNER
  JMP EXIT        ; E vamos para o fim
POSITIVO:
  ADD #30H        ; Se é positivo (0 ou 1), imprimimos
  OUT BANNER      ; seu caractere em ASCII
EXIT:
  HLT             ; Fim


ORG 50H  
  PTR_LO:DB 0     ; LOW byte do ponteiro de retorno
  PTR_HI:DB 0     ; HIGH byte do ponteiro de retorno
  PTR_TMP:DW 0    ; Ponteiro temporário
  V1:    DW 0     ; Valor de VAR1
  V2:    DW 0     ; Valor de VAR2
  RETVAL:DB 0     ; Valor de retorno da rotina
Compara:
  POP             ; }
  STA PTR_LO      ;  Pega o endereço de retorno da pilha
  POP             ;  Guarda na memória
  STA PTR_HI      ; }

  POP             ; }
  STA  V2+1       ;  Pega VAR2
  POP             ;  Guarda na memória
  STA  V2         ; }

  POP             ; }
  STA  V1+1       ;  Pega VAR1
  POP             ;  Guarda na memória
  STA  V1         ; }

  ; Temos ambos os valores 16 bits salvos
  ; e também o endereço de retorno
  ; Precisamos agora somente comparar os
  ; valores e retornar o resultado

  LDA V1          ; HIGH(VAR1) - HIGH(VAR2)
  SUB V2
  JZ ComparaLO    ; Se for = 0, vamos testar os LOW bytes
  JN Menor        ; Se for negativo, VAR1 < VAR2
  JMP Maior       ; Senão, VAR1 > VAR2
ComparaLO:
  LDA V1+1        ; LOW(VAR1) - LOW(VAR2)
  SUB V2+1
  JZ Igual        ; Se for = 0, são iguais
  JN Menor        ; Se for negativo, VAR1 < VAR2
                  ; Senão, VAR1 > VAR2
Maior:
  LDA #1          ; Se VAR1 > VAR2, retorna 1
  STA RETVAL
  JMP LEAVE
Menor:
  LDA #-1         ; Se VAR1 < VAR2, retorna -1
  STA RETVAL
  JMP LEAVE
Igual:
  LDA #0          ; Se VAR1 = VAR2, retorna 0
  STA RETVAL

  ; Comparação terminada, podemos retornar
LEAVE:
  LDA PTR_HI      ; }
  PUSH            ;  Pega o endereço de retorno da memória
  LDA PTR_LO      ;  Guarda na pilha
  PUSH            ; }
  LDA RETVAL
  RET
