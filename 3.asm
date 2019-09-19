;-------------------------------------------------------;
; Programa: Maior valor em vetor                        ;
; Autores: Breno Tostes, Matheus Avellar, Pedro Possato ;
; Data: 2019.09.17                                      ;
;-------------------------------------------------------;

BANNER      EQU 2
CLEARBANNER EQU 3

ORG 100H
  ARR:    DW 10,100,101,500,1,2,2,1,1,1,  1,1,1,1,1,1,1,2,3,7
ORG 150H
  PTR:    DW ARR
  GTR_I:  DB 0
  VAL:    DW 0

ORG 0H
MAIN:
  OUT CLEARBANNER ; Limpa o banner
  LDS PTR         ; Endereço inicial é passado na pilha
  LDA #20         ; Tamanho é passado no acumulador
  JSR Maior       ; Chama a subrotina Maior
  STA GTR_I       ; Guarda o índice do maior em GTR_I

;##### Pegar o maior valor, dado um índice #####;
  LDS PTR         ; Aponta SP para o começo do vetor
Consumer:
  POP             ; Pega o LOW byte da pilha
  STA VAL+1       ; Guarda em VAL+1
  POP             ; Pega o HIGH byte da pilha
  STA VAL         ; Guarda em VAL+0
  LDA GTR_I       ; }
  JZ PrintVal     ; Se for o primeiro, show, imprime
  SUB #1          ;  GTR_I--
  STA GTR_I       ; }
  JMP Consumer    ; Volta para o loop

;##### Imprimir em hexadecimal, dado um valor #####;
  BITS:  DB 0     ; Espaço para trabalhar com 4 bits
PrintVal:
  LDA VAL         ; Vamos converter a parte de cima do HIGH byte de VAL
  AND #0F0H       ; AND com (1111 0000)
  SHR             ; }
  SHR             ;  Seguido de 4 shifts
  SHR             ;  à direita
  SHR             ; }
  STA BITS        ; Temos agora os 4 maiores bits do HIGH byte
  JSR PrintHex    ; Converte para hexadecimal e imprime
  LDA VAL         ; Vamos converter a parte de baixo do HIGH byte de VAL
  AND #0FH        ; AND com (0000 1111)
  STA BITS        ; Temos agora os 4 menores bits do HIGH byte
  JSR PrintHex    ; Converte para hexadecimal e imprime

  LDA VAL+1       ; Vamos converter a parte de cima do LOW byte de VAL
  AND #0F0H       ; AND com (1111 0000)
  SHR             ; }
  SHR             ;  Seguido de 4 shifts
  SHR             ;  à direita
  SHR             ; }
  STA BITS        ; Temos agora os 4 maiores bits do LOW byte
  JSR PrintHex    ; Converte para hexadecimal e imprime
  LDA VAL+1       ; Vamos converter a parte de baixo do LOW byte de VAL
  AND #0FH        ; AND com (0000 1111)
  STA BITS        ; Temos agora os 4 menores bits do LOW byte
  JSR PrintHex    ; Converte para hexadecimal e imprime

  HLT             ; Fim :)

PrintHex:
  SUB #10         ; BITS - 10
  JN PrintNumber  ; Se bits < 10, é um número
                  ; Se bits >= 10, então é uma letra
  ADD #41H        ; Adiciona a posição do A em ASCII
  JMP PrintPrint  ; Imprime
PrintNumber:
  LDA BITS        ; Recupera o valor dos bits
  ADD #30H        ; Adiciona a posição do 0 em ASCII
PrintPrint:
  OUT BANNER      ; Imprime
  RET             ; Volta

ORG 200H
  PTR_LO: DB 0    ; LOW byte do ponteiro de retorno
  PTR_HI: DB 0    ; HIGH byte do ponteiro de retorno
  SIZE:   DB 0    ; Tamanho do vetor
  CURR:   DW 0    ; Número atual sendo comparado
  I:      DB -1   ; Índice atual
  GT:     DW 0    ; Maior número encontrado
  IGT:    DB 0    ; Índice do maior número
Maior:
  STA SIZE        ; Transfere o tamanho do vetor para SIZE
  POP             ; }
  STA PTR_LO      ;  Pega o endereço de retorno da pilha
  POP             ;  Guarda na memória
  STA PTR_HI      ; }

LOOP:
  LDA SIZE        ; }
  SUB #1          ;  SIZE--
  STA SIZE        ; }
  JN FIM          ; Se SIZE < 0, terminamos
  LDA I           ; }
  ADD #1          ;  I++
  STA I           ; }

  POP             ; Pega o LOW byte do elemento do vetor
  STA CURR+1      ; Salva o valor do LOW byte
  POP             ; Pega o HIGH byte do elemento do vetor
  STA CURR        ; Salva o valor do HIGH byte
  SUB GT          ; CURR - GT
  JP TrocaMaior   ; Se o resultado é positivo, CURR > GT
  JZ ComparaLO    ; Se o resultado é zero, HI(CURR) = HI(GT)
                  ; Se for negativo, GT > CURR
  JMP LOOP        ; Volta para o loop

TrocaMaior:
  LDA CURR        ; Pega o HIGH byte do valor atual
  STA GT          ; Salva na memória em GT+0
  LDA CURR+1      ; Pega o LOW byte do valor atual
  STA GT+1        ; Salva na memória em GT+1
  LDA I           ; Pega o índice atual
  STA IGT         ; Salva como índice do maior elemento
  JMP LOOP        ; Volta para o loop

ComparaLO:
  LDA CURR+1      ; Carrega o LOW byte da memória
  SUB GT+1        ; LOW(CURR) - LOW(GT)
  JP TrocaMaior   ; Se o resultado é positivo, CURR > GT
                  ; Se o resultado é zero, CURR = GT ¯\_(ツ)_/¯
                  ; Se for negativo, GT > CURR
  JMP LOOP        ; Volta para o loop

FIM:
  LDA PTR_HI      ; }
  PUSH            ;  Pega o endereço de retorno da memória
  LDA PTR_LO      ;  Guarda na pilha
  PUSH            ; }
  LDA IGT         ; Retorna no acumulador o índice do maior elemento
  RET
